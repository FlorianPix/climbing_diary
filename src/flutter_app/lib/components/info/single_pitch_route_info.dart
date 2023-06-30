import 'package:climbing_diary/interfaces/grading_system.dart';
import 'package:climbing_diary/services/ascent_service.dart';
import 'package:flutter/material.dart';

import '../../interfaces/ascent/ascent.dart';
import '../../interfaces/ascent/ascent_style.dart';
import '../../interfaces/ascent/ascent_type.dart';
import '../../interfaces/single_pitch_route/single_pitch_route.dart';
import '../../interfaces/trip/trip.dart';
import '../MyTextStyles.dart';

class SinglePitchRouteInfo extends StatefulWidget {
  const SinglePitchRouteInfo(
      {super.key, this.trip, required this.route});

  final Trip? trip;
  final SinglePitchRoute route;

  @override
  State<StatefulWidget> createState() => _SinglePitchRouteInfoState();
}

class _SinglePitchRouteInfoState extends State<SinglePitchRouteInfo>{
  AscentService ascentService = AscentService();

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Ascent>>(
        future: Future.wait(widget.route.ascentIds.map((ascentId) => ascentService.getAscent(ascentId))),
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
            String title = widget.route.name;
            if (displayedAscent != null) {
              title += " ${AscentStyle.values[displayedAscent.style].toEmoji()} ${AscentType.values[displayedAscent.type].toEmoji()}";
            }

            listInfo.add(Text(
              title,
              style: MyTextStyles.title,
            ));

            listInfo.add(Text(
              "📖 ${widget.route.grade.grade} ${widget.route.grade.system.toShortString()} 📏 ${widget.route.length}m",
              style: MyTextStyles.description,
            ));



            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: listInfo,
            );
          }
          return const CircularProgressIndicator();
        }
    );
  }
}