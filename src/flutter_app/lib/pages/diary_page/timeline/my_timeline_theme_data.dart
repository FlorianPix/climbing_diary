import 'package:flutter/material.dart';
import 'package:timelines/timelines.dart';

class MyTimeLineThemeData{
  static TimelineThemeData defaultTheme = TimelineThemeData(
    nodePosition: 0,
    color: const Color(0xff989898),
    indicatorTheme: const IndicatorThemeData(position: 0, size: 20.0),
    connectorTheme: const ConnectorThemeData(thickness: 2.5),
  );
}