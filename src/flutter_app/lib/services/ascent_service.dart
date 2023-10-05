import 'package:climbing_diary/interfaces/media/media.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
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
      // request when the trip was updated the last time
      final Response ascentIdUpdatedResponse = await netWorkLocator.dio.get('$climbingApiHost/ascentUpdated/$ascentId');
      if (ascentIdUpdatedResponse.statusCode != 200) throw Exception("Error during request of ascent id updated");
      String serverUpdated = ascentIdUpdatedResponse.data['updated'];
      // request the ascent from the server if it was updated more recently than the one in the cache
      if (!box.containsKey(ascentId) || CacheService.isStale(box.get(ascentId), serverUpdated)) {
        final Response missingAscentResponse = await netWorkLocator.dio.post('$climbingApiHost/ascent/$ascentId');
        if (missingAscentResponse.statusCode != 200) throw Exception("Error during request of missing ascent");
        return Ascent.fromJson(missingAscentResponse.data);
      } else {
        return Ascent.fromCache(box.get(ascentId));
      }
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
      // request when the ascents were updated the last time
      final Response ascentIdsUpdatedResponse = await netWorkLocator.dio.post('$climbingApiHost/ascentUpdated/ids', data: ascentIds);
      if (ascentIdsUpdatedResponse.statusCode != 200) throw Exception("Error during request of ascent ids updated");
      // find missing or stale (updated more recently on the server than in the cache) ascents
      List<Ascent> ascents = [];
      List<String> missingAscentIds = [];
      Box box = Hive.box(Ascent.boxName);
      ascentIdsUpdatedResponse.data.forEach((idWithDatetime) {
        String id = idWithDatetime['_id'];
        String serverUpdated = idWithDatetime['updated'];
        if (!box.containsKey(id) || CacheService.isStale(box.get(id), serverUpdated)) {
          missingAscentIds.add(id);
        } else {
          ascents.add(Ascent.fromCache(box.get(id)));
        }
      });
      if (missingAscentIds.isEmpty) return ascents;
      // request missing or stale ascents from the server
      final Response missingAscentsResponse = await netWorkLocator.dio.post('$climbingApiHost/ascent/ids', data: missingAscentIds);
      if (missingAscentsResponse.statusCode != 200) throw Exception("Error during request of missing ascents");
      Future.forEach(missingAscentsResponse.data, (dynamic s) async {
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
      // request when the ascents were updated the last time
      final Response ascentIdsResponse = await netWorkLocator.dio.get('$climbingApiHost/ascentUpdated');
      if (ascentIdsResponse.statusCode != 200) throw Exception("Error during request of ascent ids");
      // find missing or stale (updated more recently on the server than in the cache) ascents
      List<Ascent> ascents = [];
      List<String> missingAscentIds = [];
      Box box = Hive.box(Ascent.boxName);
      ascentIdsResponse.data.forEach((idWithDatetime) {
        String id = idWithDatetime['_id'];
        String serverUpdated = idWithDatetime['updated'];
        if (!box.containsKey(id) || CacheService.isStale(box.get(id), serverUpdated)) {
          missingAscentIds.add(id);
        } else {
          ascents.add(Ascent.fromCache(box.get(id)));
        }
      });
      if (missingAscentIds.isEmpty) return ascents;
      // request missing or stale ascents from the server
      final Response missingAscentsResponse = await netWorkLocator.dio.post('$climbingApiHost/ascent/ids', data: missingAscentIds);
      if (missingAscentsResponse.statusCode != 200) throw Exception("Error during request of missing ascents");
      Future.forEach(missingAscentsResponse.data, (dynamic s) async {
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
  Future<Ascent?> createAscentForPitch(String pitchId, CreateAscent createAscent, {bool? online}) async {
    CreateAscent ascent = CreateAscent(
      comment: (createAscent.comment != null) ? createAscent.comment! : "",
      date: createAscent.date,
      style: createAscent.style,
      type: createAscent.type,
    );
    // add to cache
    Box ascentBox = Hive.box(Ascent.boxName);
    Box createAscentBox = Hive.box(CreateAscent.boxName);
    Ascent tmpAscent = ascent.toAscent();
    await ascentBox.put(ascent.hashCode, tmpAscent.toJson());
    await createAscentBox.put(ascent.hashCode, ascent.toJson());
    if (online == null || !online) return tmpAscent;
    // try to upload and update cache if successful
    Map data = ascent.toJson();
    Ascent? uploadedAscent = await uploadAscentForPitch(pitchId, data);
    if (uploadedAscent == null) return tmpAscent;
    await ascentBox.delete(ascent.hashCode);
    await createAscentBox.delete(ascent.hashCode);
    await ascentBox.put(uploadedAscent.id, uploadedAscent.toJson());
    return uploadedAscent;
  }

  /// Create a ascent in cache and optionally on the server.
  /// If the parameter [online] is null or false the ascent is added to the cache and uploaded later at the next sync.
  /// Otherwise it is added to the cache and to the server.
  Future<Ascent?> createAscentForSinglePitchRoute(String routeId, CreateAscent createAscent, {bool? online}) async {
    CreateAscent ascent = CreateAscent(
      comment: (createAscent.comment != null) ? createAscent.comment! : "",
      date: createAscent.date,
      style: createAscent.style,
      type: createAscent.type,
    );
    // add to cache
    Box ascentBox = Hive.box(Ascent.boxName);
    Box createAscentBox = Hive.box(CreateAscent.boxName);
    Ascent tmpAscent = ascent.toAscent();
    await ascentBox.put(ascent.hashCode, tmpAscent.toJson());
    await createAscentBox.put(ascent.hashCode, ascent.toJson());
    if (online == null || !online) return tmpAscent;
    // try to upload and update cache if successful
    Map data = ascent.toJson();
    Ascent? uploadedAscent = await uploadAscentForSinglePitchRoute(routeId, data);
    if (uploadedAscent == null) return tmpAscent;
    await ascentBox.delete(ascent.hashCode);
    await createAscentBox.delete(ascent.hashCode);
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
    await updateAscentBox.put(updateAscent.id, updateAscent.toJson());
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
  Future<void> deleteAscentOfPitch(String pitchId, Ascent ascent, {bool? online}) async {
    Box ascentBox = Hive.box(Ascent.boxName);
    Box deleteAscentBox = Hive.box(Ascent.deleteBoxName);
    await ascentBox.delete(ascent.id);
    await deleteAscentBox.put(ascent.id, ascent.toJson());
    // TODO delete media from cache
    if (online == null || !online) return;
    try {
      // delete media
      for (var id in ascent.mediaIds) {
        final Response mediaResponse = await netWorkLocator.dio.delete('$mediaApiHost/media/$id');
        if (mediaResponse.statusCode != 204) throw Exception('Failed to delete medium');
      }
      // delete ascent
      final Response ascentResponse = await netWorkLocator.dio.delete('$climbingApiHost/ascent/${ascent.id}');
      if (ascentResponse.statusCode != 200) throw Exception('Failed to delete ascent');
      await deleteAscentBox.delete(ascent.id);
      MyNotifications.showPositiveNotification('Ascent was deleted: ${ascentResponse.data['name']}');
    } catch (e) {
      ErrorService.handleConnectionErrors(e);
    }
  }

  /// Delete a ascent its media in cache and optionally on the server.
  /// If the parameter [online] is null or false the data is deleted only from the cache and later from the server at the next sync.
  /// Otherwise it is deleted from cache and from the server immediately.
  Future<void> deleteAscentOfSinglePitchRoute(String pitchId, Ascent ascent, {bool? online}) async {
    Box ascentBox = Hive.box(Ascent.boxName);
    Box deleteAscentBox = Hive.box(Ascent.deleteBoxName);
    Box mediaBox = Hive.box(Media.boxName);
    await ascentBox.delete(ascent.id);
    await deleteAscentBox.put(ascent.id, ascent.toJson());
    for (String id in ascent.mediaIds) {
      await mediaBox.delete(id);
    }
    if (online == null || !online) return;
    try {
      // delete media
      for (String id in ascent.mediaIds) {
        final Response mediaResponse = await netWorkLocator.dio.delete('$mediaApiHost/media/$id');
        if (mediaResponse.statusCode != 204) throw Exception('Failed to delete medium');
      }
      // delete ascent
      final Response ascentResponse = await netWorkLocator.dio.delete('$climbingApiHost/ascent/${ascent.id}');
      if (ascentResponse.statusCode != 200) throw Exception('Failed to delete ascent');
      await deleteAscentBox.delete(ascent.id);
      MyNotifications.showPositiveNotification('Ascent was deleted: ${ascentResponse.data['name']}');
    } catch (e) {
      ErrorService.handleConnectionErrors(e);
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
      ErrorService.handleCreationErrors(e, 'ascent');
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
      ErrorService.handleCreationErrors(e, 'spot');
    }
    return null;
  }
}
