import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:climbing_diary/interfaces/media/media.dart';
import 'package:climbing_diary/services/error_service.dart';
import 'package:climbing_diary/components/common/my_notifications.dart';
import 'package:climbing_diary/config/environment.dart';
import 'package:climbing_diary/interfaces/ascent/create_ascent.dart';
import 'package:climbing_diary/data/network/dio_client.dart';
import 'package:climbing_diary/data/sharedprefs/shared_preference_helper.dart';
import 'package:climbing_diary/interfaces/ascent/ascent.dart';
import 'package:climbing_diary/interfaces/ascent/update_ascent.dart';
import 'package:climbing_diary/services/cache_service.dart';
import 'package:climbing_diary/services/locator.dart';

import '../interfaces/pitch/pitch.dart';
import '../interfaces/single_pitch_route/single_pitch_route.dart';

class AscentService {
  final netWorkLocator = getIt.get<DioClient>();
  final sharedPrefLocator = getIt.get<SharedPreferenceHelper>();
  final String climbingApiHost = Environment().config.climbingApiHost;
  final String mediaApiHost = Environment().config.mediaApiHost;

  /// Get a ascent by its id from cache and optionally from the server.
  /// If the parameter [online] is null or false the ascent is searched in cache,
  /// otherwise it is requested from the server.
  Future<Ascent?> getAscent(String ascentId, {bool? online}) async {
    Box box = Hive.box(Ascent.boxName);
    if (online == null || !online) return Ascent.fromCache(box.get(ascentId));
    // request ascent from server
    try {
      final Response ascentResponse = await netWorkLocator.dio.post('$climbingApiHost/ascent/$ascentId');
      if (ascentResponse.statusCode != 200) throw Exception("Error during request of missing ascent");
      return Ascent.fromJson(ascentResponse.data);
    } catch (e) {
      ErrorService.handleConnectionErrors(e);
    }
    return null;
  }

  /// Get ascents with given ids from cache and optionally from the server.
  /// If the parameter [online] is null or false the ascents are searched in cache,
  /// otherwise they are requested from the server.
  Future<List<Ascent>> getAscentsOfIds(List<String> ascentIds, {bool? online}) async {
    List<Ascent> ascents = CacheService.getTsFromCache<Ascent>(Ascent.boxName, Ascent.fromCache);
    if(online == null || !online) return ascents.where((ascent) => ascentIds.contains(ascent.id)).toList();
    // request ascents from the server
    try {
      List<Ascent> ascents = [];
      Box box = Hive.box(Ascent.boxName);
      final Response ascentsResponse = await netWorkLocator.dio.post('$climbingApiHost/ascent/ids', data: ascentIds);
      if (ascentsResponse.statusCode != 200) throw Exception("Error during request of missing ascents");
      Future.forEach(ascentsResponse.data, (dynamic s) async {
        Ascent ascent = Ascent.fromJson(s);
        await box.put(ascent.id, ascent.toJson());
        ascents.add(ascent);
      });
      return ascents;
    } catch (e) {
      ErrorService.handleConnectionErrors(e);
    }
    return [];
  }

  /// Get all ascents from cache and optionally from the server.
  /// If the parameter [online] is null or false the ascents are searched in cache,
  /// otherwise they are requested from the server.
  Future<List<Ascent>> getAscents({bool? online}) async {
    if(online == null || !online) return CacheService.getTsFromCache<Ascent>(Ascent.boxName, Ascent.fromCache);
    // request ascents from the server
    try {
      List<Ascent> ascents = [];
      Box box = Hive.box(Ascent.boxName);
      final Response ascentsResponse = await netWorkLocator.dio.get('$climbingApiHost/ascent');
      if (ascentsResponse.statusCode != 200) throw Exception("Error during request of ascents");
      Future.forEach(ascentsResponse.data, (dynamic s) async {
        Ascent ascent = Ascent.fromJson(s);
        box.put(ascent.id, ascent.toJson());
        ascents.add(ascent);
      });
      return ascents;
    } catch (e) {
      ErrorService.handleConnectionErrors(e);
    }
    return [];
  }

