import 'package:climbing_diary/services/error_service.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:climbing_diary/components/common/my_notifications.dart';
import 'package:climbing_diary/config/environment.dart';
import 'package:climbing_diary/data/network/dio_client.dart';
import 'package:climbing_diary/data/sharedprefs/shared_preference_helper.dart';
import 'package:climbing_diary/interfaces/media/media.dart';
import 'package:climbing_diary/services/cache_service.dart';
import 'package:climbing_diary/services/locator.dart';


class MediaService {
  final netWorkLocator = getIt.get<DioClient>();
  final sharedPrefLocator = getIt.get<SharedPreferenceHelper>();
  final String mediaApiHost = Environment().config.mediaApiHost;

  /// Get all media from cache and optionally from the server.
  /// If the parameter [online] is null or false the media is searched in cache,
  /// otherwise it is requested from the server.
  Future<List<Media>> getMedia({bool? online}) async {
    if(online == null || !online) return CacheService.getMediaFromCache(Media.fromCache);
    // request media from the server
    try{
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
    } catch (e) {
      ErrorService.handleConnectionErrors(e);
    }
    return [];
  }

  /// Get the url of a medium from the server.
  Future<String> getMediumUrl(String mediaId) async {
    final Response response = await netWorkLocator.dio.get('$mediaApiHost/media/$mediaId/access-url');
    if (response.statusCode != 200) throw Exception('Failed to load spots');
    return response.data['url'];
  }

  /// Get a medium from cache and optionally from the server.
  /// If the parameter [online] is null or false the medium is searched in cache,
  /// otherwise it is requested from the server.
  Future<Media> getMedium(String mediaId, {bool? online}) async {
    return Media.fromCache(Hive.box(Media.boxName).get(mediaId));
    // TODO request from server if online
  }

  /// Upload a medium to the server.
  Future<String> uploadMedium(XFile file) async {
    FormData formData = FormData.fromMap({"file": await MultipartFile.fromFile(file.path)});
    final Response response = await netWorkLocator.dio.post('$mediaApiHost/media', data: formData);
    if (response.statusCode != 200) throw Exception('Failed to upload medium');
    MyNotifications.showPositiveNotification('Added new image');
    return response.data['id'];
  }

  /// Delete a medium in cache and optionally on the server.
  /// If the parameter [online] is null or false the data is deleted only from the cache and later from the server at the next sync.
  /// Otherwise it is deleted from cache and from the server immediately.
  Future<void> deleteMedium(Media media, {bool? online}) async {
    Box mediaBox = Hive.box(Media.boxName);
    Box deleteMediaBox = Hive.box(Media.deleteBoxName);
    await mediaBox.delete(media.id);
    await deleteMediaBox.put(media.id, media.toJson());
    if (online == null || !online) return;
    try {
      final Response response = await netWorkLocator.dio.delete('$mediaApiHost/media/${media.id}');
      if (response.statusCode != 204) throw Exception('Failed to load spots');
      await deleteMediaBox.delete(media.id);
      MyNotifications.showPositiveNotification('Image was deleted');
    } catch (e) {
      ErrorService.handleConnectionErrors(e);
    }
  }
}