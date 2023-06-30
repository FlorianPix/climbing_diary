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

    // date, style and type
    listInfo.add(Text(
      "${ascent.date} ${AscentStyle.values[ascent.style].toEmoji()}${AscentType.values[ascent.type].toEmoji()}",
      style: MyTextStyles.title,
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