  /// Create a ascent in cache and optionally on the server.
  /// If the parameter [online] is null or false the ascent is added to the cache and uploaded later at the next sync.
  /// Otherwise it is added to the cache and to the server.
  Future<Ascent?> createAscentForPitch(Ascent createAscent, String pitchId, {bool? online}) async {
    // add to cache
    Box ascentBox = Hive.box(Ascent.boxName);
    await ascentBox.put(createAscent.id, createAscent.toJson());
    // add ascent to creation queue for later sync
    // add pitchId as well so we later know to which pitch to add it on the server
    Box createAscentBox = Hive.box(CreateAscent.boxName);
    Map<dynamic, dynamic> ascent = createAscent.toJson();
    ascent['ofPitch'] = true;
    ascent['parentId'] = pitchId;
    await createAscentBox.put(createAscent.id, ascent);
    // add to ascentIds of pitch locally
    Box pitchBox = Hive.box(Pitch.boxName);
    Map pitchMap = pitchBox.get(pitchId);
    Pitch pitch = Pitch.fromCache(pitchMap);
    pitch.ascentIds.add(createAscent.id);
    await pitchBox.put(pitch.id, pitch.toJson());
    if (online == null || !online) return createAscent;
    // try to upload and update cache if successful
    Map data = createAscent.toJson();
    Ascent? uploadedAscent = await uploadAscentForPitch(pitchId, data);
    if (uploadedAscent == null) return createAscent;
    await ascentBox.delete(createAscent.id);
    await createAscentBox.delete(createAscent.id);
    await ascentBox.put(uploadedAscent.id, uploadedAscent.toJson());
    return uploadedAscent;
  }

  /// Create a ascent in cache and optionally on the server.
  /// If the parameter [online] is null or false the ascent is added to the cache and uploaded later at the next sync.
  /// Otherwise it is added to the cache and to the server.
  Future<Ascent?> createAscentForSinglePitchRoute(Ascent createAscent, String singlePitchRouteId, {bool? online}) async {
    // add to cache
    Box ascentBox = Hive.box(Ascent.boxName);
    await ascentBox.put(createAscent.id, createAscent.toJson());
    // add ascent to creation queue for later sync
    // add singlePitchRouteId as well so we later know to which pitch to add it on the server
    Box createAscentBox = Hive.box(CreateAscent.boxName);
    Map<dynamic, dynamic> ascent = createAscent.toJson();
    ascent['ofPitch'] = false;
    ascent['parentId'] = singlePitchRouteId;
    await createAscentBox.put(createAscent.id, ascent);
    // add to ascentIds of single pitch route locally
    Box singlePitchRouteBox = Hive.box(SinglePitchRoute.boxName);
    Map singlePitchRouteMap = singlePitchRouteBox.get(singlePitchRouteId);
    SinglePitchRoute singlePitchRoute = SinglePitchRoute.fromCache(singlePitchRouteMap);
    singlePitchRoute.ascentIds.add(createAscent.id);
    await singlePitchRouteBox.put(singlePitchRoute.id, singlePitchRoute.toJson());
    if (online == null || !online) return createAscent;
    // try to upload and update cache if successful
    Map data = createAscent.toJson();
    Ascent? uploadedAscent = await uploadAscentForSinglePitchRoute(singlePitchRouteId, data);
    if (uploadedAscent == null) return createAscent;
    await ascentBox.delete(createAscent.id);
    await createAscentBox.delete(createAscent.id);
    await ascentBox.put(uploadedAscent.id, uploadedAscent.toJson());
    return uploadedAscent;
  }

