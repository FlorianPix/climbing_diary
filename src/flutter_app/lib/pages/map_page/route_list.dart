import 'package:climbing_diary/interfaces/multi_pitch_route/multi_pitch_route.dart';
import 'package:climbing_diary/interfaces/single_pitch_route/single_pitch_route.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:timelines/timelines.dart';

import '../../../interfaces/spot/spot.dart';
import '../../../interfaces/trip/trip.dart';
import '../../../services/pitch_service.dart';
import '../../../services/route_service.dart';
import '../../components/detail/multi_pitch_route_details.dart';
import '../../components/detail/single_pitch_route_details.dart';
import '../../components/info/multi_pitch_route_info.dart';
import '../../components/info/route_info.dart';
import '../../components/info/single_pitch_route_info.dart';
import '../../components/rating.dart';
import '../diary_page/image_list_view.dart';
import '../diary_page/timeline/ascent_timeline.dart';
import '../diary_page/timeline/pitch_timeline.dart';

class RouteList extends StatefulWidget {
  const RouteList({super.key, this.trip, required this.spot, required this.singlePitchRouteIds, required this.multiPitchRouteIds, required this.onNetworkChange});

  final Trip? trip;
  final Spot spot;
  final List<String> singlePitchRouteIds, multiPitchRouteIds;
  final ValueSetter<bool> onNetworkChange;

  @override
  State<StatefulWidget> createState() => RouteListState();
}

