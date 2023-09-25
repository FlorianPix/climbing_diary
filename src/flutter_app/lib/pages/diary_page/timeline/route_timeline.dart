import 'package:climbing_diary/interfaces/multi_pitch_route/multi_pitch_route.dart';
import 'package:climbing_diary/interfaces/single_pitch_route/single_pitch_route.dart';
import 'package:climbing_diary/pages/diary_page/timeline/my_timeline_theme_data.dart';
import 'package:climbing_diary/pages/diary_page/timeline/pitch_timeline.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:timelines/timelines.dart';

import '../../../components/detail/multi_pitch_route_details.dart';
import '../../../components/detail/single_pitch_route_details.dart';
import '../../../components/image_list_view.dart';
import '../../../components/info/multi_pitch_route_info.dart';
import '../../../components/info/route_info.dart';
import '../../../components/info/single_pitch_route_info.dart';
import '../../../components/rating.dart';
import '../../../interfaces/spot/spot.dart';
import '../../../interfaces/trip/trip.dart';
import '../../../services/multi_pitch_route_service.dart';
import '../../../services/pitch_service.dart';
import '../../../services/single_pitch_route_service.dart';
import 'ascent_timeline.dart';

class RouteTimeline extends StatefulWidget {
  const RouteTimeline({super.key, this.trip, required this.spot, required this.singlePitchRouteIds, required this.multiPitchRouteIds, required this.startDate, required this.endDate, required this.onNetworkChange});

  final Trip? trip;
  final Spot spot;
  final List<String> singlePitchRouteIds, multiPitchRouteIds;
  final DateTime startDate, endDate;
  final ValueSetter<bool> onNetworkChange;

  @override
  State<StatefulWidget> createState() => RouteTimelineState();
}

class RouteTimelineState extends State<RouteTimeline> {
  final MultiPitchRouteService multiPitchRouteService = MultiPitchRouteService();
  final SinglePitchRouteService singlePitchRouteService = SinglePitchRouteService();
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
    return FutureBuilder<List<MultiPitchRoute?>>(
      future: Future.wait(multiPitchRouteIds.map((routeId) => multiPitchRouteService.getMultiPitchRouteIfWithinDateRange(routeId, widget.startDate, widget.endDate, online))),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text(snapshot.error.toString());
        if (!snapshot.hasData) return const CircularProgressIndicator();
        List<MultiPitchRoute> multiPitchRoutes = snapshot.data!.whereType<MultiPitchRoute>().toList();
        return FutureBuilder<List<SinglePitchRoute?>>(
          future: Future.wait(singlePitchRouteIds.map((routeId) => singlePitchRouteService.getSinglePitchRouteIfWithinDateRange(routeId, widget.startDate, widget.endDate, online))),
          builder: (context, snapshot) {
            if (snapshot.hasError) return Text(snapshot.error.toString());
            if (!snapshot.hasData) return const CircularProgressIndicator();
            List<SinglePitchRoute> singlePitchRoutes = snapshot.data!.whereType<SinglePitchRoute>().toList();

            void updateMultiPitchRouteCallback(MultiPitchRoute route) {
              var index = -1;
              for (int i = 0; i < multiPitchRoutes.length; i++) {
                if (multiPitchRoutes[i].id == route.id) index = i;
              }
              multiPitchRoutes.removeAt(index);
              multiPitchRoutes.add(route);
              setState(() {});
            }

            void deleteMultiPitchRouteCallback(MultiPitchRoute route) {
              multiPitchRoutes.remove(route);
              setState(() {});
            }

            List<Widget> elements = [];

            if (multiPitchRoutes.isNotEmpty){
              elements.add(
                FixedTimeline.tileBuilder(
                  theme: MyTimeLineThemeData.defaultTheme,
                  builder: TimelineTileBuilder.connected(
                    connectionDirection: ConnectionDirection.before,
                    itemCount: multiPitchRoutes.length,
                    contentsBuilder: (_, index) {
                      List<Widget> elements = [];
                      MultiPitchRoute multiPitchRoute = multiPitchRoutes[index];
                      elements.add(RouteInfo(route: multiPitchRoute, onNetworkChange: widget.onNetworkChange));
                      elements.add(Rating(rating: multiPitchRoute.rating));
                      if (multiPitchRoute.pitchIds.isNotEmpty) {
                        elements.add(MultiPitchInfo(
                          pitchIds: multiPitchRoute.pitchIds,
                          onNetworkChange: widget.onNetworkChange,
                        ));
                      }
                      if (multiPitchRoute.mediaIds.isNotEmpty) {
                        elements.add(ExpansionTile(
                          leading: const Icon(Icons.image),
                          title: const Text("images"),
                          children: [ImageListView(mediaIds: multiPitchRoute.mediaIds)]
                        ));
                      }
                      if (multiPitchRoute.pitchIds.isNotEmpty) {
                        elements.add(PitchTimeline(
                          trip: widget.trip,
                          spot: widget.spot,
                          route: multiPitchRoute,
                          pitchIds: multiPitchRoute.pitchIds,
                          onNetworkChange: widget.onNetworkChange,
                        ));
                      }
                      return InkWell(
                        onTap: () => showDialog(context: context,
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
                          children: elements,
                        ))),
                      );
                    },
                    indicatorBuilder: (_, index) => const OutlinedDotIndicator(borderWidth: 2.5, color: Color(0xff66c97f)),
                    connectorBuilder: (_, index, ___) => const SolidLineConnector(color: Color(0xff66c97f)),
                  ),
                ),
              );
            }

            if (singlePitchRoutes.isNotEmpty){
              elements.add(
                FixedTimeline.tileBuilder(
                  theme: MyTimeLineThemeData.defaultTheme,
                  builder: TimelineTileBuilder.connected(
                    connectionDirection: ConnectionDirection.before,
                    itemCount: singlePitchRoutes.length,
                    contentsBuilder: (_, index) {
                      List<Widget> elements = [];
                      SinglePitchRoute singlePitchRoute = singlePitchRoutes[index];
                      elements.add(SinglePitchRouteInfo(route: singlePitchRoute, onNetworkChange: widget.onNetworkChange));
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
                        onTap: () => showDialog(context: context,
                          builder: (BuildContext context) => Dialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            child: SinglePitchRouteDetails(
                              spot: widget.spot,
                              route: singlePitchRoute,
                              onDelete: (SinglePitchRoute sPR) => {},
                              onUpdate: (SinglePitchRoute sPR) => {},
                              spotId: widget.spot.id,
                              onNetworkChange: widget.onNetworkChange,
                            )
                          )),
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
                )
              );
            }
            if (multiPitchRoutes.isEmpty && singlePitchRoutes.isEmpty) return const SizedBox.shrink();
            return Column(children: [ExpansionTile(
              leading: const Icon(Icons.route),
              title: const Text("routes"),
              children: elements,
            )]);
          }
        );
      }
    );
  }
}