  /// Edit an ascent in cache and optionally on the server.
  /// If the parameter [online] is null or false the ascent is edited only in the cache and later on the server at the next sync.
  /// Otherwise it is edited in cache and on the server immediately.
  Future<Ascent?> editAscent(UpdateAscent updateAscent, {bool? online}) async {
    // add to cache
    Box ascentBox = Hive.box(Ascent.boxName);
    Box updateAscentBox = Hive.box(UpdateAscent.boxName);
    Ascent oldAscent = Ascent.fromCache(ascentBox.get(updateAscent.id));
    Ascent tmpAscent = updateAscent.toAscent(oldAscent);
    await ascentBox.put(updateAscent.id, tmpAscent.toJson());
    await updateAscentBox.put(updateAscent.id, tmpAscent.toJson());
    if (online == null || !online) return tmpAscent;
    // try to upload and update cache if successful
    try {
      final Response response = await netWorkLocator.dio.put('$climbingApiHost/ascent/${updateAscent.id}', data: updateAscent.toJson());
      if (response.statusCode != 200) throw Exception('Failed to edit ascent');
      Ascent ascent = Ascent.fromJson(response.data);
      await ascentBox.put(updateAscent.id, updateAscent.toJson());
      await updateAscentBox.delete(updateAscent.id);
      return ascent;
    } catch (e) {
      ErrorService.handleConnectionErrors(e);
    }
    return null;
  }

  /// Delete an ascent its media in cache and optionally on the server.
  /// If the parameter [online] is null or false the data is deleted only from the cache and later from the server at the next sync.
  /// Otherwise it is deleted from cache and from the server immediately.
  Future<void> deleteAscentOfPitch(Ascent deleteAscent, String pitchId, {bool? online}) async {
    // delete ascent locally
    Box ascentBox = Hive.box(Ascent.boxName);
    await ascentBox.delete(deleteAscent.id);
    // add ascent to deletion queue for later sync
    // add pitchId as well so we later know from which pitch to remove it on the server
    Box deleteAscentBox = Hive.box(Ascent.deleteBoxName);
    Map<dynamic, dynamic> ascent = deleteAscent.toJson();
    ascent['ofPitch'] = true;
    ascent['parentId'] = pitchId;
    await deleteAscentBox.put(deleteAscent.id, ascent);
    // remove from create queue (if no sync since)
    Box createAscentBox = Hive.box(Ascent.createBoxName);
    await createAscentBox.delete(deleteAscent.id);
    // delete ascent id from pitch
    Box pitchBox = Hive.box(Pitch.boxName);
    Pitch pitch = Pitch.fromCache(pitchBox.get(pitchId));
    pitch.ascentIds.remove(deleteAscent.id);
    await pitchBox.put(pitch.id, pitch.toJson());
    // delete media of ascent locally (deleted automatically on the server when multi pitch route is deleted)
    Box mediaBox = Hive.box(Media.boxName);
    for (String id in deleteAscent.mediaIds) {
      await mediaBox.delete(id);
    }
    if (online == null || !online) return;
    try {
      // delete ascent
      final Response ascentResponse = await netWorkLocator.dio.delete('$climbingApiHost/ascent/${deleteAscent.id}/pitch/$pitchId');
      if (ascentResponse.statusCode != 200) throw Exception('Failed to delete ascent');
      await deleteAscentBox.delete(deleteAscent.id);
      MyNotifications.showPositiveNotification('Ascent was deleted: ${ascentResponse.data['name']}');
    } catch (e) {
      ErrorService.handleConnectionErrors(e);
      if (e is DioError) {
        // if the ascent can't be found on the server then we can safely remove it locally as well
        if (e.error == "Http status error [404]"){
          await deleteAscentBox.delete(deleteAscent.id);
        }
      }
    }
  }

