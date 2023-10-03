import 'package:hive/hive.dart';

import '../components/common/my_notifications.dart';
import '../config/environment.dart';
import '../interfaces/ascent/create_ascent.dart';
import 'package:dio/dio.dart';

import '../data/network/dio_client.dart';
import '../data/sharedprefs/shared_preference_helper.dart';
import '../interfaces/ascent/ascent.dart';
import '../interfaces/ascent/update_ascent.dart';
import 'cache_service.dart';
import 'locator.dart';

class AscentService {
  final netWorkLocator = getIt.get<DioClient>();
  final sharedPrefLocator = getIt.get<SharedPreferenceHelper>();
  final String climbingApiHost = Environment().config.climbingApiHost;
  final String mediaApiHost = Environment().config.mediaApiHost;

  Future<Ascent?> getAscent(String ascentId, bool online) async {
    try {
      Box box = Hive.box('ascents');
      if (online) {
        final Response ascentIdUpdatedResponse = await netWorkLocator.dio.get('$climbingApiHost/ascentUpdated/$ascentId');
        if (ascentIdUpdatedResponse.statusCode != 200) throw Exception("Error during request of ascent id updated");
        String id = ascentIdUpdatedResponse.data['_id'];
        String serverUpdated = ascentIdUpdatedResponse.data['updated'];
        if (!box.containsKey(id) || CacheService.isStale(box.get(id), serverUpdated)) {
          final Response missingMultiPitchRouteResponse = await netWorkLocator.dio.post('$climbingApiHost/ascent/$ascentId');
          if (missingMultiPitchRouteResponse.statusCode != 200) throw Exception("Error during request of missing ascent");
          return Ascent.fromJson(missingMultiPitchRouteResponse.data);
        } else {
          return Ascent.fromCache(box.get(id));
        }
      }
      return Ascent.fromCache(box.get(ascentId));
    } catch (e) {
      if (e is DioError) {
        if (e.error.toString().contains("OS Error: Connection refused, errno = 111")){
          MyNotifications.showNegativeNotification('Couldn\'t connect to API');
        }
      }
      print(e);
    }
    return null;
  }

  Future<List<Ascent>> getAscentsOfIds(List<String> ascentIds, bool online) async {
    try {
      if(online){
        final Response ascentIdsUpdatedResponse = await netWorkLocator.dio.post('$climbingApiHost/ascentUpdated/ids', data: ascentIds);
        if (ascentIdsUpdatedResponse.statusCode != 200) {
          throw Exception("Error during request of ascent ids updated");
        }
        List<Ascent> ascents = [];
        List<String> missingAscentIds = [];
        Box box = Hive.box('ascents');
        ascentIdsUpdatedResponse.data.forEach((idWithDatetime) {
          String id = idWithDatetime['_id'];
          String serverUpdated = idWithDatetime['updated'];
          if (!box.containsKey(id) || CacheService.isStale(box.get(id), serverUpdated)) {
            missingAscentIds.add(id);
          } else {
            ascents.add(Ascent.fromCache(box.get(id)));
          }
        });
        if (missingAscentIds.isEmpty){
          return ascents;
        }
        final Response missingAscentsResponse = await netWorkLocator.dio.post('$climbingApiHost/ascent/ids', data: missingAscentIds);
        if (missingAscentsResponse.statusCode != 200) {
          throw Exception("Error during request of missing ascents");
        }
        missingAscentsResponse.data.forEach((s) {
          Ascent ascent = Ascent.fromJson(s);
          if (!box.containsKey(ascent.id)) {
            box.put(ascent.id, ascent.toJson());
          }
          ascents.add(ascent);
        });
        return ascents;
      } else {
        // offline
        List<Ascent> ascents = CacheService.getTsFromCache<Ascent>('ascents', Ascent.fromCache);
        return ascents.where((element) => ascentIds.contains(element.id)).toList();
      }
    } catch (e) {
      if (e is DioError) {
        if (e.error.toString().contains("OS Error: Connection refused, errno = 111")){
          MyNotifications.showNegativeNotification('Couldn\'t connect to API');
        }
      }
    }
    return [];
  }

