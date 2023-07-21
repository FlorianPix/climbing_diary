import 'package:climbing_diary/interfaces/grading_system.dart';
import 'package:flutter/material.dart';

import '../../interfaces/ascent/ascent.dart';
import '../../interfaces/ascent/ascent_style.dart';
import '../../interfaces/ascent/ascent_type.dart';
import '../../interfaces/pitch/pitch.dart';
import '../../services/ascent_service.dart';
import '../my_text_styles.dart';

class PitchInfo extends StatefulWidget {
  const PitchInfo({super.key, required this.pitch});

  final Pitch pitch;

  @override
  State<StatefulWidget> createState() => _PitchInfoState();
}

class _PitchInfoState extends State<PitchInfo>{
  AscentService ascentService = AscentService();

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Ascent>>(
        future: Future.wait(widget.pitch.ascentIds.map((ascentId) => ascentService.getAscent(ascentId))),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
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

            // name
            listInfo.add(Text(
              title,
              style: MyTextStyles.title,
            ));

            // grade and length
            listInfo.add(Text(
              "#️ ${widget.pitch.num} 📖 ${widget.pitch.grade.grade} ${widget.pitch.grade.system.toShortString()} 📏 ${widget.pitch.length}m",
              style: MyTextStyles.description,
            ));

            // comment
            listInfo.add(Text(
              widget.pitch.comment,
              style: MyTextStyles.description,
            ));

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: listInfo,
            );
          } else {
            return const CircularProgressIndicator();
          }
      }
    );
  }
}