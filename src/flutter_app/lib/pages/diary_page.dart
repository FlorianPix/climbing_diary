import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:latlong2/latlong.dart';
import 'package:skeletons/skeletons.dart';
import 'package:timelines/timelines.dart';

import '../components/inner_timeline.dart';
import '../components/spot_details.dart';
import '../interfaces/spot.dart';
import '../services/media_service.dart';
import '../services/spot_service.dart';

const kTileHeight = 50.0;

class DiaryPage extends StatefulWidget {
  const DiaryPage({super.key});

  @override
  State<StatefulWidget> createState() => DiaryPageState();
}

class DiaryPageState extends State<DiaryPage> {
  late Future<List<Spot>> futureSpots;

  final SpotService spotService = SpotService();
  final MediaService mediaService = MediaService();

  @override
  void initState(){
    super.initState();
    checkConnection();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkConnection(),
      builder: (context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.hasData) {
          var online = snapshot.data!;
          if (online) {
            futureSpots = spotService.getSpots();
            return FutureBuilder<List<Spot>>(
              future: futureSpots,
              builder: (context, snapshot) {
                if(snapshot.hasData) {
                  var spots = snapshot.data!;
                  spots.sort((a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));

                  deleteCallback(spot) {
                    spots.remove(spot);
                    setState(() {});
                  }

                  updateCallback(Spot spot) {
                    var index = -1;
                    for (int i = 0; i < spots.length; i++) {
                      if (spots[i].id == spot.id) {
                        index = i;
                      }
                    }
                    spots.removeAt(index);
                    spots.add(spot);
                    setState(() {});
                  }

                  return getTimeline(spots, deleteCallback, updateCallback);
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }
                return const CircularProgressIndicator();
              }
            );
          } else {
            // offline
            return const Scaffold(
                body: Center(child: Text('No connection'),)
            );
          }
        } else {
          return const CircularProgressIndicator();
        }
      }
    );
  }

  Future<bool> checkConnection() async {
    return await InternetConnectionChecker().hasConnection;
  }

  Future<List<String>> fetchURLs(mediaIds) {
    List<Future<String>> futures = [];
    for (var mediaId in mediaIds) {
      futures.add(mediaService.getMediumUrl(mediaId));
    }
    return Future.wait(futures);
  }

  List<Widget> getSpotInfo(Spot spot) {
    List<Widget> listInfo = [];

    // name
    listInfo.add(Text(
      spot.name,
      style: const TextStyle(
        color: Color(0xff9b9b9b),
        fontSize: 18.0,
        fontWeight: FontWeight.w800
      ),
    ));

    // date
    listInfo.add(Text(
      spot.date,
      style: const TextStyle(
        color: Color(0xff9b9b9b),
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ));

    // coordinates
    listInfo.add(Text(
      '${round(spot.coordinates[0], decimals: 8)}, ${round(spot.coordinates[1], decimals: 8)}',
      style: const TextStyle(
        color: Color(0xff9b9b9b),
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ));

    // location
    String location = "";
    for (var i = 0; i < spot.location.length; i++){
      location += spot.location[i];
      if (i < spot.location.length - 1) {
        location += ", ";
      }
    }
    listInfo.add(Text(
      location,
      style: const TextStyle(
        color: Color(0xff9b9b9b),
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ));

    return listInfo;
  }

  Widget getRatingRow(int rating) {
    List<Widget> ratingRowElements = [];

    for (var i = 0; i < 5; i++){
      if (rating > i) {
        ratingRowElements.add(const Icon(Icons.favorite, size: 30.0, color: Colors.pink));
      } else {
        ratingRowElements.add(const Icon(Icons.favorite, size: 30.0, color: Colors.grey));
      }
    }
    return Center(
      child: Padding(
      padding: const EdgeInsets.all(10),
        child:Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: ratingRowElements,
        )
      )
    );
  }

  Widget getImageListViewFromMediaIds(List<String> mediaIds) {
    List<Widget> imageWidgets = [];
    Future<List<String>> futureMediaUrls = fetchURLs(mediaIds);

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
          for (var i = 0; i < mediaIds.length; i++){
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
    return SizedBox(
      height: 300,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: imageWidgets
      )
    );
  }

  Widget getTimeline(List<Spot> spots, ValueSetter<Spot> deleteCallback, ValueSetter<Spot> updateCallback) {
    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [FixedTimeline.tileBuilder(
        theme: TimelineThemeData(
          nodePosition: 0,
          color: const Color(0xff989898),
          indicatorTheme: const IndicatorThemeData(
            position: 0,
            size: 20.0,
          ),
          connectorTheme: const ConnectorThemeData(
            thickness: 2.5,
          ),
        ),
        builder: TimelineTileBuilder.connected(
          connectionDirection: ConnectionDirection.before,
          itemCount: spots.length,
          contentsBuilder: (_, index) {
            List<Widget> elements = [];

            // spot info
            elements.addAll(getSpotInfo(spots[index]));

            // rating as hearts in a row
            elements.add(getRatingRow(spots[index].rating));

            // images list view
            if (spots[index].mediaIds.isNotEmpty) {
              elements.add(
                  getImageListViewFromMediaIds(spots[index].mediaIds)
              );
            }

            // TODO routes
            elements.add(
                InnerTimeline(routes: spots[index].routes)
            );

            return InkWell(
              onTap: () => showDialog(
                context: context,
                builder: (BuildContext context) => Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: SpotDetails(spot: spots[index], onDelete: deleteCallback, onUpdate: updateCallback)
                ),
              ),
              child: Ink(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: elements,
                    ),
                  )
              ),
            );
          },
          indicatorBuilder: (_, index) {
            return const OutlinedDotIndicator(
              borderWidth: 2.5,
              color: Color(0xff66c97f),
            );
          },
          connectorBuilder: (_, index, ___) => const SolidLineConnector(
            color: Color(0xff66c97f),
          ),
        ),
      )],
    );
  }
}