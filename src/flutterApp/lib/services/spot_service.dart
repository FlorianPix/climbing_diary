import 'package:hive/hive.dart';

import '../interfaces/create_spot.dart';
import 'package:dio/dio.dart';

import '../data/network/dio_client.dart';
import '../data/sharedprefs/shared_preference_helper.dart';
import '../interfaces/spot.dart';
import '../interfaces/update_spot.dart';
import 'locator.dart';

class SpotService {
  final netWorkLocator = getIt.get<DioClient>();
  final sharedPrefLocator = getIt.get<SharedPreferenceHelper>();

  Future<List<Spot>> getSpots() async {
    try {
      final Response response = await netWorkLocator.dio.get('http://10.0.2.2:8000/spot');

      if (response.statusCode == 200) {
        // If the server did return a 200 OK response, then parse the JSON.
        List<Spot> spots = [];
        response.data.forEach((s) => {spots.add(Spot.fromJson(s))});
        return spots;
      }
    } catch (e) {
      // TODO give a notification that the API isn't reachable
      return [];
    }
    throw Exception('Failed to load spots');
  }

  Future<Spot> getSpot(String spotId) async {
    final Response response =
        await netWorkLocator.dio.get('http://10.0.2.2:8000/spot/$spotId');

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response, then parse the JSON.
      return Spot.fromJson(response.data);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load spot');
    }
  }

  Future<Spot?> createSpot(CreateSpot createSpot, bool hasConnection) async {
    CreateSpot spot = CreateSpot(
      date: createSpot.date,
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
      Box box = Hive.box('saveSpot');
      box.put('spot', spot.toJson());
    }
    return null;
  }

  Future<Spot?> editSpot(UpdateSpot spot) async {
    // TODO replace with spread operator after upgrade to flutter 2.3
    final Response response = await netWorkLocator.dio
        .put('http://10.0.2.2:8000/spot/${spot.id}', data: spot.toJson());

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response, then parse the JSON.
      return Spot.fromJson(response.data);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to edit spot');
    }
  }

  Future<void> deleteSpot(Spot spot) async {
    for (var id in spot.mediaIds) {
      final Response mediaResponse =
      await netWorkLocator.dio.delete('http://10.0.2.2:8001/media/$id');
      if (mediaResponse.statusCode != 204) {
        throw Exception('Failed to delete medium');
      }
    }

    final Response spotResponse =
        await netWorkLocator.dio.delete('http://10.0.2.2:8000/spot/${spot.id}');
    if (spotResponse.statusCode != 204) {
      throw Exception('Failed to delete spot');
    }
    return spotResponse.data;
  }

  Future<Spot?> uploadSpot(Map data) async {
    try {
      final Response response = await netWorkLocator.dio
          .post('http://10.0.2.2:8000/spot', data: data);
      if (response.statusCode == 201) {
        return Spot.fromJson(response.data);
      } else {
        throw Exception('Failed to create spot');
      }
    } catch (e) {
      if (e is DioError) {
        print(e);
        print(e.response!);
        print(data);
      }
    }
    return null;
  }
}
