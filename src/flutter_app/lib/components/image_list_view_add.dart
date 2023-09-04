import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/media_service.dart';
import 'add/add_image.dart';
import 'detail/media_details.dart';
import 'my_button_styles.dart';
import 'my_skeleton.dart';

class ImageListViewAdd extends StatefulWidget {
  const ImageListViewAdd({super.key, required this.onDelete, required this.mediaIds, required this.getImage});

  final List<String> mediaIds;
  final ValueSetter<String> onDelete;
  final ValueSetter<ImageSource> getImage;

  @override
  State<StatefulWidget> createState() => _ImageListViewAddState();
}

class _ImageListViewAddState extends State<ImageListViewAdd>{
  final MediaService mediaService = MediaService();

  Future<List<String>> fetchURLs() {
    List<Future<String>> futures = [];
    for (var mediaId in widget.mediaIds) {
      futures.add(mediaService.getMediumUrl(mediaId));
    }
    return Future.wait(futures);
  }

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> imageWidgets = [];
    Future<List<String>> futureMediaUrls = fetchURLs();

    imageWidgets.add(FutureBuilder<List<String>>(
      future: futureMediaUrls,
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text(snapshot.error.toString());
        if (!snapshot.hasData) {
          List<Widget> skeletons = [];
          for (var i = 0; i < widget.mediaIds.length; i++){
            skeletons.add(const MySkeleton());
          }
          return Padding(padding: const EdgeInsets.all(10),
            child: Row(mainAxisSize: MainAxisSize.min, children: skeletons)
          );
        }
        List<String> urls = snapshot.data!;
        List<Widget> images = [];
        for (var url in urls){
          images.add(InkWell(
            onTap: () => showDialog(
              context: context,
              builder: (BuildContext context) => MediaDetails(
                url: url,
                onDelete: widget.onDelete,
              )
            ),
            child: Ink(
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.fitHeight,
                    placeholder: (context, url) => const MySkeleton(),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
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
        MaterialPageRoute(builder: (context) => AddImage(onAddImage: widget.getImage))
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