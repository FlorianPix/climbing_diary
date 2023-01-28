import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class StatisticPage extends StatelessWidget {
  const StatisticPage({super.key});

  @override
  Widget build(BuildContext context) {
    var data = _getInfo();
    print("here is caches data ${data}");
    return Scaffold(
      appBar: AppBar(
        title: Text('statistic'),
      ),
      body: Center(
        child: TextField (
          textAlign: _getInfo(),
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