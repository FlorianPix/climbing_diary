import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

class MyNotifications{
  static OverlaySupportEntry showPositiveNotification(String message) {
    return showSimpleNotification(
      Text(message),
      background: Colors.green,
    );
  }

  static OverlaySupportEntry showNegativeNotification(String message) {
   return showSimpleNotification(
     Text(message),
     background: Colors.red,
   );
  }
}