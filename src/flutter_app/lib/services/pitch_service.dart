import 'package:hive/hive.dart';

import 'package:climbing_diary/components/common/my_notifications.dart';
import '../config/environment.dart';
import '../interfaces/pitch/create_pitch.dart';
import 'package:dio/dio.dart';

import '../data/network/dio_client.dart';
import '../data/sharedprefs/shared_preference_helper.dart';
import '../interfaces/pitch/pitch.dart';
import '../interfaces/pitch/update_pitch.dart';
import 'cache_service.dart';
import 'locator.dart';

class PitchService {
  final netWorkLocator = getIt.get<DioClient>();
  final sharedPrefLocator = getIt.get<SharedPreferenceHelper>();
  final String climbingApiHost = Environment().config.climbingApiHost;
  final String mediaApiHost = Environment().config.mediaApiHost;

  Future<Pitch?> createPitch(CreatePitch createPitch, String routeId, bool hasConnection) async {
    CreatePitch pitch = CreatePitch(
      comment: (createPitch.comment != null) ? createPitch.comment! : "",
      grade: createPitch.grade,
      length: createPitch.length,
      name: createPitch.name,
      num: createPitch.num,
      rating: createPitch.rating,
    );
    if (hasConnection) {
      var data = pitch.toJson();
      return uploadPitch(routeId, data);
    } else {
      // save to cache
      Box box = Hive.box('upload_later_pitches');
      Map pitchJson = pitch.toJson();
      box.put(pitchJson.hashCode, pitchJson);
    }
    return null;
  }

