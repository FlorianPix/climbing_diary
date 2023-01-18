
import 'dart:convert';

import 'package:climbing_diary/interfaces/create_spot.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

import '../data/network/dio_client.dart';
import '../data/sharedprefs/shared_preference_helper.dart';
import '../interfaces/spot.dart';
import 'locator.dart';


class SpotService {
  final netWorkLocator = getIt.get<DioClient>();
  final sharedPrefLocator = getIt.get<SharedPreferenceHelper>();

  Future<List<Spot>> getSpots() async {
    final Response response = await netWorkLocator.dio.get('http://10.0.2.2:8000/spot');

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response, then parse the JSON.
      List<Spot> spots = [];
      response.data.forEach((s) =>
      {
        print(s),
        spots.add(Spot.fromJson(s))
      });
      return spots;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load spots');
    }
  }

  Future<Spot> getSpot(String spotId) async {
    final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/spot/$spotId')
    );

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response, then parse the JSON.
      return Spot.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load spots');
    }
  }

  Future<Spot> createSpot(CreateSpot spot) async {
    final Response response = await netWorkLocator.dio.post(
        'http://10.0.2.2:8000/spot',
        data: spot.toJson()
    );

    if (response.statusCode == 201) {
      // If the server did return a 200 OK response, then parse the JSON.
      return response.data;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to create spot');
    }
  }
}