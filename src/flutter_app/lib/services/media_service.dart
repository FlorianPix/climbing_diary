import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../config/environment.dart';
import '../data/network/dio_client.dart';
import '../data/sharedprefs/shared_preference_helper.dart';
import '../interfaces/media.dart';
import 'locator.dart';


class MediaService {
  final netWorkLocator = getIt.get<DioClient>();
  final sharedPrefLocator = getIt.get<SharedPreferenceHelper>();
  final String mediaApiHost = Environment().config.mediaApiHost;

  Future<List<Media>> getMedia() async {
    final Response response = await netWorkLocator.dio.get('$mediaApiHost/media');

    if (response.statusCode == 200) {
      List<Media> media = [];
      response.data.forEach((s) =>
      {
        media.add(Media.fromJson(s))
      });
      return media;
    } else {
      throw Exception('Failed to load media');
    }
  }

  Future<String> getMediumUrl(String mediaId) async {
    final Response response = await netWorkLocator.dio.get('$mediaApiHost/media/$mediaId/access-url');

    if (response.statusCode == 200) {
      return response.data['url'];
    } else {
      throw Exception('Failed to load spots');
    }
  }

  Future<String> uploadMedia(XFile file) async {
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(file.path),
    });
    final Response response = await netWorkLocator.dio.post(
        '$mediaApiHost/media',
        data: formData
    );

    if (response.statusCode == 200) {
      return response.data['id'];
    } else {
      throw Exception('Failed to upload media');
    }
  }

  Future<void> deleteMedium(String mediaId) async {
    final Response response = await netWorkLocator.dio.delete(
        '$mediaApiHost/media/$mediaId'
    );

    if (response.statusCode == 204) {
      return;
    } else {
      throw Exception('Failed to load spots');
    }
  }
}