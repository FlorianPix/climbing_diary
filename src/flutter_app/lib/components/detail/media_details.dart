import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:photo_view/photo_view.dart';
import 'package:climbing_diary/interfaces/media/media.dart';
import 'package:climbing_diary/services/media_service.dart';

class MediaDetails extends StatelessWidget {
  MediaDetails({super.key, required this.medium, required this.onDelete });

  final Media medium;
  final ValueSetter<String> onDelete;
  final MediaService mediaService = MediaService();

  @override
  Widget build(BuildContext context) {
    List<Widget> elements = [];
    elements.add(ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: PhotoView(imageProvider: Image.memory(medium.image).image),
    ));
    elements.add(Positioned(child: Card(child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () async {
            Navigator.pop(context);
            await mediaService.deleteMedium(Media.fromCache(Hive.box(Media.boxName).get(medium.id)));
            onDelete.call(medium.id);
          },
          icon: const Icon(Icons.delete),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ],
    ))));

    return Stack(
      alignment: Alignment.bottomCenter,
      children: elements,
    );
  }
}