import 'package:climbing_diary/components/common/my_text_styles.dart';
import 'package:climbing_diary/interfaces/multi_pitch_route/update_multi_pitch_route.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../interfaces/multi_pitch_route/multi_pitch_route.dart';
import '../../interfaces/spot/spot.dart';
import '../../interfaces/trip/trip.dart';
import '../../pages/diary_page/timeline/pitch_timeline.dart';
import '../../services/media_service.dart';
import '../../services/multi_pitch_route_service.dart';
import '../../services/pitch_service.dart';
import '../add/add_image.dart';
import '../common/comment.dart';
import 'package:climbing_diary/components/common/image_list_view_add.dart';
import 'package:climbing_diary/components/common/my_button_styles.dart';
import '../add/add_pitch.dart';
import '../edit/edit_multi_pitch_route.dart';
import '../info/multi_pitch_route_info.dart';
import 'package:climbing_diary/components/common/rating.dart';

class MultiPitchRouteDetails extends StatefulWidget {
  const MultiPitchRouteDetails({super.key, this.trip, required this.spot, required this.route, required this.onDelete, required this.onUpdate, required this.spotId, required this.onNetworkChange });

  final Trip? trip;
  final Spot spot;
  final MultiPitchRoute route;
  final ValueSetter<MultiPitchRoute> onDelete;
  final ValueSetter<MultiPitchRoute> onUpdate;
  final String spotId;
  final ValueSetter<bool> onNetworkChange;

  @override
  State<StatefulWidget> createState() => _MultiPitchRouteDetailsState();
}

class _MultiPitchRouteDetailsState extends State<MultiPitchRouteDetails>{
  final MediaService mediaService = MediaService();
  final MultiPitchRouteService multiPitchRouteService = MultiPitchRouteService();
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
        var mediaId = await mediaService.uploadMedium(img);
        MultiPitchRoute multiPitchRoute = widget.route;
        multiPitchRoute.mediaIds.add(mediaId);
        multiPitchRouteService.editMultiPitchRoute(multiPitchRoute.toUpdateMultiPitchRoute());
      }
    } else {
      List<XFile> images = await picker.pickMultiImage();
      for (XFile img in images){
        var mediaId = await mediaService.uploadMedium(img);
        MultiPitchRoute multiPitchRoute = widget.route;
        multiPitchRoute.mediaIds.add(mediaId);
        multiPitchRouteService.editMultiPitchRoute(multiPitchRoute.toUpdateMultiPitchRoute());
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
      builder: (BuildContext context) => EditMultiPitchRoute(
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
    MultiPitchRoute route = widget.route;
    elements.add(Text(route.name, style: MyTextStyles.title));
    if (route.pitchIds.isNotEmpty) elements.add(MultiPitchInfo(pitchIds: route.pitchIds, onNetworkChange: widget.onNetworkChange));
    if (route.location.isNotEmpty) elements.add(Text(route.location, style: MyTextStyles.description));
    elements.add(Rating(rating: route.rating));
    if (route.comment.isNotEmpty) elements.add(Comment(comment: route.comment));

    void deleteImageCallback(String mediumId) {
      widget.route.mediaIds.remove(mediumId);
      multiPitchRouteService.editMultiPitchRoute(UpdateMultiPitchRoute(
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
      label: const Text('Add new pitch'),
      onPressed: () => Navigator.push(context,
        MaterialPageRoute(builder: (context) => AddPitch(route: widget.route))
      ),
      style: ButtonStyle(shape: MyButtonStyles.rounded)
    ));
    elements.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            Navigator.pop(context);
            multiPitchRouteService.deleteMultiPitchRoute(route, widget.spotId);
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
    if (route.pitchIds.isNotEmpty){
      elements.add(PitchTimeline(
        trip: widget.trip,
        spot: widget.spot,
        route: route,
        pitchIds: route.pitchIds,
        onNetworkChange: widget.onNetworkChange,
      ));
    }
    return Stack(children: [Padding(padding: const EdgeInsets.all(20), child: ListView(children: elements))]);
  }
}