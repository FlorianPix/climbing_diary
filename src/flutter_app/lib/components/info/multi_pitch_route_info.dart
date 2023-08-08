import 'package:climbing_diary/interfaces/grading_system.dart';
import 'package:climbing_diary/services/pitch_service.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../interfaces/grade.dart';
import '../../interfaces/pitch/pitch.dart';
import '../my_text_styles.dart';

class MultiPitchInfo extends StatefulWidget {
  const MultiPitchInfo({super.key, required this.pitchIds, required this.onNetworkChange});

  final List<String> pitchIds;
  final ValueSetter<bool> onNetworkChange;

  @override
  State<StatefulWidget> createState() => _MultiPitchInfoState();
}

class _MultiPitchInfoState extends State<MultiPitchInfo>{
  final PitchService pitchService = PitchService();
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
    return FutureBuilder<List<Pitch>>(
      future: pitchService.getPitchesOfIds(online, widget.pitchIds),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text(snapshot.error.toString());
        if (!snapshot.hasData) return const CircularProgressIndicator();
        List<Pitch> pitches = snapshot.data!;
        Grade grade = const Grade(grade: "1", system: GradingSystem.french);
        int length = 0;
        for (var pitch in pitches) {
          Grade otherGrade = pitch.grade;
          if(otherGrade > grade) grade = otherGrade;
          length += pitch.length;
        }
        String gradeString = grade.grade;
        int gradingSystemIndex = grade.system.index;
        int gradeIndex = Grade.translationTable[gradingSystemIndex].indexOf(gradeString);
        String translatedGrade = Grade.translationTable[gradingSystem.index][gradeIndex];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(
            "📖 $translatedGrade ${gradingSystem.toShortString()} 📏 ${length}m",
            style: MyTextStyles.description,
          )],
        );
      },
    );   // info



  }
}