import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:skeletons/skeletons.dart';

import '../../interfaces/pitch/pitch.dart';
import '../../services/media_service.dart';
import '../../services/pitch_service.dart';
import '../edit/edit_pitch.dart';

class PitchDetails extends StatefulWidget {
  const PitchDetails({super.key, required this.pitch, required this.onDelete, required this.onUpdate });

  final Pitch pitch;
  final ValueSetter<Pitch> onDelete;
  final ValueSetter<Pitch> onUpdate;

  @override
  State<StatefulWidget> createState() => _PitchDetailsState();
}

class _PitchDetailsState extends State<PitchDetails>{
  final MediaService mediaService = MediaService();
  final PitchService pitchService = PitchService();

  Future<List<String>> fetchURLs() {
    List<Future<String>> futures = [];
    for (var mediaId in widget.pitch.mediaIds) {
      futures.add(mediaService.getMediumUrl(mediaId));
    }
    return Future.wait(futures);
  }

  XFile? image;
  final ImagePicker picker = ImagePicker();

  Future getImage(ImageSource media) async {
    var img = await picker.pickImage(source: media);
    if (img != null){
      var mediaId = await mediaService.uploadMedia(img);
      Pitch pitch = widget.pitch;
      pitch.mediaIds.add(mediaId);
      pitchService.editPitch(pitch.toUpdatePitch());
    }

    setState(() {
      image = img;
    });
  }

  void addImageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: const Text('Please choose media to select'),
          content: SizedBox(
            height: MediaQuery.of(context).size.height / 6,
            child: Column(
              children: [
                ElevatedButton(
                  //if user click this button, user can upload image from gallery
                  onPressed: () {
                    Navigator.pop(context);
                    getImage(ImageSource.gallery);
                  },
                  child: Row(
                    children: const [
                      Icon(Icons.image),
                      Text('From Gallery'),
                    ],
                  ),
                ),
                ElevatedButton(
                  //if user click this button. user can upload image from camera
                  onPressed: () {
                    Navigator.pop(context);
                    getImage(ImageSource.camera);
                  },
                  child: Row(
                    children: const [
                      Icon(Icons.camera),
                      Text('From Camera'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      });
  }

  void editPitchDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditPitch(pitch: widget.pitch, onUpdate: widget.onUpdate);
      });
  }

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> elements = [];

    // general info
    elements.addAll([
      Text(
        widget.pitch.name,
        style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600
        ),
      ),
    ]);
    // rating
    List<Widget> ratingRowElements = [];

    for (var i = 0; i < 5; i++){
      if (widget.pitch.rating > i) {
        ratingRowElements.add(const Icon(Icons.favorite, size: 30.0, color: Colors.pink));
      } else {
        ratingRowElements.add(const Icon(Icons.favorite, size: 30.0, color: Colors.grey));
      }
    }

    elements.add(Center(child: Padding(
        padding: const EdgeInsets.all(10),
        child:Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ratingRowElements,
        )
    )));

    if (widget.pitch.comment.isNotEmpty) {
      elements.add(Container(
          margin: const EdgeInsets.all(15.0),
          padding: const EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blueAccent),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            widget.pitch.comment,
          )
      ));
    }
    // images
    if (widget.pitch.mediaIds.isNotEmpty) {
      List<Widget> imageWidgets = [];
      Future<List<String>> futureMediaUrls = fetchURLs();

      imageWidgets.add(
        FutureBuilder<List<String>>(
          future: futureMediaUrls,
          builder: (context, snapshot) {
            Widget skeleton = const Padding(
                padding: EdgeInsets.all(5),
                child: SkeletonAvatar(
                  style: SkeletonAvatarStyle(
                      shape: BoxShape.rectangle, width: 150, height: 250
                  ),
                )
            );

            if (snapshot.data != null){
              List<String> urls = snapshot.data!;
              List<Widget> images = [];
              for (var url in urls){
                images.add(
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        url,
                        fit: BoxFit.fitHeight,
                        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
                          return skeleton;
                        },
                      )
                    ),
                  )
                );
              }
              return Container(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: images
                  )
              );
            }
            List<Widget> skeletons = [];
            for (var i = 0; i < widget.pitch.mediaIds.length; i++){
              skeletons.add(skeleton);
            }
            return Container(
                padding: const EdgeInsets.all(10),
                child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: skeletons
                )
            );
          }
        )
      );
      imageWidgets.add(
        IconButton(
          icon: const Icon(Icons.add, size: 30.0, color: Colors.pink),
          tooltip: 'add image',
          onPressed: () => addImageDialog()
        )
      );
      elements.add(
        SizedBox(
          height: 250,
          child: ListView(
              scrollDirection: Axis.horizontal,
              children: imageWidgets
          )
        ),
      );
    } else {
      elements.add(
        IconButton(
          icon: const Icon(Icons.add, size: 30.0, color: Colors.pink),
          tooltip: 'add image',
          onPressed: () => addImageDialog()
        ),
      );
    }
    elements.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // delete pitch button
            IconButton(
              onPressed: () {
                Navigator.pop(context);
                pitchService.deletePitch(widget.pitch);
                widget.onDelete.call(widget.pitch);
              },
              icon: const Icon(Icons.delete),
            ),
            IconButton(
              onPressed: () => editPitchDialog(),
              icon: const Icon(Icons.edit),
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
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: elements
              )
          )
        ]
    );
  }
}