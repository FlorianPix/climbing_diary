import 'package:flutter/material.dart';

class MyButtonStyles{
  static ButtonStyle rounded = ButtonStyle(
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.0),
        side: const BorderSide(color: Colors.red)
      ),
    ),
  );
}