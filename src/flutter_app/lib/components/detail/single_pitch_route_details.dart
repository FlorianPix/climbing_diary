import 'package:climbing_diary/components/add/add_ascent_to_single_pitch_route.dart';
import 'package:climbing_diary/components/common/my_text_styles.dart';
import 'package:climbing_diary/interfaces/single_pitch_route/update_single_pitch_route.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../interfaces/single_pitch_route/single_pitch_route.dart';
import '../../interfaces/spot/spot.dart';
import '../../interfaces/trip/trip.dart';
import '../../pages/diary_page/timeline/ascent_timeline.dart';
import '../../services/media_service.dart';
import '../../services/pitch_service.dart';
import '../../services/single_pitch_route_service.dart';
import '../add/add_image.dart';
import '../common/comment.dart';
import 'package:climbing_diary/components/common/image_list_view_add.dart';
import 'package:climbing_diary/components/common/my_button_styles.dart';
import '../edit/edit_single_pitch_route.dart';
import '../info/single_pitch_route_info.dart';
import 'package:climbing_diary/components/common/rating.dart';

class SinglePitchRouteDetails extends StatefulWidget {
  const SinglePitchRouteDetails({super.key, this.trip, required this.spot, required this.route, required this.onDelete, required this.onUpdate, required this.spotId, required this.onNetworkChange });

  final Trip? trip;
  final Spot spot;
  final SinglePitchRoute route;
  final ValueSetter<SinglePitchRoute> onDelete;
  final ValueSetter<SinglePitchRoute> onUpdate;
  final String spotId;
  final ValueSetter<bool> onNetworkChange;

  @override
  State<StatefulWidget> createState() => _SinglePitchRouteDetailsState();
}

class _SinglePitchRouteDetailsState extends State<SinglePitchRouteDetails>{
  final MediaService mediaService = MediaService();
  final SinglePitchRouteService singlePitchRouteService = SinglePitchRouteService();
  final PitchService pitchService = PitchService();

  Future<List<String>> fetchURLs() {
    List<Future<String>> futures = [];
    for (var mediaId in widget.route.mediaIds) {
      futures.add(mediaService.getMediumUrl(mediaId));
    }
    return Future.wait(futures);
  }

  final ImagePicker picker = ImagePicker();

  Future<void> getImage(ImageSource media) async {
    if (media == ImageSource.camera) {
      var img = await picker.pickImage(source: media);
      if (img != null) {
        var mediaId = await mediaService.uploadMedia(img);
        SinglePitchRoute singlePitchRoute = widget.route;
        singlePitchRoute.mediaIds.add(mediaId);
        singlePitchRouteService.editSinglePitchRoute(singlePitchRoute.toUpdateSinglePitchRoute());
      }
    } else {
      List<XFile> images = await picker.pickMultiImage();
      for (XFile img in images){
        var mediaId = await mediaService.uploadMedia(img);
        SinglePitchRoute singlePitchRoute = widget.route;
        singlePitchRoute.mediaIds.add(mediaId);
        singlePitchRouteService.editSinglePitchRoute(singlePitchRoute.toUpdateSinglePitchRoute());
      }
    }
    setState(() {});
  }

  void addImageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AddImage(onAddImage: getImage)
    );
  }

  void editRouteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => EditSinglePitchRoute(
        route: widget.route,
        onUpdate: widget.onUpdate
      )
    );
  }

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> elements = [];
    SinglePitchRoute route = widget.route;
    elements.add(SinglePitchRouteInfo(route: route, onNetworkChange: widget.onNetworkChange));
    if (route.location.isNotEmpty)elements.add(Text(route.location, style: MyTextStyles.description));
    elements.add(Rating(rating: route.rating));
    if (route.comment.isNotEmpty) elements.add(Comment(comment: route.comment));

    void deleteImageCallback(String mediumId) {
      widget.route.mediaIds.remove(mediumId);
      singlePitchRouteService.editSinglePitchRoute(UpdateSinglePitchRoute(
        id: widget.route.id,
        mediaIds: widget.route.mediaIds
      ));
      setState(() {});
    }

    if (route.mediaIds.isNotEmpty) {
      elements.add(ImageListViewAdd(
        onDelete: deleteImageCallback,
        mediaIds: widget.route.mediaIds,
        getImage: getImage,
      ));
    } else {
      elements.add(ElevatedButton.icon(
        icon: const Icon(Icons.add, size: 30.0, color: Colors.pink),
        label: const Text('Add image'),
        onPressed: () => addImageDialog(),
        style: ButtonStyle(shape: MyButtonStyles.rounded)
      ));
    }
    elements.add(ElevatedButton.icon(
      icon: const Icon(Icons.add, size: 30.0, color: Colors.pink),
      label: const Text('Add new ascent'),
      onPressed: () {
        Navigator.push(context,
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
      style: ButtonStyle(shape: MyButtonStyles.rounded)
    ));
    elements.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            Navigator.pop(context);
            singlePitchRouteService.deleteSinglePitchRoute(route, widget.spotId);
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
    ));
    // ascents
    if (route.ascentIds.isNotEmpty){
      DateTime startDate = DateTime(1923);
      DateTime endDate = DateTime(2123);
      if (widget.trip != null) {
        DateTime.parse(widget.trip!.startDate);
        DateTime.parse(widget.trip!.endDate);
      }
      elements.add(AscentTimeline(
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
        onNetworkChange: widget.onNetworkChange,
      ));
    }
    return Stack(children: <Widget>[Padding(padding: const EdgeInsets.all(20), child: ListView(children: elements))]);
  }
}