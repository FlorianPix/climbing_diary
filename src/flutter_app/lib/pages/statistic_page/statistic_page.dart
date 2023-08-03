import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:intl/intl.dart';

import '../../interfaces/ascent/ascent.dart';
import '../../interfaces/ascent/ascent_type.dart';
import '../../interfaces/grade.dart';
import '../../interfaces/pitch/pitch.dart';
import '../../services/ascent_service.dart';
import '../../services/pitch_service.dart';
import '../../services/route_service.dart';

class StatisticPage extends StatefulWidget {
  const StatisticPage({super.key});

  @override
  State<StatefulWidget> createState() => StatisticPageState();
}

class StatisticPageState extends State<StatisticPage> {
  final RouteService routeService = RouteService();
  final PitchService pitchService = PitchService();
  final AscentService ascentService = AscentService();

  List<Color> gradientColors = [
    Colors.pink,
    Colors.blue,
    Colors.cyan,
  ];

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    Widget text = Container();
    if (value != -1) {
      if (value % 10 == 0) {
        text = Text(
            DateFormat.MMM().format(DateTime.parse(dates[value.toInt()])),
            style: style
        );
      }
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
    String text;
    switch (value.toInt()) {
      case 0: text = Grade.translationTable[3][0]; break;
      case 5: text = Grade.translationTable[3][5]; break;
      case 10: text = Grade.translationTable[3][10]; break;
      case 15: text = Grade.translationTable[3][15]; break;
      case 20: text = Grade.translationTable[3][20]; break;
      case 25: text = Grade.translationTable[3][25]; break;
      case 30: text = Grade.translationTable[3][30]; break;
      case 35: text = Grade.translationTable[3][35]; break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  LineChartData mainData(List<FlSpot> spots) {
    return LineChartData(
      gridData: FlGridData(
        show: false,
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.black12),
      ),
      minY: 0,
      maxY: 40,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  List<FlSpot> lineChartData = [];
  List<String> dates = [];

  fetchPerformance() async {
    List<Pitch> pitches = await pitchService.getPitches(true);
    for (Pitch pitch in pitches) {
      List<Ascent> ascents = await ascentService.getAscentsOfIds(true, pitch.ascentIds);
      ascents.sort((a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));
      for (Ascent ascent in ascents){
        if (ascent.type != AscentType.bail.index){
          lineChartData.add(FlSpot(lineChartData.length.toDouble(), Grade.translationTable[pitch.grade.system.index].indexOf(pitch.grade.grade).toDouble()));
          dates.add(ascent.date);
        }
      }
    }
    setState(() {});
  }

  @override
  void initState(){
    super.initState();
    fetchPerformance();
  }

  @override
  Widget build(BuildContext context) {
    var heatMapBuilder = FutureBuilder<List<Ascent>>(
      future: ascentService.getAscents(true), // TODO check if online
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



          return Card(child: Container(
              padding: const EdgeInsets.all(10),
              child: heatMap
          ));
        } else {
          return const CircularProgressIndicator();
        }
      },
    );

    Widget gradeLineChart = LineChart(
      mainData(lineChartData),
    );

    return Scaffold(
      body: Center(
        child: Padding(
        padding: const EdgeInsets.all(10),
          child: ListView(children: [
            heatMapBuilder,
            Card(child: Container(
                height: 200,
                padding: const EdgeInsets.all(10),
                child: gradeLineChart
            )),
          ],
          )
        )
      ),
    );
  }
}