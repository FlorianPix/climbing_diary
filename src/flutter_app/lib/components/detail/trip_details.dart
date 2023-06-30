import 'package:climbing_diary/components/MyButtonStyles.dart';
import 'package:climbing_diary/components/select/select_spot.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skeletons/skeletons.dart';

import '../../interfaces/spot/spot.dart';
import '../../interfaces/trip/trip.dart';
import '../../pages/diary_page/timeline/spot_timeline.dart';
import '../../services/media_service.dart';
import '../../services/trip_service.dart';
import '../add/add_spot.dart';
import '../edit/edit_trip.dart';

class TripDetails extends StatefulWidget {
  const TripDetails({super.key, required this.trip, required this.onTripDelete, required this.onTripUpdate, required this.onSpotAdd });

  final Trip trip;
  final ValueSetter<Trip> onTripDelete, onTripUpdate;
  final ValueSetter<Spot> onSpotAdd;

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

  XFile? image;
  final ImagePicker picker = ImagePicker();

  Future getImage(ImageSource media) async {
    var img = await picker.pickImage(source: media);
    if (img != null){
      var mediaId = await mediaService.uploadMedia(img);
      Trip trip = widget.trip;
      trip.mediaIds.add(mediaId);
      tripService.editTrip(trip.toUpdateTrip());
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

  void editTripDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditTrip(trip: widget.trip, onUpdate: widget.onTripUpdate);
      });
  }

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> elements = [];
    Trip trip = widget.trip;

    // general info
    elements.addAll([
      Text(
        widget.trip.name,
        style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600
        ),
      ),
    ]);

    elements.add(Text(
      "${trip.startDate} ${trip.endDate}",
      style: const TextStyle(
          color: Color(0xff989898),
          fontSize: 12.0,
          fontWeight: FontWeight.w400
      ),
    ));

    elements.add(Text(
      trip.comment,
      style: const TextStyle(
          color: Color(0xff989898),
          fontSize: 12.0,
          fontWeight: FontWeight.w400
      ),
    ));

    // rating
    List<Widget> ratingRowElements = [];

    for (var i = 0; i < 5; i++){
      if (trip.rating > i) {
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

    if (trip.comment.isNotEmpty) {
      elements.add(Container(
          margin: const EdgeInsets.all(15.0),
          padding: const EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blueAccent),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            trip.comment,
          )
      ));
    }
    // images
    if (trip.mediaIds.isNotEmpty) {
      List<Widget> imageWidgets = [];

      imageWidgets.add(
        FutureBuilder<List<String>>(
          future: fetchURLs(),
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
            for (var i = 0; i < trip.mediaIds.length; i++){
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
    // add spot
    elements.add(
      ElevatedButton.icon(
          icon: const Icon(Icons.add, size: 30.0, color: Colors.pink),
          label: const Text('Add new spot'),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddSpot(
                    onAdd: (spot) {
                      widget.onSpotAdd.call(spot);
                      setState(() {});
                    },
                    trip: trip,
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
          label: const Text('Add existing spot'),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SelectSpot(
                      trip: widget.trip,
                      onAdd: widget.onSpotAdd
                  ),
                )
            );
          },
          style: MyButtonStyles.rounded
      ),
    );
    // delete, edit, close
    elements.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // delete trip button
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
        )
    );
    // spots
    if (trip.spotIds.isNotEmpty){
        elements.add(SpotTimeline(
            trip: trip,
            spotIds: trip.spotIds,
            startDate: DateTime.parse(trip.startDate),
            endDate: DateTime.parse(trip.endDate)
        ));
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