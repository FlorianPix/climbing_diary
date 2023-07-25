import 'package:flutter/material.dart';

import '../../services/media_service.dart';
import '../my_skeleton.dart';

class MediaDetails extends StatefulWidget {
  const MediaDetails({super.key, required this.url, required this.onDelete });

  final String url;
  final ValueSetter<String> onDelete;

  @override
  State<StatefulWidget> createState() => _MediaDetailsState();
}

class _MediaDetailsState extends State<MediaDetails>{
  final MediaService mediaService = MediaService();

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String mediumId = widget.url;
    mediumId = mediumId.split('/')[6];
    mediumId = mediumId.split('?')[0];

    List<Widget> elements = [];

    elements.add(Padding(
      padding: const EdgeInsets.all(5.0),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.network(
            widget.url,
            fit: BoxFit.fitHeight,
            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) {
                return child;
              }
              return const MySkeleton();
            },
          )
      ),
    ));

    // delete, edit, close
    elements.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // delete spot button
            IconButton(
              onPressed: () {
                Navigator.pop(context);
                mediaService.deleteMedium(mediumId);
                widget.onDelete.call(mediumId);
              },
              icon: const Icon(Icons.delete),
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
            ),
          ],
        )
    );

    return Stack(
        children: <Widget>[
          Container(
              padding: const EdgeInsets.all(20),
              child: ListView(
                  children: elements
              )
          )
        ]
    );
  }
}