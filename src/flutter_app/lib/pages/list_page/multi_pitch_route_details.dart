import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../components/info/multi_pitch_route_info.dart';
import '../../components/my_skeleton.dart';
import '../../interfaces/multi_pitch_route/multi_pitch_route.dart';
import '../../services/media_service.dart';
import '../../services/pitch_service.dart';
import '../../services/route_service.dart';

class MultiPitchRouteDetails extends StatefulWidget {
  const MultiPitchRouteDetails({super.key, required this.route});

  final MultiPitchRoute route;

  @override
  State<StatefulWidget> createState() => _MultiPitchRouteDetailsState();
}

class _MultiPitchRouteDetailsState extends State<MultiPitchRouteDetails>{
  final MediaService mediaService = MediaService();
  final RouteService routeService = RouteService();
  final PitchService pitchService = PitchService();

  Future<List<String>> fetchURLs() {
    List<Future<String>> futures = [];
    for (var mediaId in widget.route.mediaIds) {
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
      MultiPitchRoute route = widget.route;
      route.mediaIds.add(mediaId);
      routeService.editMultiPitchRoute(route.toUpdateMultiPitchRoute());
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

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> elements = [];
    MultiPitchRoute route = widget.route;

    // general info
    elements.addAll([
      Text(
        route.name,
        style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600
        ),
      ),
      MultiPitchInfo(
          pitchIds: route.pitchIds
      ),
      Text(
        route.location,
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400
        ),
      )]);
    // rating
    List<Widget> ratingRowElements = [];

    for (var i = 0; i < 5; i++){
      if (route.rating > i) {
        ratingRowElements.add(const Icon(Icons.favorite, size: 30.0, color: Colors.pink));
      } else {
        ratingRowElements.add(const Icon(Icons.favorite, size: 30.0, color: Colors.grey));
      }
    }

    elements.add(Center(child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child:Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ratingRowElements,
        )
    )));

    if (route.comment.isNotEmpty) {
      elements.add(Container(
          margin: const EdgeInsets.all(15.0),
          padding: const EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blueAccent),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            route.comment,
          )
      ));
    }
    // images
    if (route.mediaIds.isNotEmpty) {
      List<Widget> imageWidgets = [];
      Future<List<String>> futureMediaUrls = fetchURLs();

      imageWidgets.add(
        FutureBuilder<List<String>>(
          future: futureMediaUrls,
          builder: (context, snapshot) {
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
                          return const MySkeleton();
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
            for (var i = 0; i < route.mediaIds.length; i++){
              skeletons.add(const MySkeleton());
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
      elements.add(
        SizedBox(
          height: 250,
          child: ListView(
              scrollDirection: Axis.horizontal,
              children: imageWidgets
          )
        ),
      );
    }
    return Column(
        children: elements
    );
  }
}