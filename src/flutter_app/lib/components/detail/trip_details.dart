import 'package:climbing_diary/components/common/my_button_styles.dart';
import 'package:climbing_diary/components/common/my_text_styles.dart';
import 'package:climbing_diary/components/common/select_spot.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../../interfaces/spot/spot.dart';
import '../../interfaces/trip/trip.dart';
import '../../interfaces/trip/update_trip.dart';
import '../../pages/diary_page/timeline/spot_timeline.dart';
import '../../services/media_service.dart';
import '../../services/trip_service.dart';
import '../add/add_image.dart';
import '../add/add_spot.dart';
import '../common/comment.dart';
import '../edit/edit_trip.dart';
import 'package:climbing_diary/components/common/image_list_view_add.dart';
import 'package:climbing_diary/components/common/rating.dart';

class TripDetails extends StatefulWidget {
  const TripDetails({super.key, required this.trip, required this.onTripDelete, required this.onTripUpdate, required this.onSpotAdd, required this.onNetworkChange });

  final Trip trip;
  final ValueSetter<Trip> onTripDelete, onTripUpdate;
  final ValueSetter<Spot> onSpotAdd;
  final ValueSetter<bool> onNetworkChange;

  @override
  State<StatefulWidget> createState() => _TripDetailsState();
}

class _TripDetailsState extends State<TripDetails>{
  final MediaService mediaService = MediaService();
  final TripService tripService = TripService();

  Future<List<String>> fetchURLs() {
    List<Future<String>> futures = [];
    for (var mediaId in widget.trip.mediaIds) {
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
        Trip trip = widget.trip;
        trip.mediaIds.add(mediaId);
        tripService.editTrip(trip.toUpdateTrip(), online);
      }
    } else {
      List<XFile> images = await picker.pickMultiImage();
      for (XFile img in images){
        var mediaId = await mediaService.uploadMedia(img);
        Trip trip = widget.trip;
        trip.mediaIds.add(mediaId);
        tripService.editTrip(trip.toUpdateTrip(), online);
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

  void editTripDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => EditTrip(trip: widget.trip, onUpdate: widget.onTripUpdate, onNetworkChange: widget.onNetworkChange)
    );
  }

  bool online = false;

  void checkConnection() async {
    await InternetConnectionChecker().hasConnection.then((value) {
      widget.onNetworkChange.call(value);
      setState(() => online = value);
    });
  }

  @override
  void initState(){
    super.initState();
    checkConnection();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> elements = [];
    Trip trip = widget.trip;

    elements.add(Text(widget.trip.name, style: MyTextStyles.title));
    elements.add(Text(
      "${trip.startDate} ${trip.endDate}",
      style: const TextStyle(
        color: Color(0xff989898),
        fontSize: 12.0,
        fontWeight: FontWeight.w400
      ),
    ));
    if (trip.comment.isNotEmpty) elements.add(Comment(comment: trip.comment));
    elements.add(Rating(rating: trip.rating));

    void deleteImageCallback(String mediumId) {
      widget.trip.mediaIds.remove(mediumId);
      tripService.editTrip(
        UpdateTrip(
          id: widget.trip.id,
          mediaIds: widget.trip.mediaIds
        ),
        online
      );
      setState(() {});
    }

    if (trip.mediaIds.isNotEmpty) {
      elements.add(ImageListViewAdd(
        onDelete: deleteImageCallback,
        mediaIds: widget.trip.mediaIds,
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
      label: const Text('Add new spot'),
      onPressed: () => Navigator.push(context,
        MaterialPageRoute(
          builder: (context) => AddSpot(
            onAdd: (spot) {
              widget.onSpotAdd.call(spot);
              setState(() {});
            },
            trip: trip,
            onNetworkChange: widget.onNetworkChange,
          ),
        )
      ),
      style: ButtonStyle(shape: MyButtonStyles.rounded)
    ));
    elements.add(ElevatedButton.icon(
      icon: const Icon(Icons.add, size: 30.0, color: Colors.pink),
      label: const Text('Add existing spot'),
      onPressed: () => Navigator.push(context,
        MaterialPageRoute(
          builder: (context) => SelectSpot(
            trip: widget.trip,
            onAdd: widget.onSpotAdd,
            onNetworkChange: widget.onNetworkChange,
          ),
        )
      ),
      style: ButtonStyle(shape: MyButtonStyles.rounded)
    ));
    elements.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            Navigator.pop(context);
            tripService.deleteTrip(trip);
            widget.onTripDelete.call(trip);
          },
          icon: const Icon(Icons.delete),
        ),
        IconButton(
          onPressed: () => editTripDialog(),
          icon: const Icon(Icons.edit),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ],
    ));
    if (trip.spotIds.isNotEmpty){
      elements.add(SpotTimeline(
        trip: trip,
        spotIds: trip.spotIds,
        startDate: DateTime.parse(trip.startDate),
        endDate: DateTime.parse(trip.endDate),
        onNetworkChange: widget.onNetworkChange,
      ));
    }
    return Stack(children: [Padding(padding: const EdgeInsets.all(20), child: ListView(children: elements))]);
  }
}