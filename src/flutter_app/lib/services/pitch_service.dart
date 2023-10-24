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

import '../interfaces/ascent/ascent.dart';
import '../interfaces/media/media.dart';
import '../interfaces/multi_pitch_route/multi_pitch_route.dart';

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
  Future<Pitch?> createPitch(Pitch createPitch, String routeId, {bool? online}) async {
    // add to cache
    Box pitchBox = Hive.box(Pitch.boxName);
    await pitchBox.put(createPitch.id, createPitch.toJson());
    // add pitch to creation queue for later sync
    // add routeId as well so we later know to which spot to add it on the server
    Box createPitchBox = Hive.box(CreatePitch.boxName);
    Map<dynamic, dynamic> pitch = createPitch.toJson();
    pitch['routeId'] = routeId;
    await createPitchBox.put(createPitch.id, pitch);
    // add to pitchIds of multi pitch route locally
    Box multiPitchRouteBox = Hive.box(MultiPitchRoute.boxName);
    Map multiPitchRouteMap = multiPitchRouteBox.get(routeId);
    MultiPitchRoute multiPitchRoute = MultiPitchRoute.fromCache(multiPitchRouteMap);
    multiPitchRoute.pitchIds.add(createPitch.id);
    await multiPitchRouteBox.put(multiPitchRoute.id, multiPitchRoute.toJson());
    if (online == null || !online) return createPitch;
    // try to upload and update cache if successful
    Map data = createPitch.toJson();
    Pitch? uploadedPitch = await uploadPitch(routeId, data);
    if (uploadedPitch == null) return createPitch;
    await pitchBox.delete(createPitch.id);
    await createPitchBox.delete(createPitch.id);
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
    await updatePitchBox.put(updatePitch.id, tmpPitch.toJson());
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
  Future<void> deletePitch(Pitch deletePitch, String routeId, {bool? online}) async {
    // delete pitch locally
    Box pitchBox = Hive.box(Pitch.boxName);
    await pitchBox.delete(deletePitch.id);
    // add pitch to deletion queue for later sync
    // add routeId as well so we later know from which multi pitch route to remove it on the server
    Box deletePitchBox = Hive.box(Pitch.deleteBoxName);
    Map<dynamic, dynamic> pitch = deletePitch.toJson();
    pitch['routeId'] = routeId;
    await deletePitchBox.put(deletePitch.id, pitch);
    // remove from create queue (if no sync since)
    Box createPitchBox = Hive.box(Pitch.createBoxName);
    await createPitchBox.delete(deletePitch.id);
    // delete pitch id from multi pitch route
    Box multiPitchRouteBox = Hive.box(MultiPitchRoute.boxName);
    MultiPitchRoute multiPitchRoute = MultiPitchRoute.fromCache(multiPitchRouteBox.get(routeId));
    multiPitchRoute.pitchIds.remove(deletePitch.id);
    await multiPitchRouteBox.put(multiPitchRoute.id, multiPitchRoute.toJson());
    // delete media of pitch locally (deleted automatically on the server when multi pitch route is deleted)
    Box mediaBox = Hive.box(Media.boxName);
    for (String mediaId in deletePitch.mediaIds){
      await mediaBox.delete(mediaId);
    }
    // delete ascents of pitch locally (deleted automatically on the server when multi pitch route is deleted)
    Box ascentBox = Hive.box(Ascent.boxName);
    for (String ascentId in deletePitch.ascentIds){
      Ascent ascent = Ascent.fromCache(ascentBox.get(ascentId));
      for (String mediaId in ascent.mediaIds){
        await mediaBox.delete(mediaId);
      }
      await ascentBox.delete(ascentId);
    }
    if (online == null || !online) return;
    try {
      // delete pitch
      final Response pitchResponse = await netWorkLocator.dio.delete('$climbingApiHost/pitch/${deletePitch.id}/route/$routeId');
      if (pitchResponse.statusCode != 200) throw Exception('Failed to delete pitch');
      await deletePitchBox.delete(deletePitch.id);
      MyNotifications.showPositiveNotification('Pitch was deleted: ${pitchResponse.data['name']}');
    } catch (e) {
      ErrorService.handleConnectionErrors(e);
      if (e is DioError) {
        // if the pitch can't be found on the server then we can safely remove it locally as well
        if (e.error == "Http status error [404]"){
          await deletePitchBox.delete(deletePitch.id);
        }
      }
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
      if (e is DioError) {
        final response = e.response;
        if (response != null) {
          switch (response.statusCode) {
            case 409:
              MyNotifications.showNegativeNotification('This pitch already exists!');
              Box createPitchBox = Hive.box(CreatePitch.boxName);
              await createPitchBox.delete(data['_id']);
              break;
            default:
              throw Exception('Failed to create pitch');
          }
        }
      }
    }
    return null;
  }
}
