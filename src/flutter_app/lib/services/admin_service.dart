import '../components/my_notifications.dart';
import '../config/environment.dart';
import 'package:dio/dio.dart';

import '../data/network/dio_client.dart';
import '../data/sharedprefs/shared_preference_helper.dart';
import 'locator.dart';

class AdminService {
  final netWorkLocator = getIt.get<DioClient>();
  final sharedPrefLocator = getIt.get<SharedPreferenceHelper>();
  final String climbingApiHost = Environment().config.climbingApiHost;
  final String mediaApiHost = Environment().config.mediaApiHost;

  Future<void> deleteAll() async {
    try {
      final Response dataResponse = await netWorkLocator.dio.delete('$climbingApiHost/admin/');
      if (dataResponse.statusCode != 200) {
        throw Exception('Failed to delete all data');
      }
      MyNotifications.showPositiveNotification('All your data was deleted');
      final Response mediaResponse = await netWorkLocator.dio.delete('$mediaApiHost/media');
      if (mediaResponse.statusCode != 204) {
        throw Exception('Failed to delete all images');
      }
      // TODO delete from cache
      MyNotifications.showPositiveNotification('All your images were deleted');
    } catch (e) {
      if (e is DioError) {
        if (e.error.toString().contains('OS Error: No address associated with hostname, errno = 7')){
          // TODO this means we are offline so queue this and delete later
        }
      }
    } finally {
      // TODO delete from cache;
    }
  }
}