  Future<Pitch?> getPitch(String pitchId, bool online) async {
    try {
      Box box = Hive.box('pitches');
      if (online) {
        final Response pitchIdUpdatedResponse = await netWorkLocator.dio.get('$climbingApiHost/pitchUpdated/$pitchId');
        if (pitchIdUpdatedResponse.statusCode != 200) throw Exception("Error during request of pitch id updated");
        String id = pitchIdUpdatedResponse.data['_id'];
        String serverUpdated = pitchIdUpdatedResponse.data['updated'];
        if (!box.containsKey(id) || CacheService.isStale(box.get(id), serverUpdated)) {
          final Response missingMultiPitchRouteResponse = await netWorkLocator.dio.post('$climbingApiHost/pitch/$pitchId');
          if (missingMultiPitchRouteResponse.statusCode != 200) throw Exception("Error during request of missing pitch");
          return Pitch.fromJson(missingMultiPitchRouteResponse.data);
        } else {
          return Pitch.fromCache(box.get(id));
        }
      }
      return Pitch.fromCache(box.get(pitchId));
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

  Future<List<Pitch>> getPitchesOfIds(List<String> pitchIds, bool online) async {
    try {
      if(online){
        final Response pitchIdsUpdatedResponse = await netWorkLocator.dio.post('$climbingApiHost/pitchUpdated/ids', data: pitchIds);
        if (pitchIdsUpdatedResponse.statusCode != 200) throw Exception("Error during request of pitch ids updated");
        List<Pitch> pitches = [];
        List<String> missingPitchIds = [];
        Box box = Hive.box('pitches');
        pitchIdsUpdatedResponse.data.forEach((idWithDatetime) {
          String id = idWithDatetime['_id'];
          String serverUpdated = idWithDatetime['updated'];
          if (!box.containsKey(id) || CacheService.isStale(box.get(id), serverUpdated)) {
            missingPitchIds.add(id);
          } else {
            pitches.add(Pitch.fromCache(box.get(id)));
          }
        });
        if (missingPitchIds.isEmpty){
          return pitches;
        }
        final Response missingPitchesResponse = await netWorkLocator.dio.post('$climbingApiHost/pitch/ids', data: missingPitchIds);
        if (missingPitchesResponse.statusCode != 200) throw Exception("Error during request of missing pitches");
        missingPitchesResponse.data.forEach((s) {
          Pitch pitch = Pitch.fromJson(s);
          if (!box.containsKey(pitch.id)) {
            box.put(pitch.id, pitch.toJson());
          }
          pitches.add(pitch);
        });
        return pitches;
      } else {
        // offline
        return CacheService.getTsFromCache<Pitch>('pitches', Pitch.fromCache);
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

  Future<List<Pitch>> getPitches(bool online) async {
    try {
      if(online){
        final Response pitchIdsResponse = await netWorkLocator.dio.get('$climbingApiHost/pitchUpdated');
        if (pitchIdsResponse.statusCode != 200) throw Exception("Error during request of pitch ids");
        List<Pitch> pitches = [];
        List<String> missingPitchIds = [];
        Box box = Hive.box('pitches');
        pitchIdsResponse.data.forEach((idWithDatetime) {
          String id = idWithDatetime['_id'];
          String serverUpdated = idWithDatetime['updated'];
          if (!box.containsKey(id) || CacheService.isStale(box.get(id), serverUpdated)) {
            missingPitchIds.add(id);
          } else {
            pitches.add(Pitch.fromCache(box.get(id)));
          }
        });
        if (missingPitchIds.isEmpty){
          return pitches;
        }
        final Response missingPitchesResponse = await netWorkLocator.dio.post('$climbingApiHost/pitch/ids', data: missingPitchIds);
        if (missingPitchesResponse.statusCode != 200) throw Exception("Error during request of missing pitches");
        missingPitchesResponse.data.forEach((s) {
          Pitch pitch = Pitch.fromJson(s);
          if (!box.containsKey(pitch.id)) box.put(pitch.id, pitch.toJson());
          pitches.add(pitch);
        });
        return pitches;
      } else {
        // offline
        return CacheService.getTsFromCache<Pitch>('pitches', Pitch.fromCache);
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

  Future<List<Pitch>> getPitchesByName(String name, bool online) async {
    List<Pitch> pitches = await getPitches(online);
    if (name.isEmpty) return pitches;
    return pitches.where((pitch) => pitch.name.contains(name)).toList();
  }

  Future<Pitch?> editPitch(UpdatePitch pitch) async {
    try {
      final Response response = await netWorkLocator.dio
          .put('$climbingApiHost/pitch/${pitch.id}', data: pitch.toJson());
      if (response.statusCode != 200) throw Exception('Failed to edit pitch');
      // TODO deletePitchFromEditQueue(pitch.hashCode);
      return Pitch.fromJson(response.data);
    } catch (e) {
      if (e is DioError) {
        if (e.error.toString().contains('OS Error: No address associated with hostname, errno = 7')){
          // this means we are offline so queue this pitch and edit later
          Box box = Hive.box('edit_later_pitchs');
          Map pitchJson = pitch.toJson();
          box.put(pitchJson.hashCode, pitchJson);
        }
      }
    } finally {
      // TODO editPitchFromCache(pitch);
    }
    return null;
  }

  Future<void> deletePitch(String routeId, Pitch pitch) async {
    try {
      for (var id in pitch.mediaIds) {
        final Response mediaResponse =
        await netWorkLocator.dio.delete('$mediaApiHost/media/$id');
        if (mediaResponse.statusCode != 204) throw Exception('Failed to delete medium');
      }

      final Response pitchResponse =
      await netWorkLocator.dio.delete('$climbingApiHost/pitch/${pitch.id}/route/$routeId');
      if (pitchResponse.statusCode != 200) {
        MyNotifications.showNegativeNotification('Failed to delete pitch: ${pitch.name}');
      }
      MyNotifications.showPositiveNotification('Pitch was deleted: ${pitchResponse.data['name']}');
      // TODO deletePitchFromDeleteQueue(pitch.toJson().hashCode);
      return pitchResponse.data;
    } catch (e) {
      if (e is DioError) {
        if (e.error.toString().contains('OS Error: No address associated with hostname, errno = 7')){
          // this means we are offline so queue this pitch and delete later
          Box box = Hive.box('delete_later_pitchs');
          Map pitchJson = pitch.toJson();
          box.put(pitchJson.hashCode, pitchJson);
        }
      }
    } finally {
      // TODO deletePitchFromCache(pitch.id);
    }
  }

  Future<Pitch?> uploadPitch(String routeId, Map data) async {
    try {
      final Response response = await netWorkLocator.dio
          .post('$climbingApiHost/pitch/route/$routeId', data: data);
      if (response.statusCode == 201) {
        MyNotifications.showPositiveNotification('Created new pitch: ${response.data['name']}');
        return Pitch.fromJson(response.data);
      } else {
        throw Exception('Failed to create pitch $response');
      }
    } catch (e) {
      if (e is DioError) {
        final response = e.response;
        if (response != null) {
          switch (response.statusCode) {
            case 409:
              MyNotifications.showNegativeNotification('This pitch already exists!');
              break;
            default:
              throw Exception('Failed to create pitch $response');
          }
        }
      }
    } finally {
      // TODO deletePitchFromUploadQueue(data.hashCode);
    }
    return null;
  }
}
