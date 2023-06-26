import 'package:flutter/material.dart';

import '../../interfaces/route/route.dart';
import '../MyTextStyles.dart';

class RouteInfo extends StatelessWidget {
  const RouteInfo({super.key,
    required this.route
  });

  final ClimbingRoute route;

  @override
  Widget build(BuildContext context) {
    List<Widget> listInfo = [];

    // name
    listInfo.add(Text(
      route.name,
      style: MyTextStyles.title,
    ));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: listInfo,
    );
  }
}