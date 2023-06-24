import 'package:climbing_diary/components/diary_page/image_list_view.dart';
import 'package:climbing_diary/components/diary_page/pitch_timeline.dart';
import 'package:climbing_diary/components/diary_page/rating_row.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:timelines/timelines.dart';

import '../../interfaces/pitch/pitch.dart';
import '../../interfaces/route/route.dart';
import '../../interfaces/spot/spot.dart';
import '../../interfaces/trip/trip.dart';
import '../../services/pitch_service.dart';
import '../../services/route_service.dart';
import '../detail/route_details.dart';
import '../info/multi_pitch_info.dart';
import '../info/route_info.dart';
import '../info/single_pitch_info.dart';

class RouteTimeline extends StatefulWidget {
  const RouteTimeline({super.key, this.trip, required this.spot, required this.routeIds});

  final Trip? trip;
  final Spot spot;
  final List<String> routeIds;

  @override
  State<StatefulWidget> createState() => RouteTimelineState();
}

class RouteTimelineState extends State<RouteTimeline> {
  final RouteService routeService = RouteService();
  final PitchService pitchService = PitchService();

  @override
  void initState(){
    super.initState();
    checkConnection();
  }

  @override
  Widget build(BuildContext context) {
    List<String> routeIds = widget.routeIds;
    return FutureBuilder<bool>(
      future: checkConnection(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var online = snapshot.data!;
          if (online) {
            return FutureBuilder<List<ClimbingRoute>>(
              future: Future.wait(routeIds.map((routeId) => routeService.getRoute(routeId))),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<ClimbingRoute> routes = snapshot.data!;

                  // TODO filter for routes that have ascents within the trip date range

                  updateRouteCallback(ClimbingRoute route) {
                    var index = -1;
                    for (int i = 0; i < routes.length; i++) {
                      if (routes[i].id == route.id) {
                        index = i;
                      }
                    }
                    routes.removeAt(index);
                    routes.add(route);
                    setState(() {});
                  }

                  deleteRouteCallback(ClimbingRoute route) {
                    routes.remove(route);
                    setState(() {});
                  }

                  return Column(
                    children: [
                      FixedTimeline.tileBuilder(
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
                          itemCount: routes.length,
                          contentsBuilder: (_, index) {
                            List<Widget> elements = [];
                            // route info
                            elements.add(RouteInfo(route: routes[index]));
                            // rating as hearts in a row
                            elements.add(RatingRow(rating: routes[index].rating));
                            // images list view
                            if (routes[index].mediaIds.isNotEmpty) {
                              elements.add(
                                  ImageListView(mediaIds: routes[index].mediaIds)
                              );
                            }
                            // pitches
                            /*
                            if (routes[index].pitchIds.isNotEmpty){
                              if (routes[index].pitchIds.length > 1) {
                                // multi pitch
                                elements.add(
                                  MultiPitchInfo(pitchIds: routes[index].pitchIds)
                                );
                                elements.add(
                                  PitchTimeline(
                                      trip: widget.trip,
                                      spot: widget.spot,
                                      route: routes[index],
                                      pitchIds: routes[index].pitchIds
                                  )
                                );
                              } else {
                                // single pitch
                                // TODO
                              }
                            }
                             */
                            return InkWell(
                              onTap: () => showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        Dialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: RouteDetails(
                                                trip: widget.trip,
                                                spot: widget.spot,
                                                route: routes[index],
                                                onDelete: deleteRouteCallback,
                                                onUpdate: updateRouteCallback,
                                                spotId: widget.spot.id)
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
                          connectorBuilder: (_, index, ___) =>
                          const SolidLineConnector(color: Color(0xff66c97f)),
                        ),
                      )
                    ],
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              }
            );
          } else {
            return const CircularProgressIndicator();
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
}