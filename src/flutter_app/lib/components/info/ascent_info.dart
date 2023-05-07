import 'package:climbing_diary/interfaces/ascent/ascent_style.dart';
import 'package:flutter/material.dart';

import '../../interfaces/ascent/ascent.dart';
import '../../interfaces/ascent/ascent_type.dart';
import '../MyTextStyles.dart';

class AscentInfo extends StatelessWidget {
  const AscentInfo({super.key,
    required this.ascent
  });

  final Ascent ascent;

  @override
  Widget build(BuildContext context) {
    List<Widget> listInfo = [];

    // name
    listInfo.add(Text(
      ascent.date,
      style: MyTextStyles.title,
    ));

    String style = "❓";
    switch (AscentStyle.values[ascent.style]) {
      case AscentStyle.boulder:
        style = "🪨";
        break;
      case AscentStyle.solo:
        style = "🔥";
        break;
      case AscentStyle.lead:
        style = "🥇";
        break;
      case AscentStyle.second:
        style = "🥈";
        break;
      case AscentStyle.topRope:
        style = "🥉";
        break;
      case AscentStyle.aid:
        style = "🩹";
        break;
    }

    String type = "❓";
    switch (AscentType.values[ascent.type]) {
      case AscentType.onSight:
        type = "👁️";
        break;
      case AscentType.flash:
        type = "⚡";
        break;
      case AscentType.redPoint:
        type = "🔴";
        break;
      case AscentType.tick:
        type = "✔️";
        break;
      case AscentType.bail:
        type = "❌";
        break;
    }

    // style and type
    listInfo.add(Text(
      "$style $type",
      style: MyTextStyles.description,
    ));

    // comment
    listInfo.add(Text(
      ascent.comment,
      style: MyTextStyles.description,
    ));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: listInfo,
    );
  }
}