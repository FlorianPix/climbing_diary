import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import 'package:climbing_diary/components/add/add_image.dart';
import 'package:climbing_diary/components/common/comment.dart';
import 'package:climbing_diary/components/common/grade_distribution.dart';
import 'package:climbing_diary/components/common/image_list_view_add.dart';
import 'package:climbing_diary/components/common/my_button_styles.dart';
import 'package:climbing_diary/components/common/my_text_styles.dart';
import 'package:climbing_diary/components/common/rating.dart';
import 'package:climbing_diary/components/common/transport.dart';
import 'package:uuid/uuid.dart';
import '../../interfaces/media/media.dart';
import '../../interfaces/spot/spot.dart';
import '../../interfaces/spot/update_spot.dart';
import '../../services/media_service.dart';
import '../../services/spot_service.dart';

class SpotDetails extends StatefulWidget {
  const SpotDetails({super.key, required this.spot, required this.onNetworkChange});

  final Spot spot;
  final ValueSetter<bool> onNetworkChange;

  @override
  State<StatefulWidget> createState() => _SpotDetailsState();
}

class _SpotDetailsState extends State<SpotDetails>{
  final MediaService mediaService = MediaService();
  final SpotService spotService = SpotService();

  Future<List<Media>> fetchMedia() {
    List<Future<Media>> futures = [];
    for (var mediaId in widget.spot.mediaIds) {
      futures.add(mediaService.getMedium(mediaId));
    }
    return Future.wait(futures);
  }

  final ImagePicker picker = ImagePicker();

  Future<void> getImage(ImageSource media) async {
    if (media == ImageSource.camera) {
      XFile? file = await picker.pickImage(source: media);
      if (file != null) {
        Media medium = Media(
          id: const Uuid().v4(),
          userId: '',
          title: file.name,
          createdAt: DateTime.now().toIso8601String(),
          image: await file.readAsBytes(),
        );
        String mediaId = await mediaService.createMedium(medium);
        Spot spot = widget.spot;
        spot.mediaIds.add(mediaId);
        spotService.editSpot(spot.toUpdateSpot());
      }
    } else {
      List<XFile> files = await picker.pickMultiImage();
      for (XFile file in files){
        Media medium = Media(
          id: const Uuid().v4(),
          userId: '',
          title: file.name,
          createdAt: DateTime.now().toIso8601String(),
          image: await file.readAsBytes(),
        );
        var mediaId = await mediaService.createMedium(medium);
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
        style: ButtonStyle(shape: MyButtonStyles.rounded)
      ));
    }
    return Column(children: elements);
  }
}