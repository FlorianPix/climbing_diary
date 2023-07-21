import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';

import '../../interfaces/ascent/ascent.dart';
import '../../services/ascent_service.dart';

class StatisticPage extends StatefulWidget {
  const StatisticPage({super.key});

  @override
  State<StatefulWidget> createState() => StatisticPageState();
}

class StatisticPageState extends State<StatisticPage> {
  final AscentService ascentService = AscentService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder<List<Ascent>>(
          future: ascentService.getAscents(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Ascent> ascents = snapshot.data!;
              Map<DateTime, int> datasets = <DateTime, int>{};
              for (var ascent in ascents) {
                DateTime date = DateTime.parse(ascent.date);
                if (datasets.keys.contains(date)){
                  datasets[date] = (datasets[date]! + 1);
                } else {
                  datasets[date] = 1;
                }
              }
              Widget heatMap = HeatMapCalendar(
                defaultColor: Colors.white,
                flexible: true,
                colorMode: ColorMode.opacity,
                datasets: datasets,
                colorsets: const {
                  1: Colors.red,
                  3: Colors.orange,
                  5: Colors.yellow,
                  7: Colors.green,
                  9: Colors.blue,
                  11: Colors.indigo,
                  13: Colors.purple,
                },
                onClick: (value) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value.toString())));
                },
              );
              return ListView(
                children: [
                  heatMap
                ],
              );
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}