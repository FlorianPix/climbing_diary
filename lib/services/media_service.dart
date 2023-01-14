
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

import '../data/network/dio_client.dart';
import '../data/sharedprefs/shared_preference_helper.dart';
import '../interfaces/media.dart';
import '../interfaces/spot.dart';
import 'locator.dart';


class MediaService {
  final netWorkLocator = getIt.get<DioClient>();
  final sharedPrefLocator = getIt.get<SharedPreferenceHelper>();

  Future<List<Media>> fetchMedia() async {
    final Response response = await netWorkLocator.dio.get('http://10.0.2.2:8001/media');

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response, then parse the JSON.
      List<Media> media = [];
      response.data.forEach((s) =>
      {
        media.add(Media.fromJson(s))
      });
      return media;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load media');
    }
  }

  Future<String> fetchMediumUrl(String mediaId) async {
    final Response response = await netWorkLocator.dio.get('http://10.0.2.2:8001/media/$mediaId/access-url');

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response, then parse the JSON.
      return response.data['url'];
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load spots');
    }
  }
}