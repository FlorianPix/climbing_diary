import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';

import '../components/common/my_notifications.dart';
import '../config/environment.dart';
import '../data/network/dio_client.dart';
import '../data/sharedprefs/shared_preference_helper.dart';
import '../interfaces/media.dart';
import 'cache_service.dart';
import 'locator.dart';


class MediaService {
  final netWorkLocator = getIt.get<DioClient>();
  final sharedPrefLocator = getIt.get<SharedPreferenceHelper>();
  final String mediaApiHost = Environment().config.mediaApiHost;

  Future<List<Media>> getMedia(bool online) async {
    if (online) {
      final Response response = await netWorkLocator.dio.get('$mediaApiHost/media');
      if (response.statusCode != 200) throw Exception('Failed to load media');
      List<Media> media = [];
      Box box = Hive.box(Media.boxName);
      await Future.forEach(response.data, (dynamic s) async {
        if (!box.containsKey(s['id'])) {
          String mediumUrl = await getMediumUrl(s['id']);
          final mediumResponse = await http.get(Uri.parse(mediumUrl));
          s['image'] = mediumResponse.bodyBytes;
          Media medium = Media.fromJson(s);
          await box.put(medium.id, medium.toJson());
          media.add(medium);
        } else {
          Media medium = Media.fromCache(box.get(s['id']));
          media.add(medium);
        }
      });
      return media;
    }
    return [];
  }

  Future<String> getMediumUrl(String mediaId) async {
    final Response response = await netWorkLocator.dio.get('$mediaApiHost/media/$mediaId/access-url');
    if (response.statusCode != 200) throw Exception('Failed to load spots');
    return response.data['url'];
  }

  Future<Media> getMedium(String mediaId) async {
    return CacheService.getMediumFromCache(mediaId);
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