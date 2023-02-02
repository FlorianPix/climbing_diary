import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class StatisticPage extends StatelessWidget {
  const StatisticPage({super.key});

  @override
  Widget build(BuildContext context) {
    var data = _getInfo();
    return Scaffold(
      body: Center(
        child: Text (
         // "$data"
          "Statistics"
        )
      ),
    );
  }
  _getInfo() {
    Box box = Hive.box('saveSpot');
    var data = box.get('spot');
    return data;
  }
}