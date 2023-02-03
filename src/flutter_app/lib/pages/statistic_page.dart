import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class StatisticPage extends StatelessWidget {
  const StatisticPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text (
          "Statistics"
        )
      ),
    );
  }
}