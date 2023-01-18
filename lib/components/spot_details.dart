import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:skeletons/skeletons.dart';

import '../interfaces/spot.dart';
import '../services/media_service.dart';

class SpotDetails extends StatefulWidget {
  const SpotDetails({super.key, required this.spot});

  final Spot spot;

  @override
  State<StatefulWidget> createState() => _SpotDetailsState();
}

class _SpotDetailsState extends State<SpotDetails>{
  final MediaService mediaService = MediaService();

  Future<List<String>> fetchURLs() {
    List<Future<String>> futures = [];
    for (var mediaId in widget.spot.mediaIds) {
      futures.add(mediaService.fetchMediumUrl(mediaId));
    }
    return Future.wait(futures);
  }

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String location = "";
    for (var i = 0; i < widget.spot.location.length; i++){
      location += widget.spot.location[i];
      if (i < widget.spot.location.length - 1) {
        location += ", ";
      }
    }

    List<Widget> elements = [];

    // general info
    elements.addAll([
      Text(
        widget.spot.name,
        style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600
        ),
      ),
      Text(
        widget.spot.date,
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400
        ),
      ),
      Text(
        '${round(widget.spot.coordinates[0], decimals: 8)}, ${round(widget.spot.coordinates[1], decimals: 8)}',
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400
        ),
      ),
      Text(
        widget.spot.country,
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400
        ),
      ),
      Text(
        location,
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400
        ),
      )]);
    // rating
    List<Widget> ratingRowElements = [];

    for (var i = 0; i < 5; i++){
      if (widget.spot.rating > i) {
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

    // time to walk transport
    elements.add(Center(child: Padding(
        padding: const EdgeInsets.all(5),
        child:Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            const Icon(Icons.train, size: 30.0, color: Colors.green),
            Text(
              '${widget.spot.distancePublicTransport} min',
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400
              ),
            ),
            const Icon(Icons.directions_car, size: 30.0, color: Colors.red),
            Text(
              '${widget.spot.distanceParking} min',
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400
              ),
            )
          ],
        )
    )));

    if (widget.spot.comment.isNotEmpty) {
      elements.add(Container(
          margin: const EdgeInsets.all(15.0),
          padding: const EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blueAccent),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            widget.spot.comment,
          )
      ));
    }

    // images
    if (widget.spot.mediaIds.isNotEmpty) {
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
                  padding: const EdgeInsets.all(20),
                  child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: images
                  )
              );
            }
            List<Widget> skeletons = [];
            for (var i = 0; i < widget.spot.mediaIds.length; i++){
              skeletons.add(skeleton);
            }
            return Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: skeletons
                )
            );
          }
        )
      );
      elements.add(
        Container(
            height: 300,
            child: ListView(
                scrollDirection: Axis.horizontal,
                children: imageWidgets
            )
        ),
      );
    }
    // close button
    elements.add(
        Align(
          alignment: Alignment.bottomRight,
          child: TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
        )
    );

    return Stack(
        children: <Widget>[
          Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: elements
              )
          )
        ]
    );
  }
}