  Future<List<Ascent>> getAscents(bool online) async {
    try {
      if(online){
        final Response ascentIdsResponse = await netWorkLocator.dio.get('$climbingApiHost/ascentUpdated');
        if (ascentIdsResponse.statusCode != 200) {
          throw Exception("Error during request of ascent ids");
        }
        List<Ascent> ascents = [];
        List<String> missingAscentIds = [];
        Box box = Hive.box('ascents');
        ascentIdsResponse.data.forEach((idWithDatetime) {
          String id = idWithDatetime['_id'];
          String serverUpdated = idWithDatetime['updated'];
          if (!box.containsKey(id) || CacheService.isStale(box.get(id), serverUpdated)) {
            missingAscentIds.add(id);
          } else {
            ascents.add(Ascent.fromCache(box.get(id)));
          }
        });
        if (missingAscentIds.isEmpty){
          return ascents;
        }
        final Response missingAscentsResponse = await netWorkLocator.dio.post('$climbingApiHost/ascent/ids', data: missingAscentIds);
        if (missingAscentsResponse.statusCode != 200) {
          throw Exception("Error during request of missing ascents");
        }
        missingAscentsResponse.data.forEach((s) {
          Ascent ascent = Ascent.fromJson(s);
          if (!box.containsKey(ascent.id)) {
            box.put(ascent.id, ascent.toJson());
          }
          ascents.add(ascent);
        });
        return ascents;
      } else {
        // offline
        return CacheService.getTsFromCache<Ascent>('ascents', Ascent.fromCache);
      }
    } catch (e) {
      if (e is DioError) {
        if (e.error.toString().contains("OS Error: Connection refused, errno = 111")){
          MyNotifications.showNegativeNotification('Couldn\'t connect to API');
        }
      }
    }
    return [];
  }

  Future<Ascent?> createAscent(String pitchId, CreateAscent createAscent, bool hasConnection) async {
    CreateAscent ascent = CreateAscent(
      comment: (createAscent.comment != null) ? createAscent.comment! : "",
      date: createAscent.date,
      style: createAscent.style,
      type: createAscent.type,
    );
    if (hasConnection) {
      var data = ascent.toJson();
      return uploadAscent(pitchId, data);
    } else {
      // save to cache
      Box box = Hive.box('upload_later_ascents');
      Map ascentJson = ascent.toJson();
      box.put(ascentJson.hashCode, ascentJson);
    }
    return null;
  }

  Future<Ascent?> createAscentForSinglePitchRoute(String routeId, CreateAscent createAscent, bool hasConnection) async {
    CreateAscent ascent = CreateAscent(
      comment: (createAscent.comment != null) ? createAscent.comment! : "",
      date: createAscent.date,
      style: createAscent.style,
      type: createAscent.type,
    );
    if (hasConnection) {
      var data = ascent.toJson();
      return uploadAscentForSinglePitchRoute(routeId, data);
    } else {
      // save to cache
      Box box = Hive.box('upload_later_ascents');
      Map ascentJson = ascent.toJson();
      box.put(ascentJson.hashCode, ascentJson);
    }
    return null;
  }

  Future<Ascent?> editAscent(UpdateAscent ascent) async {
    try {
      final Response response = await netWorkLocator.dio
          .put('$climbingApiHost/ascent/${ascent.id}', data: ascent.toJson());
      if (response.statusCode == 200) {
        // TODO deleteAscentFromEditQueue(ascent.hashCode);
        return Ascent.fromJson(response.data);
      } else {
        throw Exception('Failed to edit ascent');
      }
    } catch (e) {
      if (e is DioError) {
        if (e.error.toString().contains('OS Error: No address associated with hostname, errno = 7')){
          // this means we are offline so queue this ascent and edit later
          Box box = Hive.box('edit_later_ascents');
          Map ascentJson = ascent.toJson();
          box.put(ascentJson.hashCode, ascentJson);
        }
      }
    } finally {
      // TODO editAscentFromCache(ascent);
    }
    return null;
  }

