import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

import '../../interfaces/spot/spot.dart';
import 'package:climbing_diary/components/common/my_text_styles.dart';

class SpotInfo extends StatelessWidget {
  const SpotInfo({super.key, required this.spot});

  final Spot spot;

  @override
  Widget build(BuildContext context) {
    List<Widget> listInfo = [];

    listInfo.add(Text(spot.name, style: MyTextStyles.title));
    listInfo.add(Row(children: [
      Text(
        '${round(spot.coordinates[0], decimals: 8)}, ${round(spot.coordinates[1], decimals: 8)}',
        style: MyTextStyles.description,
      ),
      IconButton(
          iconSize: 16,
          color: const Color(0xff989898),
          onPressed: () async => await Clipboard.setData(ClipboardData(text: "${spot.coordinates[0]},${spot.coordinates[1]}")),
          icon: const Icon(Icons.content_copy))
    ]));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: listInfo,
    );
  }
}