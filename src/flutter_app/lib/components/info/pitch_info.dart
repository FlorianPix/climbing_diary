import 'package:climbing_diary/interfaces/grading_system.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../interfaces/ascent/ascent.dart';
import '../../interfaces/ascent/ascent_style.dart';
import '../../interfaces/ascent/ascent_type.dart';
import '../../interfaces/grade.dart';
import '../../interfaces/pitch/pitch.dart';
import '../../services/ascent_service.dart';
import '../common/my_text_styles.dart';

class PitchInfo extends StatefulWidget {
  const PitchInfo({super.key, required this.pitch, required this.onNetworkChange});

  final Pitch pitch;
  final ValueSetter<bool> onNetworkChange;

  @override
  State<StatefulWidget> createState() => _PitchInfoState();
}

class _PitchInfoState extends State<PitchInfo>{
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
      future: ascentService.getAscentsOfIds(widget.pitch.ascentIds, false),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text(snapshot.error.toString());
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
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
        String title = widget.pitch.name;
        if (displayedAscent != null) {
          title += " ${AscentStyle.values[displayedAscent.style].toEmoji()}${AscentType.values[displayedAscent.type].toEmoji()}";
        }

        listInfo.add(Text(title, style: MyTextStyles.title,));

        String gradeString = widget.pitch.grade.grade;
        int gradingSystemIndex = widget.pitch.grade.system.index;
        int gradeIndex = Grade.translationTable[gradingSystemIndex].indexOf(gradeString);
        if(0 > gradeIndex || gradeIndex > 40) gradeIndex = 0;
        String translatedGrade = Grade.translationTable[gradingSystem.index][gradeIndex];

        listInfo.add(Text(
          "#️ ${widget.pitch.num} 📖 $translatedGrade ${gradingSystem.toShortString()} 📏 ${widget.pitch.length}m",
          style: MyTextStyles.description,
        ));

        if (widget.pitch.comment.isNotEmpty){
          listInfo.add(Text(widget.pitch.comment, style: MyTextStyles.description));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: listInfo,
        );
      }
    );
  }
}