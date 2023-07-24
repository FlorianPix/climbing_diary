import 'package:climbing_diary/components/my_skeleton.dart';
import 'package:flutter/material.dart';

import '../../services/media_service.dart';

class ImageListView extends StatelessWidget {
  ImageListView({super.key, required this.mediaIds});

  final List<String> mediaIds;
  final MediaService mediaService = MediaService();

  Future<List<String>> fetchURLs(mediaIds) {
    List<Future<String>> futures = [];
    for (var mediaId in mediaIds) {
      futures.add(mediaService.getMediumUrl(mediaId));
    }
    return Future.wait(futures);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> imageWidgets = [];
    Future<List<String>> futureMediaUrls = fetchURLs(mediaIds);

    imageWidgets.add(
        FutureBuilder<List<String>>(
            future: futureMediaUrls,
            builder: (context, snapshot) {
              if (snapshot.data != null) {
                List<String> urls = snapshot.data!;
                List<Widget> images = [];
                for (var url in urls) {
                  images.add(
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              url,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                }
                                return const MySkeleton();
                              },
                            )
                        ),
                      )
                  );
                }
                return Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: images
                    )
                );
              }
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
        )
    );
    return SizedBox(
        height: 300,
        child: ListView(
            scrollDirection: Axis.horizontal,
            children: imageWidgets
        )
    );
  }
}