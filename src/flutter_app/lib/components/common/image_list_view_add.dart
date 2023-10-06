import 'package:climbing_diary/interfaces/media/media.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/media_service.dart';
import '../add/add_image.dart';
import '../detail/media_details.dart';
import 'package:climbing_diary/components/common/my_button_styles.dart';
import 'my_skeleton.dart';

class ImageListViewAdd extends StatelessWidget {
  ImageListViewAdd({super.key, required this.onDelete, required this.mediaIds, required this.getImage});

  final List<String> mediaIds;
  final ValueSetter<String> onDelete;
  final ValueSetter<ImageSource> getImage;
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
    List<Widget> imageWidgets = [];
    imageWidgets.add(FutureBuilder<List<Media>>(
      future: fetchMedia(mediaIds),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text(snapshot.error.toString());
        if (!snapshot.hasData) {
          List<Widget> skeletons = [];
          for (var i = 0; i < mediaIds.length; i++){
            skeletons.add(const MySkeleton());
          }
          return Padding(padding: const EdgeInsets.all(10),
            child: Row(mainAxisSize: MainAxisSize.min, children: skeletons)
          );
        }
        List<Media> media = snapshot.data!;
        List<Widget> images = [];
        for (var medium in media){
          images.add(InkWell(
            onTap: () => showDialog(
              context: context,
              builder: (BuildContext context) => MediaDetails(
                medium: medium,
                onDelete: onDelete,
              )
            ),
            child: Ink(
              child: Padding(
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
              )
            ),
          ));
        }
        return Padding(padding: const EdgeInsets.all(10), child: Row(
          mainAxisSize: MainAxisSize.min,
          children: images
        ));
      }
    ));
    imageWidgets.add(ElevatedButton.icon(
      icon: const Icon(Icons.add, size: 30.0, color: Colors.pink),
      label: const Text('Add image'),
      onPressed: () => Navigator.push(context,
        MaterialPageRoute(builder: (context) => AddImage(onAddImage: getImage))
      ),
      style: ButtonStyle(shape: MyButtonStyles.rounded)
    ));
    return SizedBox(
      height: 250,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: imageWidgets
      )
    );
  }
}