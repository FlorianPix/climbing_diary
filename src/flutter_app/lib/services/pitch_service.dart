import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:climbing_diary/services/error_service.dart';
import 'package:climbing_diary/components/common/my_notifications.dart';
import 'package:climbing_diary/config/environment.dart';
import 'package:climbing_diary/interfaces/pitch/create_pitch.dart';
import 'package:climbing_diary/data/network/dio_client.dart';
import 'package:climbing_diary/data/sharedprefs/shared_preference_helper.dart';
import 'package:climbing_diary/interfaces/pitch/pitch.dart';
import 'package:climbing_diary/interfaces/pitch/update_pitch.dart';
import 'package:climbing_diary/services/cache_service.dart';
import 'package:climbing_diary/services/locator.dart';

class PitchService {
  final netWorkLocator = getIt.get<DioClient>();
  final sharedPrefLocator = getIt.get<SharedPreferenceHelper>();
  final String climbingApiHost = Environment().config.climbingApiHost;
  final String mediaApiHost = Environment().config.mediaApiHost;

  /// Get a pitch by its id from cache and optionally from the server.
  /// If the parameter [online] is null or false the pitch is searched in cache,
  /// otherwise it is requested from the server.
  Future<Pitch?> getPitch(String pitchId, {bool? online}) async {
    Box box = Hive.box(Pitch.boxName);
    if (online == null || !online) return Pitch.fromCache(box.get(pitchId));
    // request pitch from server
    try {
      final Response missingPitchResponse = await netWorkLocator.dio.post('$climbingApiHost/pitch/$pitchId');
      if (missingPitchResponse.statusCode != 200) throw Exception("Error during request of missing pitch");
      return Pitch.fromJson(missingPitchResponse.data);
    } catch (e) {
      ErrorService.handleConnectionErrors(e);
    }
    return null;
  }

  /// Get pitches with given ids from cache and optionally from the server.
  /// If the parameter [online] is null or false the pitches are searched in cache,
  /// otherwise they are requested from the server.
  Future<List<Pitch>> getPitchesOfIds(List<String> pitchIds, {bool? online}) async {
    List<Pitch> pitches = CacheService.getTsFromCache<Pitch>(Pitch.boxName, Pitch.fromCache);
    if(online == null || !online) return pitches.where((pitch) => pitchIds.contains(pitch.id)).toList();
    // request pitches from the server
    try {
      List<Pitch> pitches = [];
      Box box = Hive.box(Pitch.boxName);
      final Response missingPitchesResponse = await netWorkLocator.dio.post('$climbingApiHost/pitch/ids', data: pitchIds);
      if (missingPitchesResponse.statusCode != 200) throw Exception("Error during request of missing pitches");
      Future.forEach(missingPitchesResponse.data, (dynamic s) async {
        Pitch pitch = Pitch.fromJson(s);
        await box.put(pitch.id, pitch.toJson());
        pitches.add(pitch);
      });
      return pitches;
    } catch (e) {
      ErrorService.handleConnectionErrors(e);
    }
    return [];
  }

  /// Get all pitches from cache and optionally from the server.
  /// If the parameter [online] is null or false the pitches are searched in cache,
  /// otherwise they are requested from the server.
  Future<List<Pitch>> getPitches({bool? online}) async {
    if(online == null || !online) return CacheService.getTsFromCache<Pitch>(Pitch.boxName, Pitch.fromCache);
    // request pitches from the server
    try {
      List<Pitch> pitches = [];
      Box box = Hive.box(Pitch.boxName);
      final Response missingPitchesResponse = await netWorkLocator.dio.get('$climbingApiHost/pitch');
      if (missingPitchesResponse.statusCode != 200) throw Exception("Error during request of missing pitches");
      Future.forEach(missingPitchesResponse.data, (dynamic s) async {
        Pitch pitch = Pitch.fromJson(s);
        await box.put(pitch.id, pitch.toJson());
        pitches.add(pitch);
      });
      return pitches;
    } catch (e) {
      ErrorService.handleConnectionErrors(e);
    }
    return [];
  }

  /// Get all pitches from cache and optionally from the server by their name.
  /// If the parameter [online] is null or false the pitches are searched in cache,
  /// otherwise they are requested from the server.
  Future<List<Pitch>> getPitchesByName(String name, {bool? online}) async {
    List<Pitch> pitches = await getPitches(online: online);
    if (name.isEmpty) return pitches;
    return pitches.where((pitch) => pitch.name.contains(name)).toList();
  }

