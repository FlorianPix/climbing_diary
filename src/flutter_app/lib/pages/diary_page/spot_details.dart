import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../../components/add/add_image.dart';
import '../../components/comment.dart';
import '../../components/grade_distribution.dart';
import '../../components/image_list_view_add.dart';
import '../../components/my_button_styles.dart';
import '../../components/edit/edit_spot.dart';
import '../../components/my_text_styles.dart';
import '../../components/rating.dart';
import '../../components/transport.dart';
import '../../interfaces/spot/spot.dart';
import '../../interfaces/spot/update_spot.dart';
import '../../interfaces/trip/trip.dart';
import '../../services/media_service.dart';
import '../../services/spot_service.dart';
import 'timeline/route_timeline.dart';

class SpotDetails extends StatefulWidget {
  const SpotDetails({super.key, this.trip, required this.spot, required this.onDelete, required this.onUpdate, required this.onNetworkChange });

  final Trip? trip;
  final Spot spot;
  final ValueSetter<Spot> onDelete, onUpdate;
  final ValueSetter<bool> onNetworkChange;

  @override
  State<StatefulWidget> createState() => _SpotDetailsState();
}

class _SpotDetailsState extends State<SpotDetails>{
  final MediaService mediaService = MediaService();
  final SpotService spotService = SpotService();

  Future<List<String>> fetchURLs() {
    List<Future<String>> futures = [];
    for (var mediaId in widget.spot.mediaIds) {
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
        Spot spot = widget.spot;
        spot.mediaIds.add(mediaId);
        spotService.editSpot(spot.toUpdateSpot());
      }
    } else {
      List<XFile> images = await picker.pickMultiImage();
      for (XFile img in images){
        var mediaId = await mediaService.uploadMedia(img);
        Spot spot = widget.spot;
        spot.mediaIds.add(mediaId);
        spotService.editSpot(spot.toUpdateSpot());
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

  void editSpotDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => EditSpot(spot: widget.spot, onUpdate: widget.onUpdate)
    );
  }

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> elements = [];

    elements.add(Text(widget.spot.name, style: MyTextStyles.title));
    elements.add(Text(
      '${round(widget.spot.coordinates[0], decimals: 8)}, ${round(widget.spot.coordinates[1], decimals: 8)}',
      style: MyTextStyles.description,
    ));
    elements.add(Text(widget.spot.location, style: MyTextStyles.description));
    elements.add(Rating(rating: widget.spot.rating));
    if (widget.spot.singlePitchRouteIds.isNotEmpty || widget.spot.multiPitchRouteIds.isNotEmpty) {
      elements.add(GradeDistribution(
        singlePitchRouteIds: widget.spot.singlePitchRouteIds,
        multiPitchRouteIds: widget.spot.multiPitchRouteIds,
        onNetworkChange: widget.onNetworkChange,
      ));
    }
    if (widget.spot.distancePublicTransport != 0 || widget.spot.distanceParking != 0){
      elements.add(Transport(
        distancePublicTransport: widget.spot.distancePublicTransport,
        distanceParking: widget.spot.distanceParking)
      );
    }
    if (widget.spot.comment.isNotEmpty) elements.add(Comment(comment: widget.spot.comment));

    void deleteImageCallback(String mediumId) {
      widget.spot.mediaIds.remove(mediumId);
      spotService.editSpot(UpdateSpot(
        id: widget.spot.id,
        mediaIds: widget.spot.mediaIds
      ));
      setState(() {});
    }

    if (widget.spot.mediaIds.isNotEmpty) {
      elements.add(ImageListViewAdd(
        onDelete: deleteImageCallback,
        mediaIds: widget.spot.mediaIds,
        getImage: getImage,
      ));
    } else {
      elements.add(ElevatedButton.icon(
        icon: const Icon(Icons.add, size: 30.0, color: Colors.pink),
        label: const Text('Add image'),
        onPressed: () => addImageDialog(),
        style: MyButtonStyles.rounded
      ));
    }
    elements.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            Navigator.pop(context);
            spotService.deleteSpot(widget.spot);
            widget.onDelete.call(widget.spot);
          },
          icon: const Icon(Icons.delete),
        ),
        IconButton(
          onPressed: () => editSpotDialog(),
          icon: const Icon(Icons.edit),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ],
    )
    );
    if (widget.spot.multiPitchRouteIds.isNotEmpty || widget.spot.singlePitchRouteIds.isNotEmpty){
      elements.add(RouteTimeline(
        trip: widget.trip,
        spot: widget.spot,
        singlePitchRouteIds: widget.spot.singlePitchRouteIds,
        multiPitchRouteIds: widget.spot.multiPitchRouteIds,
        startDate: DateTime(1923),
        endDate: DateTime(2123),
        onNetworkChange: widget.onNetworkChange,
      ));
    }
    return Stack(children: [Container(padding: const EdgeInsets.all(20), child: ListView(children: elements))]);
  }
}