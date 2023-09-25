import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../../interfaces/ascent/ascent.dart';
import '../../interfaces/ascent/ascent_style.dart';
import '../../interfaces/ascent/ascent_type.dart';
import '../../interfaces/multi_pitch_route/multi_pitch_route.dart';
import '../../services/multi_pitch_route_service.dart';
import '../my_text_styles.dart';

class RouteInfo extends StatefulWidget {
  const RouteInfo({super.key, required this.route, required this.onNetworkChange});

  final MultiPitchRoute route;
  final ValueSetter<bool> onNetworkChange;

  @override
  State<StatefulWidget> createState() => _RouteInfoState();
}

class _RouteInfoState extends State<RouteInfo>{
  final MultiPitchRouteService multiPitchRouteService = MultiPitchRouteService();
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
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Ascent?>(
      future: multiPitchRouteService.getBestAscent(widget.route, online),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Ascent? ascent = snapshot.data;
          List<Widget> listInfo = [];
          String title = widget.route.name;
          if (ascent != null) {
            title += " ${AscentStyle.values[ascent.style].toEmoji()}${AscentType.values[ascent.type].toEmoji()}";
          }

          listInfo.add(Text(title, style: MyTextStyles.title));

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