  Future<void> deleteAscent(Ascent ascent, String pitchId, bool isMultiPitch) async {
    if (isMultiPitch){
      try {
        for (var id in ascent.mediaIds) {
          final Response mediaResponse =
          await netWorkLocator.dio.delete('$mediaApiHost/media/$id');
          if (mediaResponse.statusCode != 204) {
            throw Exception('Failed to delete medium');
          }
        }
        final Response ascentResponse =
        await netWorkLocator.dio.delete('$climbingApiHost/ascent/${ascent.id}/pitch/$pitchId');
        if (ascentResponse.statusCode != 200) {
          MyNotifications.showNegativeNotification('Failed to delete ascent: ${ascent.comment}');
        }
        MyNotifications.showPositiveNotification('Ascent was deleted: ${ascentResponse.data['comment']}');
        // TODO deleteAscentFromDeleteQueue(ascent.toJson().hashCode);
        return ascentResponse.data;
      } catch (e) {
        if (e is DioError) {
          if (e.error.toString().contains('OS Error: No address associated with hostname, errno = 7')){
            // this means we are offline so queue this ascent and delete later
            Box box = Hive.box('delete_later_ascents');
            Map ascentJson = ascent.toJson();
            box.put(ascentJson.hashCode, ascentJson);
          }
        }
      } finally {
        // TODO deleteAscentFromCache(ascent.id);
      }
    } else {
      try {
        for (var id in ascent.mediaIds) {
          final Response mediaResponse =
          await netWorkLocator.dio.delete('$mediaApiHost/media/$id');
          if (mediaResponse.statusCode != 204) {
            throw Exception('Failed to delete medium');
          }
        }

        final Response ascentResponse = await netWorkLocator.dio.delete('$climbingApiHost/ascent/${ascent.id}/route/$pitchId');
        if (ascentResponse.statusCode != 200) {
          MyNotifications.showNegativeNotification('Failed to delete ascent: ${ascent.comment}');
        }
        MyNotifications.showPositiveNotification('Ascent was deleted: ${ascentResponse.data['comment']}');
        // TODO deleteAscentFromDeleteQueue(ascent.toJson().hashCode);
        return ascentResponse.data;
      } catch (e) {
        if (e is DioError) {
          if (e.error.toString().contains('OS Error: No address associated with hostname, errno = 7')){
            // this means we are offline so queue this ascent and delete later
            Box box = Hive.box('delete_later_ascents');
            Map ascentJson = ascent.toJson();
            box.put(ascentJson.hashCode, ascentJson);
          }
        }
      } finally {
        // TODO deleteAscentFromCache(ascent.id);
      }
    }
  }

  Future<Ascent?> uploadAscent(String pitchId, Map data) async {
    try {
      final Response response = await netWorkLocator.dio
          .post('$climbingApiHost/ascent/pitch/$pitchId', data: data);
      if (response.statusCode == 201) {
        MyNotifications.showPositiveNotification('Created new ascent: ${response.data['comment']}');
        return Ascent.fromJson(response.data);
      } else {
        throw Exception('Failed to create ascent');
      }
    } catch (e) {
      if (e is DioError) {
        final response = e.response;
        if (response != null) {
          switch (response.statusCode) {
            case 409:
              MyNotifications.showNegativeNotification('This ascent already exists!');
              break;
            default:
              throw Exception('Failed to create ascent');
          }
        }
      }
    } finally {
      // TODO deleteAscentFromUploadQueue(data.hashCode);
    }
    return null;
  }

  Future<Ascent?> uploadAscentForSinglePitchRoute(String routeId, Map data) async {
    try {
      final Response response = await netWorkLocator.dio
          .post('$climbingApiHost/ascent/route/$routeId', data: data);
      if (response.statusCode == 201) {
        MyNotifications.showPositiveNotification('Created new ascent: ${response.data['comment']}');
        return Ascent.fromJson(response.data);
      } else {
        throw Exception('Failed to create ascent');
      }
    } catch (e) {
      if (e is DioError) {
        final response = e.response;
        if (response != null) {
          switch (response.statusCode) {
            case 409:
              MyNotifications.showNegativeNotification('This ascent already exists!');
              break;
            default:
              throw Exception('Failed to create ascent');
          }
        }
      }
    } finally {
      // TODO deleteAscentFromUploadQueue(data.hashCode);
    }
    return null;
  }
}
