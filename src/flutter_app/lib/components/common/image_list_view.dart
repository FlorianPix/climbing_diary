import 'package:climbing_diary/components/common/my_skeleton.dart';
import 'package:flutter/material.dart';

import '../../interfaces/media/media.dart';
import '../../services/media_service.dart';

class ImageListView extends StatelessWidget {
  ImageListView({super.key, required this.mediaIds});

  final List<String> mediaIds;
  final MediaService mediaService = MediaService();

  Future<List<Media>> fetchMedia(mediaIds) {
    List<Future<Media>> futures = [];
    for (var mediaId in mediaIds) {
      futures.add(mediaService.getMedium(mediaId));
    }
    return Future.wait(futures);
  }

  @override
  Widget build(BuildContext context) {
    Future<List<Media>> futureMedia = fetchMedia(mediaIds);
    Widget images = FutureBuilder<List<Media>>(
      future: futureMedia,
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text(snapshot.error.toString());
        if (!snapshot.hasData) {
          List<Widget> skeletons = [];
          for (var i = 0; i < mediaIds.length; i++) {
            skeletons.add(const MySkeleton());
          }
          return Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: skeletons
            )
          );
        }
        List<Media> media = snapshot.data!;
        List<Widget> images = [];
        for (var medium in media) {
          images.add(Padding(
            padding: const EdgeInsets.all(5.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.memory(
                medium.image,
                fit: BoxFit.fitHeight,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (wasSynchronouslyLoaded) return child;
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 2000),
                    child: frame != null ? child : const MySkeleton(),
                  );
                },
                errorBuilder: (context, object, error) => const Icon(Icons.error),
              )
            ),
          ));
        }
        return Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: images
          )
        );
      }
    );
    return SizedBox(
      height: 300,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [images]
      )
    );
  }
}