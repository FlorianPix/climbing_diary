import 'package:climbing_diary/components/diary_page/image_list_view.dart';
import 'package:climbing_diary/components/diary_page/pitch_timeline.dart';
import 'package:climbing_diary/components/diary_page/rating_row.dart';
import 'package:climbing_diary/interfaces/multi_pitch_route/multi_pitch_route.dart';
import 'package:climbing_diary/interfaces/single_pitch_route/single_pitch_route.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:timelines/timelines.dart';

import '../../interfaces/spot/spot.dart';
import '../../interfaces/trip/trip.dart';
import '../../services/pitch_service.dart';
import '../../services/route_service.dart';
import '../detail/multi_pitch_route_details.dart';
import '../detail/single_pitch_route_details.dart';
import '../info/multi_pitch_route_info.dart';
import '../info/route_info.dart';
import '../info/single_pitch_route_info.dart';

class RouteTimeline extends StatefulWidget {
  const RouteTimeline({super.key, this.trip, required this.spot, required this.singlePitchRouteIds, required this.multiPitchRouteIds});

  final Trip? trip;
  final Spot spot;
  final List<String> singlePitchRouteIds;
  final List<String> multiPitchRouteIds;

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
    List<String> singlePitchRouteIds = widget.singlePitchRouteIds;
    List<String> multiPitchRouteIds = widget.multiPitchRouteIds;
    return FutureBuilder<bool>(
      future: checkConnection(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var online = snapshot.data!;
          if (online) {
            return FutureBuilder<List<MultiPitchRoute>>(
              future: Future.wait(multiPitchRouteIds.map((routeId) => routeService.getMultiPitchRoute(routeId))),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<MultiPitchRoute> multiPitchRoutes = snapshot.data!;
                  return FutureBuilder<List<SinglePitchRoute>>(
                    future: Future.wait(singlePitchRouteIds.map((routeId) => routeService.getSinglePitchRoute(routeId))),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        List<SinglePitchRoute> singlePitchRoutes = snapshot.data!;

                        updateMultiPitchRouteCallback(MultiPitchRoute route) {
                          var index = -1;
                          for (int i = 0; i < multiPitchRoutes.length; i++) {
                            if (multiPitchRoutes[i].id == route.id) {
                              index = i;
                            }
                          }
                          multiPitchRoutes.removeAt(index);
                          multiPitchRoutes.add(route);
                          setState(() {});
                        }

                        deleteMultiPitchRouteCallback(MultiPitchRoute route) {
                          multiPitchRoutes.remove(route);
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
                                itemCount: multiPitchRoutes.length,
                                contentsBuilder: (_, index) {
                                  List<Widget> elements = [];
                                  // route info
                                  MultiPitchRoute multiPitchRoute = multiPitchRoutes[index];
                                  elements.add(RouteInfo(route: multiPitchRoute));
                                  // rating as hearts in a row
                                  elements.add(RatingRow(rating: multiPitchRoute.rating));
                                  // images list view
                                  if (multiPitchRoute.mediaIds.isNotEmpty) {
                                    elements.add(
                                        ImageListView(mediaIds: multiPitchRoute.mediaIds)
                                    );
                                  }
                                  // pitches
                                  if (multiPitchRoute.pitchIds.isNotEmpty) {
                                    // multi pitch
                                    elements.add(
                                        MultiPitchInfo(
                                            pitchIds: multiPitchRoute.pitchIds
                                        )
                                    );
                                    elements.add(
                                        PitchTimeline(
                                            trip: widget.trip,
                                            spot: widget.spot,
                                            route: multiPitchRoute,
                                            pitchIds: multiPitchRoute.pitchIds
                                        )
                                    );
                                  }
                                  return InkWell(
                                    onTap: () => showDialog(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            Dialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: MultiPitchRouteDetails(
                                                    spot: widget.spot,
                                                    route: multiPitchRoute,
                                                    onDelete: deleteMultiPitchRouteCallback,
                                                    onUpdate: updateMultiPitchRouteCallback,
                                                    spotId: widget.spot.id
                                                )
                                            )
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
                            ),
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
                                itemCount: multiPitchRoutes.length,
                                contentsBuilder: (_, index) {
                                  List<Widget> elements = [];
                                  // route info
                                  MultiPitchRoute multiPitchRoute = multiPitchRoutes[index];
                                  elements.add(RouteInfo(route: multiPitchRoute));
                                  // rating as hearts in a row
                                  elements.add(RatingRow(rating: multiPitchRoute.rating));
                                  // images list view
                                  if (multiPitchRoute.mediaIds.isNotEmpty) {
                                    elements.add(
                                        ImageListView(mediaIds: multiPitchRoute.mediaIds)
                                    );
                                  }
                                  elements.add(SinglePitchRouteInfo(
                                      spot: widget.spot,
                                      route: singlePitchRoutes[index]
                                  ));
                                  return InkWell(
                                    onTap: () => showDialog(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            Dialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: SinglePitchRouteDetails(
                                                    spot: widget.spot,
                                                    route: singlePitchRoutes[index],
                                                    onDelete: (SinglePitchRoute singlePitchRoute) => {},
                                                    onUpdate: (SinglePitchRoute singlePitchRoute) => {},
                                                    spotId: widget.spot.id)
                                            )
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