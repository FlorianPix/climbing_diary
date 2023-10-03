import 'package:climbing_diary/interfaces/grading_system.dart';
import 'package:climbing_diary/services/ascent_service.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../interfaces/ascent/ascent.dart';
import '../../interfaces/ascent/ascent_style.dart';
import '../../interfaces/ascent/ascent_type.dart';
import '../../interfaces/grade.dart';
import '../../interfaces/single_pitch_route/single_pitch_route.dart';
import '../../interfaces/trip/trip.dart';
import '../common/my_text_styles.dart';

class SinglePitchRouteInfo extends StatefulWidget {
  const SinglePitchRouteInfo({super.key, this.trip, required this.route, required this.onNetworkChange});

  final Trip? trip;
  final SinglePitchRoute route;
  final ValueSetter<bool> onNetworkChange;

  @override
  State<StatefulWidget> createState() => _SinglePitchRouteInfoState();
}

class _SinglePitchRouteInfoState extends State<SinglePitchRouteInfo>{
  AscentService ascentService = AscentService();

  GradingSystem gradingSystem = GradingSystem.french;
  late SharedPreferences prefs;
  bool online = false;

  void checkConnection() async {
    await InternetConnectionChecker().hasConnection.then((value) {
      widget.onNetworkChange.call(value);
      setState(() => online = value);
    });
  }

  fetchGradingSystemPreference() async {
    prefs = await SharedPreferences.getInstance();
    int? fetchedGradingSystem = prefs.getInt('gradingSystem');
    if (fetchedGradingSystem != null) gradingSystem = GradingSystem.values[fetchedGradingSystem];
    setState(() {});
  }

  @override
  void initState(){
    super.initState();
    fetchGradingSystemPreference();
    checkConnection();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Ascent>>(
      future: ascentService.getAscentsOfIds(widget.route.ascentIds, false),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text(snapshot.error.toString());
        if (!snapshot.hasData) return const CircularProgressIndicator();
        List<Ascent> ascents = snapshot.data!;
        int style = 6;
        int type = 4;
        Ascent? displayedAscent;
        for (Ascent ascent in ascents){
          if (ascent.style < style){
            displayedAscent = ascent;
            style = displayedAscent.style;
            type = displayedAscent.type;
          }
          if (ascent.style == style && ascent.type < type){
            displayedAscent = ascent;
            style = displayedAscent.style;
            type = displayedAscent.type;
          }
        }

        List<Widget> listInfo = [];
        String title = widget.route.name;
        if (displayedAscent != null) {
          title += " ${AscentStyle.values[displayedAscent.style].toEmoji()}${AscentType.values[displayedAscent.type].toEmoji()}";
        }

        listInfo.add(Text(title, style: MyTextStyles.title));

        String gradeString = widget.route.grade.grade;
        int gradingSystemIndex = widget.route.grade.system.index;
        int gradeIndex = Grade.translationTable[gradingSystemIndex].indexOf(gradeString);
        String translatedGrade = Grade.translationTable[gradingSystem.index][gradeIndex];
        listInfo.add(Text(
          "📖 $translatedGrade ${gradingSystem.toShortString()} 📏 ${widget.route.length}m",
          style: MyTextStyles.description,
        ));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: listInfo,
        );
      }
    );
  }
}