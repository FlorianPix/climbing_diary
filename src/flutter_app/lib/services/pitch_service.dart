import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:overlay_support/overlay_support.dart';

import '../config/environment.dart';
import '../interfaces/pitch/create_pitch.dart';
import 'package:dio/dio.dart';

import '../data/network/dio_client.dart';
import '../data/sharedprefs/shared_preference_helper.dart';
import '../interfaces/pitch/pitch.dart';
import '../interfaces/pitch/update_pitch.dart';
import 'cache.dart';
import 'locator.dart';

class PitchService {
  final netWorkLocator = getIt.get<DioClient>();
  final sharedPrefLocator = getIt.get<SharedPreferenceHelper>();
  final String climbingApiHost = Environment().config.climbingApiHost;
  final String mediaApiHost = Environment().config.mediaApiHost;

  Future<List<Pitch>> getPitches() async {
    try {
      final Response response = await netWorkLocator.dio.get('$climbingApiHost/pitch');

      if (response.statusCode == 200) {
        // If the server did return a 200 OK response, then parse the JSON.
        List<Pitch> pitches = [];
        // save to cache
        Box box = Hive.box('pitches');
        response.data.forEach((s) {
          Pitch pitch = Pitch.fromJson(s);
          if (!box.containsKey(pitch.id)) {
            box.put(pitch.id, pitch.toJson());
          }
          pitches.add(pitch);
        });
        return pitches;
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

  Future<Pitch> getPitch(String pitchId) async {
    final Response response =
        await netWorkLocator.dio.get('$climbingApiHost/pitch/$pitchId');
    if (response.statusCode == 200) {
      return Pitch.fromJson(response.data);
    } else {
      throw Exception('Failed to load pitch');
    }
  }

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
      Box box = Hive.box('upload_later_pitchs');
      Map pitchJson = pitch.toJson();
      box.put(pitchJson.hashCode, pitchJson);
    }
    return null;
  }

  Future<Pitch?> editPitch(UpdatePitch pitch) async {
    try {
      final Response response = await netWorkLocator.dio
          .put('$climbingApiHost/pitch/${pitch.id}', data: pitch.toJson());
      if (response.statusCode == 200) {
        // TODO deletePitchFromEditQueue(pitch.hashCode);
        return Pitch.fromJson(response.data);
      } else {
        throw Exception('Failed to edit pitch');
      }
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
        if (mediaResponse.statusCode != 204) {
          throw Exception('Failed to delete medium');
        }
      }

      final Response pitchResponse =
      await netWorkLocator.dio.delete('$climbingApiHost/route/$routeId/pitch/${pitch.id}');
      if (pitchResponse.statusCode != 204) {
        throw Exception('Failed to delete pitch');
      }
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
          .post('$climbingApiHost/route/$routeId', data: data);
      if (response.statusCode == 201) {
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
              showSimpleNotification(
                const Text('This pitch already exists!'),
                background: Colors.red,
              );
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
