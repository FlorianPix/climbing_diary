import 'package:climbing_diary/components/common/my_colors.dart';
import 'package:climbing_diary/interfaces/ascent/ascent_style.dart';
import 'package:climbing_diary/interfaces/single_pitch_route/single_pitch_route.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../interfaces/ascent/ascent.dart';
import '../../interfaces/ascent/ascent_type.dart';
import '../../interfaces/grade.dart';
import '../../interfaces/grading_system.dart';
import '../../interfaces/pitch/pitch.dart';
import '../../services/ascent_service.dart';
import '../../services/pitch_service.dart';
import '../../interfaces/detailed_grade.dart';
import '../../services/single_pitch_route_service.dart';

class StatisticPage extends StatefulWidget {
  const StatisticPage({super.key, required this.onNetworkChange});
  final ValueSetter<bool> onNetworkChange;

  @override
  State<StatefulWidget> createState() => StatisticPageState();
}

class StatisticPageState extends State<StatisticPage> {
  final SinglePitchRouteService singlePitchRouteService = SinglePitchRouteService();
  final PitchService pitchService = PitchService();
  final AscentService ascentService = AscentService();

  List<Color> gradientColors = [
    Colors.pink,
    Colors.blue,
    Colors.cyan
  ];

  Future<List<DetailedGrade>> fetchDetailedGrade(bool online) async {
    List<DetailedGrade> detailedGrades = [];
    List<Pitch> pitches = await pitchService.getPitches(online);
    for (Pitch pitch in pitches) {
      List<Ascent> ascents = await ascentService.getAscentsOfIds(online, pitch.ascentIds);
      for (Ascent ascent in ascents){
        if (ascent.type != AscentType.bail.index){
          DetailedGrade detailedGrade = DetailedGrade(
            date: ascent.date,
            ascentStyle: AscentStyle.values[ascent.style],
            ascentType: AscentType.values[ascent.type],
            grade: pitch.grade
          );
          detailedGrades.add(detailedGrade);
        }
      }
    }
    List<SinglePitchRoute> singlePitchRoutes = await singlePitchRouteService.getSinglePitchRoutes(online);
    for (SinglePitchRoute singlePitchRoute in singlePitchRoutes) {
      List<Ascent> ascents = await ascentService.getAscentsOfIds(online, singlePitchRoute.ascentIds);
      for (Ascent ascent in ascents){
        if (ascent.type != AscentType.bail.index){
          DetailedGrade detailedGrade = DetailedGrade(
            date: ascent.date,
            ascentStyle: AscentStyle.values[ascent.style],
            ascentType: AscentType.values[ascent.type],
            grade: singlePitchRoute.grade
          );
          detailedGrades.add(detailedGrade);
        }
      }
    }
    detailedGrades.sort((a, b) => DateTime.parse(a.date).compareTo(DateTime.parse(b.date)));
    return detailedGrades;
  }

  GradingSystem gradingSystem = GradingSystem.french;
  late SharedPreferences prefs;
  fetchGradingSystemPreference() async {
    prefs = await SharedPreferences.getInstance();
    int? fetchedGradingSystem = prefs.getInt('gradingSystem');
    if (fetchedGradingSystem != null) gradingSystem = GradingSystem.values[fetchedGradingSystem];
    setState(() {});
  }

  bool switchBoulder = false;
  bool switchSolo = false;
  bool switchLead = true;
  bool switchSecond = false;
  bool switchTopRope = false;
  bool switchAid = false;

  bool switchOnSight = true;
  bool switchFlash = true;
  bool switchRedPoint = true;
  bool switchTick = false;

  bool online = false;

  void checkConnection() async {
    await InternetConnectionChecker().hasConnection.then((value) {
      widget.onNetworkChange.call(value);
      setState(() => online = value);
    });
  }


  @override
  void initState(){
    super.initState();
    fetchGradingSystemPreference();
    checkConnection();
  }

