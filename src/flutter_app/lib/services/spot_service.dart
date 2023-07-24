import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:overlay_support/overlay_support.dart';

import '../config/environment.dart';
import '../interfaces/ascent/ascent.dart';
import '../interfaces/multi_pitch_route/multi_pitch_route.dart';
import '../interfaces/pitch/pitch.dart';
import '../interfaces/single_pitch_route/single_pitch_route.dart';
import '../interfaces/spot/create_spot.dart';
import 'package:dio/dio.dart';

import '../data/network/dio_client.dart';
import '../data/sharedprefs/shared_preference_helper.dart';
import '../interfaces/spot/spot.dart';
import '../interfaces/spot/update_spot.dart';
import 'cache.dart';
import 'locator.dart';

class SpotService {
  final netWorkLocator = getIt.get<DioClient>();
  final sharedPrefLocator = getIt.get<SharedPreferenceHelper>();
  final String climbingApiHost = Environment().config.climbingApiHost;
  final String mediaApiHost = Environment().config.mediaApiHost;

  Future<List<Spot>> getSpots() async {
    try {
      final Response response = await netWorkLocator.dio.get('$climbingApiHost/spot');

      if (response.statusCode == 200) {
        // If the server did return a 200 OK response, then parse the JSON.
        List<Spot> spots = [];
        // save to cache
        Box box = Hive.box('spots');
        response.data.forEach((s) {
          Spot spot = Spot.fromJson(s);
          if (!box.containsKey(spot.id)) {
            box.put(spot.id, spot.toJson());
          }
          spots.add(spot);
        });
        return spots;
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

  Future<List<Spot>> getSpotsByName(String name) async {
    try {
      final Response response = await netWorkLocator.dio.get('$climbingApiHost/spot');

      if (response.statusCode == 200) {
        // If the server did return a 200 OK response, then parse the JSON.
        List<Spot> spots = [];
        response.data.forEach((s) {
          Spot spot = Spot.fromJson(s);
          if (spot.name.contains(name)) {
            spots.add(spot);
          }
        });
        return spots;
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

  Future<Spot?> getSpot(String spotId) async {
    final Response response =
        await netWorkLocator.dio.get('$climbingApiHost/spot/$spotId');
    if (response.statusCode == 200) {
      return Spot.fromJson(response.data);
    } else {
      return null;
    }
  }

  Future<Spot?> getSpotIfWithinDateRange(String spotId, DateTime startDate, DateTime endDate) async {
    final Response spotResponse =
    await netWorkLocator.dio.get('$climbingApiHost/spot/$spotId');
    if (spotResponse.statusCode == 200) {
      Spot spot = Spot.fromJson(spotResponse.data);
      for (String routeId in spot.multiPitchRouteIds){
        final Response multiPitchResponse = await netWorkLocator.dio.get('$climbingApiHost/multi_pitch_route/$routeId');
        if (multiPitchResponse.statusCode == 200) {
          MultiPitchRoute multiPitchRoute = MultiPitchRoute.fromJson(multiPitchResponse.data);
          for (String pitchId in multiPitchRoute.pitchIds){
            final Response pitchResponse = await netWorkLocator.dio.get('$climbingApiHost/pitch/$pitchId');
            Pitch pitch = Pitch.fromJson(pitchResponse.data);
            for (String ascentId in pitch.ascentIds){
              final Response ascentResponse = await netWorkLocator.dio.get('$climbingApiHost/ascent/$ascentId');
              Ascent ascent = Ascent.fromJson(ascentResponse.data);
              DateTime dateOfAscent = DateTime.parse(ascent.date);
              if ((dateOfAscent.isAfter(startDate) && dateOfAscent.isBefore(endDate)) || dateOfAscent.isAtSameMomentAs(startDate) || dateOfAscent.isAtSameMomentAs(endDate)){
                return spot;
              }
            }
          }
        }
      }
      for (String routeId in spot.singlePitchRouteIds){
        final Response singlePitchResponse = await netWorkLocator.dio.get('$climbingApiHost/single_pitch_route/$routeId');
        if (singlePitchResponse.statusCode == 200) {
          SinglePitchRoute singlePitchRoute = SinglePitchRoute.fromJson(singlePitchResponse.data);
          for (String ascentId in singlePitchRoute.ascentIds){
            final Response ascentResponse = await netWorkLocator.dio.get('$climbingApiHost/ascent/$ascentId');
            Ascent ascent = Ascent.fromJson(ascentResponse.data);
            DateTime dateOfAscent = DateTime.parse(ascent.date);
            if ((dateOfAscent.isAfter(startDate) && dateOfAscent.isBefore(endDate)) || dateOfAscent.isAtSameMomentAs(startDate) || dateOfAscent.isAtSameMomentAs(endDate)){
              return spot;
            }
          }
        }
      }
    }
    return null;
  }

  Future<Spot?> createSpot(CreateSpot createSpot, bool hasConnection) async {
    CreateSpot spot = CreateSpot(
      name: createSpot.name,
      coordinates: createSpot.coordinates,
      location: createSpot.location,
      rating: createSpot.rating,
      comment: (createSpot.comment != null) ? createSpot.comment! : "",
      distanceParking: (createSpot.distanceParking != null)
          ? createSpot.distanceParking!
          : 0,
      distancePublicTransport: (createSpot.distancePublicTransport != null)
          ? createSpot.distancePublicTransport!
          : 0,
    );
    if (hasConnection) {
      var data = spot.toJson();
      return uploadSpot(data);
    } else {
      // save to cache
      Box box = Hive.box('upload_later_spots');
      Map spotJson = spot.toJson();
      box.put(spotJson.hashCode, spotJson);
    }
    return null;
  }

  Future<Spot?> editSpot(UpdateSpot spot) async {
    try {
      final Response response = await netWorkLocator.dio
          .put('$climbingApiHost/spot/${spot.id}', data: spot.toJson());
      if (response.statusCode == 200) {
        deleteSpotFromEditQueue(spot.hashCode);
        return Spot.fromJson(response.data);
      } else {
        throw Exception('Failed to edit spot');
      }
    } catch (e) {
      if (e is DioError) {
        if (e.error.toString().contains('OS Error: No address associated with hostname, errno = 7')){
          // this means we are offline so queue this spot and edit later
          Box box = Hive.box('edit_later_spots');
          Map spotJson = spot.toJson();
          box.put(spotJson.hashCode, spotJson);
        }
      }
    } finally {
      editSpotFromCache(spot);
    }
    return null;
  }

  Future<void> deleteSpot(Spot spot) async {
    try {
      for (var id in spot.mediaIds) {
        final Response mediaResponse =
        await netWorkLocator.dio.delete('$mediaApiHost/media/$id');
        if (mediaResponse.statusCode != 204) {
          throw Exception('Failed to delete medium');
        }
      }

      final Response spotResponse =
      await netWorkLocator.dio.delete('$climbingApiHost/spot/${spot.id}');
      if (spotResponse.statusCode != 200) {
        throw Exception('Failed to delete spot');
      }
      showSimpleNotification(
        Text('Spot was deleted: ${spotResponse.data['name']}'),
        background: Colors.green,
      );
      deleteSpotFromDeleteQueue(spot.toJson().hashCode);
      return spotResponse.data;
    } catch (e) {
      if (e is DioError) {
        if (e.error.toString().contains('OS Error: No address associated with hostname, errno = 7')){
          // this means we are offline so queue this spot and delete later
          Box box = Hive.box('delete_later_spots');
          Map spotJson = spot.toJson();
          box.put(spotJson.hashCode, spotJson);
        }
      }
    } finally {
      deleteSpotFromCache(spot.id);
    }
  }

  Future<Spot?> uploadSpot(Map data) async {
    try {
      final Response response = await netWorkLocator.dio
          .post('$climbingApiHost/spot', data: data);
      if (response.statusCode == 201) {
        showSimpleNotification(
          Text('Created new spot: ${response.data['name']}'),
          background: Colors.green,
        );
        return Spot.fromJson(response.data);
      } else {
        throw Exception('Failed to create spot');
      }
    } catch (e) {
      if (e is DioError) {
        final response = e.response;
        if (response != null) {
          switch (response.statusCode) {
            case 409:
              showSimpleNotification(
                const Text('This spot already exists!'),
                background: Colors.red,
              );
              break;
            default:
              throw Exception('Failed to create spot');
          }
        }
      }
    } finally {
      deleteSpotFromUploadQueue(data.hashCode);
    }
    return null;
  }
}
