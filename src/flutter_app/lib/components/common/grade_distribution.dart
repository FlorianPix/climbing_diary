import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;

import '../../interfaces/grade.dart';
import '../../interfaces/grading_system.dart';
import '../../interfaces/multi_pitch_route/multi_pitch_route.dart';
import '../../interfaces/pitch/pitch.dart';
import '../../interfaces/single_pitch_route/single_pitch_route.dart';
import '../../services/multi_pitch_route_service.dart';
import '../../services/pitch_service.dart';
import '../../services/single_pitch_route_service.dart';

class GradeDistribution extends StatefulWidget{
  const GradeDistribution({super.key, required this.multiPitchRouteIds, required this.singlePitchRouteIds, required this.onNetworkChange});

  final List<String> multiPitchRouteIds;
  final List<String> singlePitchRouteIds;
  final ValueSetter<bool> onNetworkChange;

  @override
  State<StatefulWidget> createState() => _GradeDistributionState();
}

class _GradeDistributionState extends State<GradeDistribution> {
  final MultiPitchRouteService multiPitchRouteService = MultiPitchRouteService();
  final SinglePitchRouteService singlePitchRouteService = SinglePitchRouteService();
  final PitchService pitchService = PitchService();
  Map<int, double> distribution = {
    0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0, 8: 0, 9: 0,
    10: 0, 11: 0, 12: 0, 13: 0, 14: 0, 15: 0, 16: 0, 17: 0, 18: 0, 19: 0,
    20: 0, 21: 0, 22: 0, 23: 0, 24: 0, 25: 0, 26: 0, 27: 0, 28: 0, 29: 0,
    30: 0, 31: 0, 32: 0, 33: 0, 34: 0, 35: 0, 36: 0, 37: 0, 38: 0, 39: 0,
  };

  GradingSystem gradingSystem = GradingSystem.french;
  late SharedPreferences prefs;

  fetchGradingSystemPreference() async {
    prefs = await SharedPreferences.getInstance();
    int? fetchedGradingSystem = prefs.getInt('gradingSystem');
    if (fetchedGradingSystem != null) {
      gradingSystem = GradingSystem.values[fetchedGradingSystem];
    }
    setState(() {});
  }

  void fetchDistribution() async {
    Map<int, double> _distribution = {};
    for (int i = 0; i < 40; i++){
      _distribution[i] = 0;
    }

    List<SinglePitchRoute> singlePitchRoutes = await singlePitchRouteService.getSinglePitchRoutesOfIds(widget.singlePitchRouteIds);
    for (SinglePitchRoute singlePitchRoute in singlePitchRoutes) {
      int gradeIndex = Grade.translationTable[singlePitchRoute.grade.system.index].indexOf(singlePitchRoute.grade.grade);
      _distribution[gradeIndex] = _distribution[gradeIndex]! + 1;
    }

    List<MultiPitchRoute> multiPitchRoutes = await multiPitchRouteService.getMultiPitchRoutesOfIds(online, widget.multiPitchRouteIds);
    for (MultiPitchRoute multiPitchRoute in multiPitchRoutes) {
      int maxGradeIndex = -1;
      List<Pitch> pitches = await pitchService.getPitchesOfIds(multiPitchRoute.pitchIds, false);
      for (Pitch pitch in pitches) {
        int gradeIndex = Grade.translationTable[pitch.grade.system.index].indexOf(pitch.grade.grade);
        maxGradeIndex = math.max(maxGradeIndex, gradeIndex);
      }
      if (maxGradeIndex >= 0) _distribution[maxGradeIndex] = _distribution[maxGradeIndex]! + 1;
    }
    setState(() => distribution = _distribution);
  }

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
    checkConnection();
    fetchDistribution();
    fetchGradingSystemPreference();
  }

  Widget getTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.blue,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    String text = Grade.translationTable[gradingSystem.index][value.toInt()];
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 6,
      child: Transform.rotate(
        angle: -math.pi / 2,
        child: Text(text, style: style),
      ),
    );
  }

  FlTitlesData get titlesData => FlTitlesData(
    show: true,
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 30,
        getTitlesWidget: getTitles,
      ),
    ),
    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
  );

  LinearGradient get _barsGradient => const LinearGradient(
    colors: [
      Colors.blue,
      Colors.cyan,
    ],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );

  List<BarChartGroupData> barGroups(Map<int, double> distribution) {
    List<BarChartGroupData> groups = [];
    for (int x = 0; x < 40; x+=1){
      if (distribution[x]! > 0){
        groups.add(BarChartGroupData(
          x: x,
          barRods: [
            BarChartRodData(
              toY: distribution[x]!,
              gradient: _barsGradient,
            )
          ],
          showingTooltipIndicators: [0],
        ));
      }
    }
    return groups;
  }

  BarTouchData get barTouchData => BarTouchData(
    enabled: false,
    touchTooltipData: BarTouchTooltipData(
      tooltipBgColor: Colors.transparent,
      tooltipPadding: EdgeInsets.zero,
      tooltipMargin: 8,
      getTooltipItem: (
        BarChartGroupData group,
        int groupIndex,
        BarChartRodData rod,
        int rodIndex,
      ) => BarTooltipItem(
        rod.toY.round().toString(),
        const TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.only(top: 20),
      child: SizedBox(
        height: 50 + (widget.singlePitchRouteIds.length + widget.multiPitchRouteIds.length).toDouble(),
        child: BarChart(BarChartData(
          barTouchData: barTouchData,
          titlesData: titlesData,
          borderData: FlBorderData(show: false),
          barGroups: barGroups(distribution),
          gridData: FlGridData(show: false),
          alignment: BarChartAlignment.center,
          maxY: (widget.singlePitchRouteIds.length + widget.multiPitchRouteIds.length).toDouble(),
        ))
      )
    );
  }
}