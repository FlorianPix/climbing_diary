import 'package:climbing_diary/components/common/my_notifications.dart';
import 'package:dio/dio.dart';

class ErrorService {
  static void handleConnectionErrors(dynamic e){
    if (e is DioError) {
      if (e.error.toString().contains("OS Error: Connection refused, errno = 111")){
        MyNotifications.showNegativeNotification('No connection');
      }
      if (e.error.toString().contains('OS Error: No address associated with hostname, errno = 7')){
        MyNotifications.showNegativeNotification('No connection');
      }
    }
    print(e);
  }

  static void handleCreationErrors(dynamic e, String elementName){
    if (e is DioError) {
      final response = e.response;
      if (response != null) {
        switch (response.statusCode) {
          case 409:
            MyNotifications.showNegativeNotification('This $elementName already exists!');
            break;
          default:
            throw Exception('Failed to create $elementName');
        }
      }
    }
    print(e);
  }
}