  /// Delete a ascent its media in cache and optionally on the server.
  /// If the parameter [online] is null or false the data is deleted only from the cache and later from the server at the next sync.
  /// Otherwise it is deleted from cache and from the server immediately.
  Future<void> deleteAscentOfSinglePitchRoute(Ascent deleteAscent, String singlePitchRouteId, {bool? online}) async {
    // delete ascent locally
    Box ascentBox = Hive.box(Ascent.boxName);
    await ascentBox.delete(deleteAscent.id);
    // add ascent to deletion queue for later sync
    // add singlePitchRouteId as well so we later know from which single pitch route to remove it on the server
    Box deleteAscentBox = Hive.box(Ascent.deleteBoxName);
    Map<dynamic, dynamic> ascent = deleteAscent.toJson();
    ascent['ofPitch'] = false;
    ascent['parentId'] = singlePitchRouteId;
    await deleteAscentBox.put(deleteAscent.id, ascent);
    // remove from create queue (if no sync since)
    Box createAscentBox = Hive.box(Ascent.createBoxName);
    await createAscentBox.delete(deleteAscent.id);
    // delete ascent id from single pitch route
    Box singlePitchRouteBox = Hive.box(SinglePitchRoute.boxName);
    SinglePitchRoute singlePitchRoute = SinglePitchRoute.fromCache(singlePitchRouteBox.get(singlePitchRouteId));
    singlePitchRoute.ascentIds.remove(deleteAscent.id);
    await singlePitchRouteBox.put(singlePitchRoute.id, singlePitchRoute.toJson());
    // delete media of ascent locally (deleted automatically on the server when multi pitch route is deleted)
    Box mediaBox = Hive.box(Media.boxName);
    for (String id in deleteAscent.mediaIds) {
      await mediaBox.delete(id);
    }
    if (online == null || !online) return;
    try {
      // delete ascent
      final Response ascentResponse = await netWorkLocator.dio.delete('$climbingApiHost/ascent/${deleteAscent.id}/route/$singlePitchRouteId');
      if (ascentResponse.statusCode != 200) throw Exception('Failed to delete ascent');
      await deleteAscentBox.delete(deleteAscent.id);
      MyNotifications.showPositiveNotification('Ascent was deleted: ${ascentResponse.data['name']}');
    } catch (e) {
      ErrorService.handleConnectionErrors(e);
      if (e is DioError) {
        // if the ascent can't be found on the server then we can safely remove it locally as well
        if (e.error == "Http status error [404]"){
          await deleteAscentBox.delete(deleteAscent.id);
        }
      }
    }
  }

  /// Upload an ascent to the server.
  Future<Ascent?> uploadAscentForPitch(String pitchId, Map data) async {
    try {
      final Response response = await netWorkLocator.dio.post('$climbingApiHost/ascent/pitch/$pitchId', data: data);
      if (response.statusCode != 201) throw Exception('Failed to create ascent');
      MyNotifications.showPositiveNotification('Created new ascent: ${response.data['comment']}');
      return Ascent.fromJson(response.data);
    } catch (e) {
      if (e is DioError) {
        final response = e.response;
        if (response != null) {
          switch (response.statusCode) {
            case 409:
              MyNotifications.showNegativeNotification('This ascent already exists!');
              Box createAscentBox = Hive.box(CreateAscent.boxName);
              await createAscentBox.delete(data['_id']);
              break;
            default:
              throw Exception('Failed to create ascent');
          }
        }
      }
    }
    return null;
  }

  /// Upload an ascent to the server.
  Future<Ascent?> uploadAscentForSinglePitchRoute(String routeId, Map data) async {
    try {
      final Response response = await netWorkLocator.dio.post('$climbingApiHost/ascent/route/$routeId', data: data);
      if (response.statusCode != 201) throw Exception('Failed to create ascent');
      MyNotifications.showPositiveNotification('Created new ascent: ${response.data['comment']}');
      return Ascent.fromJson(response.data);
    } catch (e) {
      if (e is DioError) {
        final response = e.response;
        if (response != null) {
          switch (response.statusCode) {
            case 409:
              MyNotifications.showNegativeNotification('This ascent already exists!');
              Box createAscentBox = Hive.box(CreateAscent.boxName);
              await createAscentBox.delete(data['_id']);
              break;
            default:
              throw Exception('Failed to create ascent');
          }
        }
      }
    }
    return null;
  }
}
