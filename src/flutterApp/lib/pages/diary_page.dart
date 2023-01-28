import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:latlong2/latlong.dart';
import 'package:skeletons/skeletons.dart';
import 'package:timelines/timelines.dart';

import '../components/spot_details.dart';
import '../interfaces/spot.dart';
import '../services/media_service.dart';
import '../services/spot_service.dart';

const kTileHeight = 50.0;

class DiaryPage extends StatefulWidget {
  const DiaryPage({super.key});

  @override
  State<StatefulWidget> createState() => _DiaryPageState();
}

class _InnerTimeline extends StatelessWidget {
  const _InnerTimeline({
    required this.routes,
  });

  final List<String> routes;


  @override
  Widget build(BuildContext context) {
    bool isEdgeIndex(int index) {
      return index == 0 || index == routes.length + 1;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: FixedTimeline.tileBuilder(
        theme: TimelineTheme.of(context).copyWith(
          nodePosition: 0,
          connectorTheme: TimelineTheme.of(context).connectorTheme.copyWith(
            thickness: 1.0,
          ),
          indicatorTheme: TimelineTheme.of(context).indicatorTheme.copyWith(
            size: 10.0,
            position: 0.5,
          ),
        ),
        builder: TimelineTileBuilder(
          indicatorBuilder: (_, index) =>
          !isEdgeIndex(index) ? Indicator.outlined(borderWidth: 1.0) : null,
          startConnectorBuilder: (_, index) => Connector.solidLine(),
          endConnectorBuilder: (_, index) => Connector.solidLine(),
          contentsBuilder: (_, index) {
            if (isEdgeIndex(index)) {
              return null;
            }

            return Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(routes[index - 1]),
            );
          },
          itemExtentBuilder: (_, index) => isEdgeIndex(index) ? 10.0 : 30.0,
          nodeItemOverlapBuilder: (_, index) =>
          isEdgeIndex(index) ? true : null,
          itemCount: routes.length + 2,
        ),
      ),
    );
  }
}

class _DiaryPageState extends State<DiaryPage> {
  late Future<List<Spot>> futureSpots;

  final SpotService spotService = SpotService();
  final MediaService mediaService = MediaService();

  Future<List<String>> fetchURLs(mediaIds) {
    List<Future<String>> futures = [];
    for (var mediaId in mediaIds) {
      futures.add(mediaService.getMediumUrl(mediaId));
    }
    return Future.wait(futures);
  }

  @override
  void initState(){
    super.initState();
    futureSpots = spotService.getSpots();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: const TextStyle(
        color: Color(0xff9b9b9b),
        fontSize: 12.5,
      ),
      child: FutureBuilder<List<Spot>>(
        future: futureSpots,
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            var spots = snapshot.data!;
            spots.sort((a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));

            deleteCallback(spot) {
              spots.remove(spot);
              setState(() {});
            }

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
                    String details = '';
                    details += '${spots[index].date}\n';
                    details += '${round(spots[index].coordinates[0], decimals: 8)}';
                    details += ', ${round(spots[index].coordinates[1], decimals: 8)}';

                    List<Widget> elements = [];

                    elements.add(Text(
                      spots[index].name,
                      style: DefaultTextStyle.of(context).style.copyWith(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w800
                      ),
                    ));
                    elements.add(Text(
                      details,
                      style: DefaultTextStyle.of(context).style.copyWith(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600
                      ),
                    ));
                    String location = "";
                    for (var i = 0; i < spots[index].location.length; i++){
                      location += spots[index].location[i];
                      if (i < spots[index].location.length - 1) {
                        location += ", ";
                      }
                    }

                    elements.add(Text(
                      location,
                      style: DefaultTextStyle.of(context).style.copyWith(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600
                      ),
                    ));

                    List<Widget> ratingRowElements = [];

                    for (var i = 0; i < 5; i++){
                      if (spots[index].rating > i) {
                        ratingRowElements.add(const Icon(Icons.favorite, size: 30.0, color: Colors.pink));
                      } else {
                        ratingRowElements.add(const Icon(Icons.favorite, size: 30.0, color: Colors.grey));
                      }
                    }

                    elements.add(Center(child: Padding(
                        padding: const EdgeInsets.all(10),
                        child:Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: ratingRowElements,
                        )
                    )));

                    // images
                    if (spots[index].mediaIds.isNotEmpty) {
                      List<Widget> imageWidgets = [];
                      Future<List<String>> futureMediaUrls = fetchURLs(spots[index].mediaIds);

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
                                for (var i = 0; i < spots[index].mediaIds.length; i++){
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

                    elements.add(
                      _InnerTimeline(routes: spots[index].routes)
                    );

                    return InkWell(
                      onTap: () => showDialog(
                        context: context,
                        builder: (BuildContext context) => Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: SpotDetails(spot: spots[index], onDelete: deleteCallback,)
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
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          return const CircularProgressIndicator();
        }
      )
    );
  }
}