import 'package:climbing_diary/components/common/grade_distribution.dart';
import 'package:climbing_diary/components/common/my_text_styles.dart';
import 'package:climbing_diary/components/common/transport.dart';
import 'package:climbing_diary/interfaces/spot/update_spot.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import 'package:climbing_diary/components/add/add_image.dart';
import 'package:climbing_diary/components/common/comment.dart';
import 'package:climbing_diary/components/common/image_list_view_add.dart';
import 'package:climbing_diary/components/common/my_button_styles.dart';
import 'package:climbing_diary/components/add/add_route.dart';
import 'package:climbing_diary/components/edit/edit_spot.dart';
import 'package:climbing_diary/components/common/rating.dart';
import 'package:uuid/uuid.dart';
import '../../interfaces/media/media.dart';
import '../../interfaces/spot/spot.dart';
import '../../interfaces/trip/trip.dart';
import '../../services/media_service.dart';
import '../../services/spot_service.dart';
import 'route_list.dart';

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
        var mediaId = await mediaService.createMedium(medium);
        Spot spot = widget.spot;
        spot.mediaIds.add(mediaId);
        await spotService.editSpot(spot.toUpdateSpot());
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
        await spotService.editSpot(spot.toUpdateSpot());
      }
    }
    setState(() {});
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
    elements.add(Row(children: [
      Text(
        '${round(widget.spot.coordinates[0], decimals: 8)}, ${round(widget.spot.coordinates[1], decimals: 8)}',
        style: MyTextStyles.description,
      ),
      IconButton(
        iconSize: 16,
        color: const Color(0xff989898),
        onPressed: () async => await Clipboard.setData(ClipboardData(text: "${widget.spot.coordinates[0]},${widget.spot.coordinates[1]}")),
        icon: const Icon(Icons.content_copy))
    ]));
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
      elements.add(
        ElevatedButton.icon(
          icon: const Icon(Icons.add, size: 30.0, color: Colors.pink),
          label: const Text('Add image'),
          onPressed: () => Navigator.push(context, MaterialPageRoute(
            builder: (context) => AddImage(onAddImage: getImage)
          )),
          style: ButtonStyle(shape: MyButtonStyles.rounded)
        ),
      );
    }
    elements.add(ElevatedButton.icon(
      icon: const Icon(Icons.add, size: 30.0, color: Colors.pink),
      label: const Text('Add new route'),
      onPressed: () => Navigator.push(context,
        MaterialPageRoute(
          builder: (context) => AddRoute(
            spot: widget.spot,
            onAddMultiPitchRoute: (route) {
              widget.spot.multiPitchRouteIds.add(route.id);
              setState(() {});
            },
            onAddSinglePitchRoute: (route) {
              widget.spot.singlePitchRouteIds.add(route.id);
              setState(() {});
            },
          ),
        )
      ),
      style: ButtonStyle(shape: MyButtonStyles.rounded)
    ));
    elements.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () async {
            Navigator.pop(context);
            await Hive.box(Spot.boxName).delete(widget.spot.id);
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
    ));
    if (widget.spot.multiPitchRouteIds.isNotEmpty || widget.spot.singlePitchRouteIds.isNotEmpty){
      elements.add(RouteList(
        trip: widget.trip,
        spot: widget.spot,
        singlePitchRouteIds: widget.spot.singlePitchRouteIds,
        multiPitchRouteIds: widget.spot.multiPitchRouteIds,
        onNetworkChange: widget.onNetworkChange,
      ));
    }
    return Stack(children: [Container(padding: const EdgeInsets.all(20), child: ListView(children: elements))]);
  }
}