class RouteListState extends State<RouteList> {
  final RouteService routeService = RouteService();
  final PitchService pitchService = PitchService();

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
    List<String> singlePitchRouteIds = widget.singlePitchRouteIds;
    List<String> multiPitchRouteIds = widget.multiPitchRouteIds;
    List<Widget> elements = [];
    return FutureBuilder<List<MultiPitchRoute?>>(
      future: routeService.getMultiPitchRoutesOfIds(online, multiPitchRouteIds),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<MultiPitchRoute> multiPitchRoutes = snapshot.data!.whereType<MultiPitchRoute>().toList();
          multiPitchRoutes.sort((a, b) => a.name.compareTo(b.name));

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

          if (multiPitchRoutes.isNotEmpty){
            elements.add(FixedTimeline.tileBuilder(
              theme: TimelineThemeData(
                nodePosition: 0,
                color: const Color(0xff989898),
                indicatorTheme: const IndicatorThemeData(position: 0, size: 20.0,),
                connectorTheme: const ConnectorThemeData(thickness: 2.5,),
              ),
              builder: TimelineTileBuilder.connected(
                connectionDirection: ConnectionDirection.before,
                itemCount: multiPitchRoutes.length,
                contentsBuilder: (_, index) {
                  List<Widget> timeLineElements = [];
                  MultiPitchRoute multiPitchRoute = multiPitchRoutes[index];
                  timeLineElements.add(RouteInfo(route: multiPitchRoute));
                  timeLineElements.add(Rating(rating: multiPitchRoute.rating));
                  if (multiPitchRoute.mediaIds.isNotEmpty) {
                    timeLineElements.add(ExpansionTile(
                      leading: const Icon(Icons.image),
                      title: const Text("images"),
                      children: [ImageListView(mediaIds: multiPitchRoute.mediaIds)]
                    ));
                  }
                  if (multiPitchRoute.pitchIds.isNotEmpty) {
                    timeLineElements.add(MultiPitchInfo(pitchIds: multiPitchRoute.pitchIds));
                    timeLineElements.add(PitchTimeline(
                      trip: widget.trip,
                      spot: widget.spot,
                      route: multiPitchRoute,
                      pitchIds: multiPitchRoute.pitchIds,
                      onNetworkChange: widget.onNetworkChange,
                    ));
                  }
                  return InkWell(
                    onTap: () => showDialog(
                      context: context,
                      builder: (BuildContext context) => Dialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: MultiPitchRouteDetails(
                          spot: widget.spot,
                          route: multiPitchRoute,
                          onDelete: deleteMultiPitchRouteCallback,
                          onUpdate: updateMultiPitchRouteCallback,
                          spotId: widget.spot.id,
                          onNetworkChange: widget.onNetworkChange,
                        )
                      )
                    ),
                    child: Ink(child: Padding(padding: const EdgeInsets.only(left: 8.0), child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: timeLineElements,
                    ))),
                  );
                },
                indicatorBuilder: (_, index) => const OutlinedDotIndicator(borderWidth: 2.5, color: Color(0xff66c97f)),
                connectorBuilder: (_, index, ___) => const SolidLineConnector(color: Color(0xff66c97f)),
              ),
            ));
          }
          return FutureBuilder<List<SinglePitchRoute?>>(
              future: routeService.getSinglePitchRoutesOfIds(online, singlePitchRouteIds),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Text(snapshot.error.toString());
                if (!snapshot.hasData) return const CircularProgressIndicator();
                List<SinglePitchRoute> singlePitchRoutes = snapshot.data!.whereType<SinglePitchRoute>().toList();
                singlePitchRoutes.sort((a, b) => a.name.compareTo(b.name));

                updateSinglePitchRouteCallback(SinglePitchRoute route) {
                  var index = -1;
                  for (int i = 0; i < singlePitchRoutes.length; i++) {
                    if (singlePitchRoutes[i].id == route.id) index = i;
                  }
                  singlePitchRoutes.removeAt(index);
                  singlePitchRoutes.add(route);
                  setState(() {});
                }

                deleteSinglePitchRouteCallback(SinglePitchRoute route) {
                  singlePitchRoutes.remove(route);
                  singlePitchRouteIds.remove(route.id);
                  setState(() {});
                }

                if (singlePitchRoutes.isNotEmpty){
                  elements.add(FixedTimeline.tileBuilder(
                    theme: TimelineThemeData(
                      nodePosition: 0,
                      color: const Color(0xff989898),
                      indicatorTheme: const IndicatorThemeData(position: 0, size: 20.0),
                      connectorTheme: const ConnectorThemeData(thickness: 2.5),
                    ),
                    builder: TimelineTileBuilder.connected(
                      connectionDirection: ConnectionDirection.before,
                      itemCount: singlePitchRoutes.length,
                      contentsBuilder: (_, index) {
                        List<Widget> elements = [];
                        SinglePitchRoute singlePitchRoute = singlePitchRoutes[index];
                        elements.add(SinglePitchRouteInfo(route: singlePitchRoute));
                        elements.add(Rating(rating: singlePitchRoute.rating));
                        if (singlePitchRoute.mediaIds.isNotEmpty) {
                          elements.add(ExpansionTile(
                            leading: const Icon(Icons.image),
                            title: const Text("images"),
                            children: [ImageListView(mediaIds: singlePitchRoute.mediaIds)]
                          ));
                        }
                        if (singlePitchRoute.ascentIds.isNotEmpty) {
                          DateTime startDate = DateTime(1923);
                          DateTime endDate = DateTime(2123);
                          if (widget.trip != null) {
                            DateTime.parse(widget.trip!.startDate);
                            DateTime.parse(widget.trip!.endDate);
                          }
                          elements.add(ExpansionTile(
                              leading: const Icon(Icons.flag),
                              title: const Text("ascents"),
                              children: [AscentTimeline(
                                trip: widget.trip,
                                spot: widget.spot,
                                route: singlePitchRoute,
                                pitchId: singlePitchRoute.id,
                                ascentIds: singlePitchRoute.ascentIds,
                                onUpdate: (ascent) {
                                  // TODO
                                },
                                onDelete: (ascent) {
                                  singlePitchRoute.ascentIds.remove(ascent.id);
                                  setState(() {});
                                },
                                startDate: startDate,
                                endDate: endDate,
                                ofMultiPitch: false,
                                onNetworkChange: widget.onNetworkChange,
                              )]
                          ));
                        }
                        return InkWell(
                          onTap: () => showDialog(
                            context: context,
                            builder: (BuildContext context) => Dialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              child: SinglePitchRouteDetails(
                                spot: widget.spot,
                                route: singlePitchRoute,
                                onDelete: (SinglePitchRoute sPR) => deleteSinglePitchRouteCallback(sPR),
                                onUpdate: (SinglePitchRoute sPR) => updateSinglePitchRouteCallback(sPR),
                                spotId: widget.spot.id,
                                onNetworkChange: widget.onNetworkChange,
                              )
                            )
                          ),
                          child: Ink(child: Padding(padding: const EdgeInsets.only(left: 8.0), child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: elements,
                          ))),
                        );
                      },
                      indicatorBuilder: (_, index) => const OutlinedDotIndicator(borderWidth: 2.5, color: Color(0xff66c97f)),
                      connectorBuilder: (_, index, ___) => const SolidLineConnector(color: Color(0xff66c97f)),
                    ),
                  ));
                }
                return Column(
                  children: elements,
                );
              }
          );
        } else {
          return const CircularProgressIndicator();
        }
      }
    );
  }
}