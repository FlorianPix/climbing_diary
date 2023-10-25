import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:climbing_diary/services/error_service.dart';
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
  final String climbingApiHost = Environment().config.climbingApiHost;

  /// Upload a medium to the server.
  Future<String> createMedium(Media medium, {bool? online}) async {
    // add to cache
    Box mediaBox = Hive.box(Media.boxName);
    Box createMediaBox = Hive.box(Media.createBoxName);
    await mediaBox.put(medium.id, medium.toJson());
    await createMediaBox.put(medium.id, medium.toJson());
    if (online == null || !online) return medium.id;
    Media? createdMedium = await uploadMedium(medium.toJson());
    if (createdMedium == null) return medium.id;
    await mediaBox.put(createdMedium.id, createdMedium.toJson());
    await createMediaBox.delete(medium.id);
    return createdMedium.id;
  }

  /// Get all media from cache and optionally from the server.
  /// If the parameter [online] is null or false the media is searched in cache,
  /// otherwise it is requested from the server.
  Future<List<Media>> getMedia({bool? online}) async {
    if(online == null || !online) return CacheService.getMediaFromCache(Media.fromCache);
    // request media from the server
    try{
      final Response response = await netWorkLocator.dio.get('$climbingApiHost/media');
      if (response.statusCode != 200) throw Exception('Failed to load media');
      List<Media> media = [];
      Box mediaBox = Hive.box(Media.boxName);
      await Future.forEach(response.data, (dynamic s) async {
        Media medium = await getMedium(s['_id'], online: online);
        await mediaBox.put(medium.id, medium.toJson());
        media.add(medium);
      });
      // delete media that were deleted on the server
      List<Media> cachedMedia = CacheService.getTsFromCache<Media>(Media.boxName, Media.fromCache);
      for (Media cachedMedium in cachedMedia){
        if (!media.contains(cachedMedium)){
          await mediaBox.delete(cachedMedium.id);
        }
      }
      return media;
    } catch (e) {
      ErrorService.handleConnectionErrors(e);
    }
    return [];
  }

  /// Get a medium from cache and optionally from the server.
  /// If the parameter [online] is null or false the medium is searched in cache,
  /// otherwise it is requested from the server.
  Future<Media> getMedium(String mediaId, {bool? online}) async {
    if(online == null || !online) return Media.fromCache(Hive.box(Media.boxName).get(mediaId));
    try{
      final Response response = await netWorkLocator.dio.get('$climbingApiHost/media/$mediaId');
      if (response.statusCode != 200) throw Exception('Failed to load medium');
      Box box = Hive.box(Media.boxName);
      Media medium = Media.fromJson(response.data);
      await box.put(medium.id, medium.toJson());
      return medium;
    } catch (e) {
      ErrorService.handleConnectionErrors(e);
    }
    throw Exception('Couldn\'t find medium');
  }

  /// Delete a medium in cache and optionally on the server.
  /// If the parameter [online] is null or false the data is deleted only from the cache and later from the server at the next sync.
  /// Otherwise it is deleted from cache and from the server immediately.
  Future<void> deleteMedium(Media media, {bool? online}) async {
    Box deleteMediaBox = Hive.box(Media.deleteBoxName);
    await deleteMediumLocal(media);
    await deleteMediaBox.put(media.id, media.toJson());
    if (online == null || !online) return;
    await deleteMediumRemote(media);
    await deleteMediaBox.delete(media.id);
  }

  /// Delete a medium in cache only.
  Future<void> deleteMediumLocal(Media media) async {
    Box mediaBox = Hive.box(Media.boxName);
    await mediaBox.delete(media.id);
  }

  /// Delete a medium on the server only.
  Future<void> deleteMediumRemote(Media media) async {
    try {
      final Response response = await netWorkLocator.dio.delete('$climbingApiHost/media/${media.id}');
      if (response.statusCode != 200) throw Exception('Failed to delete medium');
      MyNotifications.showPositiveNotification('Image was deleted');
    } catch (e) {
      ErrorService.handleConnectionErrors(e);
    }
  }

  /// Upload a medium to the server.
  Future<Media?> uploadMedium(Map data) async {
    try {
      final Response response = await netWorkLocator.dio.post('$climbingApiHost/media', data: data);
      if (response.statusCode != 201) throw Exception('Failed to create medium');
      MyNotifications.showPositiveNotification('Added a new image');
      return Media.fromJson(response.data);
    } catch (e) {
      if (e is DioError) {
        final response = e.response;
        if (response != null) {
          switch (response.statusCode) {
            case 409:
              MyNotifications.showNegativeNotification('This medium already exists!');
              Box createMediaBox = Hive.box(Media.createBoxName);
              await createMediaBox.delete(data['_id']);
              break;
            default:
              throw Exception('Failed to create medium');
          }
        }
      }
    }
    return null;
  }
}