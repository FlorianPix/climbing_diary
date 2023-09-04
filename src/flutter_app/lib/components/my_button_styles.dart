import 'package:flutter/material.dart';

class MyButtonStyles{
  static MaterialStateProperty<OutlinedBorder?>? rounded = MaterialStateProperty.all<RoundedRectangleBorder>(
    RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18.0),
    )
  );
}