  @override
  Widget build(BuildContext context) {
    var heatMapBuilder = FutureBuilder<List<Ascent>>(
      future: ascentService.getAscents(online),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text(snapshot.error.toString());
        if (!snapshot.hasData) return const CircularProgressIndicator();
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
          colorMode: ColorMode.color,
          datasets: datasets,
          colorsets: MyColors.heatMap,
          onClick: (value) {
            int? numOfAscents = datasets[value];
            numOfAscents = numOfAscents ?? 0;
            ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("${numOfAscents.toString()} ascent(s)")));
          },
        );
        return Card(child: Container(padding: const EdgeInsets.all(10), child: heatMap));
      },
    );

    Widget switchStyleRow = Card(child: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Row(children: [
          Column(children: [
            const Text("🪨"),
            Switch(value: switchBoulder,
              onChanged: (bool value) => setState(() => switchBoulder = value)
            ),
          ]),
          Column(children: [
            const Text("🔥"),
            Switch(value: switchSolo,
              onChanged: (bool value) => setState(() => switchSolo = value)
            )
          ]),
          Column(children: [
            const Text("🥇"),
            Switch(value: switchLead,
              onChanged: (bool value) => setState(() => switchLead = value)
            )
          ]),
          Column(children: [
            const Text("🥈️"),
            Switch(value: switchSecond,
              onChanged: (bool value) => setState(() => switchSecond = value)
            )
          ]),
          Column(children: [
            const Text("🥉"),
            Switch(value: switchTopRope,
              onChanged: (bool value) => setState(() => switchTopRope = value)
            )
          ]),
          Column(children: [
            const Text("🩹"),
            Switch(value: switchAid,
              onChanged: (bool value) => setState(() => switchAid = value)
            )
          ]),
        ])
    ));

    Widget switchTypeRow = Card(child: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Row(children: [
          Column(children: [
            const Text("👁️"),
            Switch(value: switchOnSight,
              onChanged: (bool value) => setState(() => switchOnSight = value)
            )
          ]),
          Column(children: [
            const Text("⚡"),
            Switch(value: switchFlash,
              onChanged: (bool value) => setState(() => switchFlash = value)
            )
          ]),
          Column(children: [
            const Text("🔴"),
            Switch(value: switchRedPoint,
              onChanged: (bool value) => setState(() => switchRedPoint = value)
            )
          ]),
          Column(children: [
            const Text("✔️"),
            Switch(value: switchTick,
              onChanged: (bool value) => setState(() => switchTick = value)
            )
          ]),
        ])
    ));

    Widget gradeLineChart = FutureBuilder<List<DetailedGrade>>(
      future: fetchDetailedGrade(online),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text(snapshot.error.toString());
        if (!snapshot.hasData) return const CircularProgressIndicator();
        List<DetailedGrade> detailedGrades = snapshot.data!;

        bool noBetterDetailedGrade(List<DetailedGrade> list, DetailedGrade el){
          for (DetailedGrade gs in list){
            if (gs == el) continue;
            if (gs.date != el.date) continue;
            if (gs.grade > el.grade) return false;
          }
          return true;
        }

        detailedGrades = detailedGrades.where((element) {
          if (!switchBoulder && element.ascentStyle == AscentStyle.boulder) return false;
          if (!switchSolo && element.ascentStyle == AscentStyle.solo) return false;
          if (!switchLead && element.ascentStyle == AscentStyle.lead) return false;
          if (!switchSecond && element.ascentStyle == AscentStyle.second) return false;
          if (!switchTopRope && element.ascentStyle == AscentStyle.topRope) return false;
          if (!switchAid && element.ascentStyle == AscentStyle.aid) return false;
          if (!switchOnSight && element.ascentType == AscentType.onSight) return false;
          if (!switchFlash && element.ascentType == AscentType.flash) return false;
          if (!switchRedPoint && element.ascentType == AscentType.redPoint) return false;
          if (!switchTick && element.ascentType == AscentType.tick) return false;
          if (DateTime.now().difference(DateTime.parse(element.date)).inDays > 365) return false;
          return true;
        }).toList();

        detailedGrades = detailedGrades.where((element) {
          if (!noBetterDetailedGrade(detailedGrades, element)) return false;
          return true;
        }).toList();

        List<FlSpot> lineChartData = [];
        for (int i = 0; i < detailedGrades.length; i++) {
          DetailedGrade detailedGrade = detailedGrades[i];
          lineChartData.add(FlSpot(
            i.toDouble(),
            Grade.translationTable[detailedGrade.grade.system.index].indexOf(detailedGrade.grade.grade).toDouble()
          ));
        }

        Widget bottomTitleWidgets(double value, TitleMeta meta) {
          const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 16);
          Widget text = Container();
          if (value != -1) {
            text = Text(
              DateFormat.MMMd().format(DateTime.parse(detailedGrades[value.toInt()].date)),
              style: style
            );
          }

          return SideTitleWidget(axisSide: meta.axisSide, child: text);
        }

        Widget leftTitleWidgets(double value, TitleMeta meta) {
          const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 15);
          String text;
          int valInt = value.toInt();
          if (valInt >= 0 && valInt <= 38){
            text = Grade.translationTable[gradingSystem.index][valInt];
          } else {
            return const SizedBox.shrink();
          }
          return Text(text, style: style, textAlign: TextAlign.left);
        }

        LineChartData mainData(List<FlSpot> spots) {
          return LineChartData(
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                  fitInsideHorizontally: true,
                  getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                    return touchedBarSpots.map((barSpot) {
                      final flSpot = barSpot;
                      return LineTooltipItem(
                        Grade.translationTable[gradingSystem.index][flSpot.y.toInt()],
                        const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        textAlign: TextAlign.left,
                      );
                    }).toList();
                  }),
            ),
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(show: true,
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true,
                  reservedSize: 50,
                  interval: lineChartData.length / 4,
                  getTitlesWidget: bottomTitleWidgets,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true,
                  interval: 5,
                  getTitlesWidget: leftTitleWidgets,
                  reservedSize: 40,
                ),
              ),
            ),
            borderData: FlBorderData(show: true, border: Border.all(color: Colors.black12)),
            minY: 0,
            maxY: detailedGrades.fold(10.0, (previousValue, element) {
              int elementValue = Grade.translationTable[element.grade.system.index].indexOf(element.grade.grade);
              return elementValue > previousValue! ? elementValue.toDouble() : previousValue;
            }),
            lineBarsData: [
              LineChartBarData(spots: spots,
                isCurved: true,
                gradient: LinearGradient(colors: gradientColors),
                barWidth: 5,
                isStrokeCapRound: true,
                dotData: FlDotData(show: true),
                belowBarData: BarAreaData(show: true,
                  gradient: LinearGradient(colors: gradientColors.map((color) => color.withOpacity(0.3)).toList()),
                ),
              ),
            ],
          );
        }

        Widget gradeLineChart = Container();
        if (lineChartData.isNotEmpty)gradeLineChart = LineChart(mainData(lineChartData));
        return gradeLineChart;
      }
    );

    return Scaffold(body: Center(
      child: Padding(padding: const EdgeInsets.all(10), child: ListView(children: [
        heatMapBuilder,
        switchStyleRow,
        switchTypeRow,
        Card(child: Container(
          height: 200,
          padding: const EdgeInsets.only(left: 10, top: 10, right: 30, bottom: 10),
          child: gradeLineChart
        )),
      ]))
    ));
  }
}