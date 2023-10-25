import 'dart:typed_data';

import 'package:climbing_diary/components/common/my_notifications.dart';
import 'package:climbing_diary/interfaces/media/media.dart';
import 'package:climbing_diary/services/cache_service.dart';
import 'package:climbing_diary/services/error_service.dart';
import 'package:climbing_diary/services/media_service.dart';
import '../config/environment.dart';
import 'package:dio/dio.dart';

import '../data/network/dio_client.dart';
import '../data/sharedprefs/shared_preference_helper.dart';
import 'locator.dart';
import 'package:http/http.dart' as http;

class AdminService {
  final netWorkLocator = getIt.get<DioClient>();
  final sharedPrefLocator = getIt.get<SharedPreferenceHelper>();
  final String climbingApiHost = Environment().config.climbingApiHost;
  final String mediaApiHost = Environment().config.mediaApiHost;
  MediaService mediaService = MediaService();

  Future<void> deleteAll() async {
    try {
      final Response dataResponse = await netWorkLocator.dio.delete('$climbingApiHost/admin/');
      if (dataResponse.statusCode != 200) throw Exception('Failed to delete all data');
      await CacheService.clearCache();
      MyNotifications.showPositiveNotification('All your data was deleted');
    } catch (e) {
      ErrorService.handleConnectionErrors(e);
    }
  }

  Future<void> migrateMedia() async {
    try {
      final Response mediaResponse = await netWorkLocator.dio.get('$mediaApiHost/media');
      if (mediaResponse.statusCode != 200) throw Exception('Failed to get media');
      for (final medium in mediaResponse.data!){
        final Response mediumResponse = await netWorkLocator.dio.get('$mediaApiHost/media/${medium["id"]}/access-url');
        if (mediumResponse.statusCode != 200) throw Exception('Failed to get medium');
        final idUrl = mediumResponse.data!;
        String url = idUrl['url'];
        // download image
        var uri = Uri.parse(url);
        http.Response response = await http.get(uri);
        Uint8List image = response.bodyBytes;
        // create medium
        Media createMedium = Media(
          id: medium['id'],
          userId: medium['user_id'],
          title: medium['title'],
          createdAt: DateTime.parse(medium['created_at']).toIso8601String(),
          image: image
        );
        await mediaService.createMedium(createMedium);
      }
      MyNotifications.showPositiveNotification('Migrated media');
    } catch (e) {
      ErrorService.handleConnectionErrors(e);
    }
  }
}
