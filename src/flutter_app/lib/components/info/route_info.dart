import 'package:climbing_diary/services/route_service.dart';
import 'package:flutter/material.dart';

import '../../interfaces/ascent/ascent.dart';
import '../../interfaces/ascent/ascent_style.dart';
import '../../interfaces/ascent/ascent_type.dart';
import '../../interfaces/multi_pitch_route/multi_pitch_route.dart';
import '../my_text_styles.dart';

class RouteInfo extends StatefulWidget {
  const RouteInfo({super.key, required this.route});

  final MultiPitchRoute route;

  @override
  State<StatefulWidget> createState() => _RouteInfoState();
}

class _RouteInfoState extends State<RouteInfo>{
  RouteService routeService = RouteService();

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Ascent?>(
        future: routeService.getBestAscent(widget.route),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Ascent? ascent = snapshot.data;
            List<Widget> listInfo = [];
            String title = widget.route.name;
            if (ascent != null) {
              title += " ${AscentStyle.values[ascent.style].toEmoji()}${AscentType.values[ascent.type].toEmoji()}";
            }

            listInfo.add(Text(
              title,
              style: MyTextStyles.title,
            ));

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: listInfo,
            );
          } else {
            List<Widget> listInfo = [];
            listInfo.add(Text(
              widget.route.name,
              style: MyTextStyles.title,
            ));
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: listInfo,
            );
          }
        }
    );
  }
}