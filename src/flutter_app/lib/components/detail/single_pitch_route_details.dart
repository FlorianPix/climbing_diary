import 'package:climbing_diary/components/add/add_ascent_to_single_pitch_route.dart';
import 'package:climbing_diary/components/image_list_view.dart';
import 'package:climbing_diary/interfaces/single_pitch_route/update_single_pitch_route.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../interfaces/single_pitch_route/single_pitch_route.dart';
import '../../interfaces/spot/spot.dart';
import '../../interfaces/trip/trip.dart';
import '../../pages/diary_page/timeline/ascent_timeline.dart';
import '../../services/media_service.dart';
import '../../services/pitch_service.dart';
import '../../services/route_service.dart';
import '../my_button_styles.dart';
import '../edit/edit_single_pitch_route.dart';
import '../info/single_pitch_route_info.dart';
import '../rating.dart';

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
      routeService.editSinglePitchRoute(route.toUpdateSinglePitchRoute());
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


    elements.add(SinglePitchRouteInfo(route: route));
    if (route.location.isNotEmpty){
      elements.add(Text(route.location,
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400
        ),
      ));
    }

    elements.add(Rating(rating: route.rating));

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

    void deleteImageCallback(String mediumId) {
      widget.route.mediaIds.remove(mediumId);
      routeService.editSinglePitchRoute(UpdateSinglePitchRoute(
          id: widget.route.id,
          mediaIds: widget.route.mediaIds
      ));
      setState(() {});
    }

    if (route.mediaIds.isNotEmpty) {
      elements.add(ImageListView(
        onDelete: deleteImageCallback,
        mediaIds: widget.spot.mediaIds,
        getImage: getImage,
      ));
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // delete route button
            IconButton(
              onPressed: () {
                Navigator.pop(context);
                routeService.deleteSinglePitchRoute(route, widget.spotId);
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
      DateTime startDate = DateTime(1923);
      DateTime endDate = DateTime(2123);
      if (widget.trip != null) {
        DateTime.parse(widget.trip!.startDate);
        DateTime.parse(widget.trip!.endDate);
      }
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
          startDate: startDate,
          endDate: endDate,
          ofMultiPitch: false,
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