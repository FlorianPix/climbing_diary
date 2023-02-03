import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

class StatisticPage extends StatelessWidget {
  const StatisticPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showSimpleNotification(
              const Text("Statistics page is not implemented yet"),
              background: Colors.red,
              duration: const Duration(seconds: 4)
            );
          },
          child: const Text("Statistics"),
        ),
      ),
    );
  }
}