import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../components/common/my_notifications.dart';
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
    if (response.statusCode != 200) throw Exception('Failed to load media');
    List<Media> media = [];
    response.data.forEach((s) => media.add(Media.fromJson(s)));
    return media;
  }

  Future<String> getMediumUrl(String mediaId) async {
    final Response response = await netWorkLocator.dio.get('$mediaApiHost/media/$mediaId/access-url');
    if (response.statusCode != 200) throw Exception('Failed to load spots');
    return response.data['url'];
  }

  Future<String> uploadMedia(XFile file) async {
    FormData formData = FormData.fromMap({"file": await MultipartFile.fromFile(file.path)});
    final Response response = await netWorkLocator.dio.post('$mediaApiHost/media', data: formData);
    if (response.statusCode != 200) throw Exception('Failed to upload media');
    MyNotifications.showPositiveNotification('Added new image');
    return response.data['id'];
  }

  Future<void> deleteMedium(String mediaId) async {
    final Response response = await netWorkLocator.dio.delete('$mediaApiHost/media/$mediaId');
    if (response.statusCode != 204) throw Exception('Failed to load spots');
    MyNotifications.showPositiveNotification('Image was deleted');
    return;
  }
}