import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:overlay_support/overlay_support.dart';

import '../config/environment.dart';
import '../interfaces/ascent/create_ascent.dart';
import 'package:dio/dio.dart';

import '../data/network/dio_client.dart';
import '../data/sharedprefs/shared_preference_helper.dart';
import '../interfaces/ascent/ascent.dart';
import '../interfaces/ascent/update_ascent.dart';
import 'cache.dart';
import 'locator.dart';

class AscentService {
  final netWorkLocator = getIt.get<DioClient>();
  final sharedPrefLocator = getIt.get<SharedPreferenceHelper>();
  final String climbingApiHost = Environment().config.climbingApiHost;
  final String mediaApiHost = Environment().config.mediaApiHost;

  Future<List<Ascent>> getAscents() async {
    try {
      final Response response = await netWorkLocator.dio.get('$climbingApiHost/ascent');

      if (response.statusCode == 200) {
        // If the server did return a 200 OK response, then parse the JSON.
        List<Ascent> ascents = [];
        // save to cache
        Box box = Hive.box('ascents');
        response.data.forEach((s) {
          Ascent ascent = Ascent.fromJson(s);
          if (!box.containsKey(ascent.id)) {
            box.put(ascent.id, ascent.toJson());
          }
          ascents.add(ascent);
        });
        return ascents;
      }
    } catch (e) {
      if (e is DioError) {
        if (e.error.toString().contains("OS Error: Connection refused, errno = 111")){
          showSimpleNotification(
            const Text('Couldn\'t connect to API'),
            background: Colors.red,
          );
        }
      }
    }
    return [];
  }

  Future<Ascent> getAscent(String ascentId) async {
    final Response response =
        await netWorkLocator.dio.get('$climbingApiHost/ascent/$ascentId');
    if (response.statusCode == 200) {
      return Ascent.fromJson(response.data);
    } else {
      throw Exception('Failed to load ascent');
    }
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
        if (ascentResponse.statusCode != 204) {
          throw Exception('Failed to delete ascent');
        }
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
        if (ascentResponse.statusCode != 204) {
          throw Exception('Failed to delete ascent');
        }
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
              showSimpleNotification(
                const Text('This ascent already exists!'),
                background: Colors.red,
              );
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
              showSimpleNotification(
                const Text('This ascent already exists!'),
                background: Colors.red,
              );
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
