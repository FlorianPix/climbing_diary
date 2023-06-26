import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:overlay_support/overlay_support.dart';

import '../config/environment.dart';
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

  Future<Spot?> getSpot(String spotId) async {
    final Response response =
        await netWorkLocator.dio.get('$climbingApiHost/spot/$spotId');
    if (response.statusCode == 200) {
      return Spot.fromJson(response.data);
    } else {
      return null;
    }
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
      if (spotResponse.statusCode != 204) {
        throw Exception('Failed to delete spot');
      }
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