  /// Create a pitch in cache and optionally on the server.
  /// If the parameter [online] is null or false the pitch is added to the cache and uploaded later at the next sync.
  /// Otherwise it is added to the cache and to the server.
  Future<Pitch?> createPitch(CreatePitch createPitch, String routeId, {bool? online}) async {
    CreatePitch pitch = CreatePitch(
      comment: (createPitch.comment != null) ? createPitch.comment! : "",
      grade: createPitch.grade,
      length: createPitch.length,
      name: createPitch.name,
      num: createPitch.num,
      rating: createPitch.rating,
    );
    // add to cache
    Box pitchBox = Hive.box(Pitch.boxName);
    Box createPitchBox = Hive.box(CreatePitch.boxName);
    Pitch tmpPitch = pitch.toPitch();
    await pitchBox.put(pitch.hashCode, tmpPitch.toJson());
    await createPitchBox.put(pitch.hashCode, pitch.toJson());
    if (online == null || !online) return tmpPitch;
    // try to upload and update cache if successful
    Map data = pitch.toJson();
    Pitch? uploadedPitch = await uploadPitch(routeId, data);
    if (uploadedPitch == null) return tmpPitch;
    await pitchBox.delete(pitch.hashCode);
    await createPitchBox.delete(pitch.hashCode);
    await pitchBox.put(uploadedPitch.id, uploadedPitch.toJson());
    return uploadedPitch;
  }

  /// Edit a pitch in cache and optionally on the server.
  /// If the parameter [online] is null or false the pitch is edited only in the cache and later on the server at the next sync.
  /// Otherwise it is edited in cache and on the server immediately.
  Future<Pitch?> editPitch(UpdatePitch updatePitch, {bool? online}) async {
    // add to cache
    Box pitchBox = Hive.box(Pitch.boxName);
    Box updatePitchBox = Hive.box(UpdatePitch.boxName);
    Pitch oldPitch = Pitch.fromCache(pitchBox.get(updatePitch.id));
    Pitch tmpPitch = updatePitch.toPitch(oldPitch);
    await pitchBox.put(updatePitch.id, tmpPitch.toJson());
    await updatePitchBox.put(updatePitch.id, updatePitch.toJson());
    if (online == null || !online) return tmpPitch;
    // try to upload and update cache if successful
    try {
      final Response response = await netWorkLocator.dio.put('$climbingApiHost/pitch/${updatePitch.id}', data: updatePitch.toJson());
      if (response.statusCode != 200) throw Exception('Failed to edit pitch');
      Pitch pitch = Pitch.fromJson(response.data);
      await pitchBox.put(updatePitch.id, updatePitch.toJson());
      await updatePitchBox.delete(updatePitch.id);
      return pitch;
    } catch (e) {
      ErrorService.handleConnectionErrors(e);
    }
    return null;
  }

  /// Delete a pitch its media, and ascents in cache and optionally on the server.
  /// If the parameter [online] is null or false the data is deleted only from the cache and later from the server at the next sync.
  /// Otherwise it is deleted from cache and from the server immediately.
  Future<void> deletePitch(String routeId, Pitch pitch, {bool? online}) async {
    Box pitchBox = Hive.box(Pitch.boxName);
    Box deletePitchBox = Hive.box(Pitch.deleteBoxName);
    await pitchBox.delete(pitch.id);
    await deletePitchBox.put(pitch.id, pitch.toJson());
    // TODO delete media from cache
    // TODO delete ascents from cache
    if (online == null || !online) return;
    try {
      // delete media
      for (var id in pitch.mediaIds) {
        final Response mediaResponse = await netWorkLocator.dio.delete('$mediaApiHost/media/$id');
        if (mediaResponse.statusCode != 204) throw Exception('Failed to delete medium');
      }
      // delete pitch
      final Response pitchResponse = await netWorkLocator.dio.delete('$climbingApiHost/pitch/${pitch.id}');
      if (pitchResponse.statusCode != 200) throw Exception('Failed to delete pitch');
      await deletePitchBox.delete(pitch.id);
      MyNotifications.showPositiveNotification('Pitch was deleted: ${pitchResponse.data['name']}');
    } catch (e) {
      ErrorService.handleConnectionErrors(e);
    }
  }

  /// Upload a pitch to the server.
  Future<Pitch?> uploadPitch(String routeId, Map data) async {
    try {
      final Response response = await netWorkLocator.dio.post('$climbingApiHost/pitch/route/$routeId', data: data);
      if (response.statusCode != 201) throw Exception('Failed to create pitch $response');
      MyNotifications.showPositiveNotification('Created new pitch: ${response.data['name']}');
      return Pitch.fromJson(response.data);
    } catch (e) {
      ErrorService.handleCreationErrors(e, 'pitch');
    }
    return null;
  }
}
