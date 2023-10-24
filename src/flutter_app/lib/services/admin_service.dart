import 'package:climbing_diary/components/common/my_notifications.dart';
import 'package:climbing_diary/services/cache_service.dart';
import 'package:climbing_diary/services/error_service.dart';
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

  Future<void> deleteAll() async {
    try {
      final Response dataResponse = await netWorkLocator.dio.delete('$climbingApiHost/admin/');
      if (dataResponse.statusCode != 200) throw Exception('Failed to delete all data');
      await CacheService.clearCache();
      MyNotifications.showPositiveNotification('All your data was deleted');
    } catch (e) {
      if (e is DioError) {
        if (e.error.toString().contains('OS Error: No address associated with hostname, errno = 7')){
        }
      }
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
        var uri = Uri.https(url);
        var response = await http.get(uri);
        print('Response status: ${response.statusCode}');
        // convert to UInt8List
        // create medium
      }
    } catch (e) {
      ErrorService.handleConnectionErrors(e);
    }
  }
}
