import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:timelines/timelines.dart';

import '../interfaces/spot.dart';
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

  @override
  void initState(){
    super.initState();
    futureSpots = fetchSpots();
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
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: FixedTimeline.tileBuilder(
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
                    elements.add(Text(
                      spots[index].country,
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

                    elements.add(
                      _InnerTimeline(routes: spots[index].routes)
                    );

                    return Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: elements,
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
              ),
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