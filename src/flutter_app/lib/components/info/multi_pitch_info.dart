import 'package:climbing_diary/interfaces/grading_system.dart';
import 'package:climbing_diary/services/pitch_service.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../interfaces/grade.dart';
import '../../interfaces/pitch/pitch.dart';
import '../MyTextStyles.dart';

class MultiPitchInfo extends StatelessWidget {
  MultiPitchInfo({super.key, required this.pitchIds});

  final List<String> pitchIds;
  final PitchService pitchService = PitchService();

  @override
  Widget build(BuildContext context) {
    List<Widget> listInfo = [];

    return FutureBuilder<List<Pitch>>(
      future: Future.wait(pitchIds.map((pitchId) => pitchService.getPitch(pitchId))),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Pitch> pitches = snapshot.data!;
          Grade grade = Grade(grade: "1", system: GradingSystem.french);
          int length = 0;
          pitches.forEach((pitch) {
            Grade otherGrade = pitch.grade;
            grade += otherGrade;
            length += pitch.length;
          });
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
              "📖 ${grade.grade} ${grade.system.toShortString()} 📏 ${length}m",
                style: MyTextStyles.description,
              ),
            ],
          );

        } else {
          return const CircularProgressIndicator();
        }
      },
    );   // info



  }
}