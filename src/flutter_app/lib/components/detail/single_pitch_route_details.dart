import 'package:climbing_diary/components/add/add_ascent_to_single_pitch_route.dart';
import 'package:climbing_diary/components/select/select_ascent_of_single_pitch_route.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skeletons/skeletons.dart';

import '../../interfaces/single_pitch_route/single_pitch_route.dart';
import '../../interfaces/spot/spot.dart';
import '../../interfaces/trip/trip.dart';
import '../../services/media_service.dart';
import '../../services/pitch_service.dart';
import '../../services/route_service.dart';
import '../MyButtonStyles.dart';
import '../add/add_ascent.dart';
import '../add/add_pitch.dart';
import '../diary_page/ascent_timeline.dart';
import '../edit/edit_single_pitch_route.dart';
import '../info/single_pitch_route_info.dart';
import '../select/select_ascent.dart';
import '../select/select_pitch.dart';

class SinglePitchRouteDetails extends StatefulWidget {
  const SinglePitchRouteDetails({super.key, this.trip, required this.spot, required this.route, required this.onDelete, required this.onUpdate, required this.spotId });

  final Trip? trip;
  final Spot spot;
  final SinglePitchRoute route;
  final ValueSetter<SinglePitchRoute> onDelete;
  final ValueSetter<SinglePitchRoute> onUpdate;
  final String spotId;

  @override
  State<StatefulWidget> createState() => _SinglePitchRouteDetailsState();
}

class _SinglePitchRouteDetailsState extends State<SinglePitchRouteDetails>{
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
      SinglePitchRoute route = widget.route;
      route.mediaIds.add(mediaId);
      routeService.editRoute(route.toUpdateSinglePitchRoute());
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

  void editRouteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditSinglePitchRoute(
            route: widget.route,
            onUpdate: widget.onUpdate);
      });
  }

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> elements = [];
    SinglePitchRoute route = widget.route;

    // general info
    elements.addAll([
      Text(
        route.name,
        style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600
        ),
      ),
      SinglePitchRouteInfo(
          spot: widget.spot,
          route: route
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
            for (var i = 0; i < route.mediaIds.length; i++){
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
        ElevatedButton.icon(
            icon: const Icon(Icons.add, size: 30.0, color: Colors.pink),
            label: const Text('Add image'),
            onPressed: () => addImageDialog(),
            style: MyButtonStyles.rounded
        ),
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
        ElevatedButton.icon(
            icon: const Icon(Icons.add, size: 30.0, color: Colors.pink),
            label: const Text('Add image'),
            onPressed: () => addImageDialog(),
            style: MyButtonStyles.rounded
        ),
      );
    }
    // add ascent
    elements.add(
      ElevatedButton.icon(
          icon: const Icon(Icons.add, size: 30.0, color: Colors.pink),
          label: const Text('Add new ascent'),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddAscentToSinglePitchRoute(
                    singlePitchRoutes: [widget.route],
                    onAdd: (ascent) {
                      widget.route.ascentIds.add(ascent.id);
                      setState(() {});
                    },
                  ),
                )
            );
          },
          style: MyButtonStyles.rounded
      ),
    );
    elements.add(
      ElevatedButton.icon(
          icon: const Icon(Icons.add, size: 30.0, color: Colors.pink),
          label: const Text('Add existing ascent'),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SelectAscentOfSinglePitchRoute(singlePitchRoute: widget.route),
                )
            );
          },
          style: MyButtonStyles.rounded
      ),
    );
    elements.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // delete route button
            IconButton(
              onPressed: () {
                Navigator.pop(context);
                routeService.deleteRoute(route, widget.spotId);
                widget.onDelete.call(route);
              },
              icon: const Icon(Icons.delete),
            ),
            IconButton(
              onPressed: () => editRouteDialog(),
              icon: const Icon(Icons.edit),
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
            ),
          ],
        )
    );
    // ascents
    if (route.ascentIds.isNotEmpty){
      elements.add(
          AscentTimeline(
            trip: widget.trip,
            spot: widget.spot,
            route: widget.route,
            pitchId: route.id,
            ascentIds: route.ascentIds,
            onUpdate: (ascent) {},
            onDelete: (ascent) {
              route.ascentIds.remove(ascent.id);
              setState(() {});
            },
          )
      );
    }

    return Stack(
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                  children: elements
              )
          )
        ]
    );
  }
}