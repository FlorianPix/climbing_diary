import 'package:climbing_diary/interfaces/multi_pitch_route/multi_pitch_route.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:timelines/timelines.dart';

import '../../../interfaces/spot/spot.dart';
import '../../../interfaces/trip/trip.dart';
import 'package:climbing_diary/components/detail/multi_pitch_route_details.dart';
import 'package:climbing_diary/components/info/multi_pitch_route_info.dart';
import 'package:climbing_diary/components/info/route_info.dart';
import 'package:climbing_diary/components/common/rating.dart';
import 'package:climbing_diary/components/common/image_list_view.dart';
import '../../services/multi_pitch_route_service.dart';
import '../diary_page/timeline/pitch_timeline.dart';

class MultiPitchRouteList extends StatefulWidget {
  const MultiPitchRouteList({super.key, this.trip, required this.spot, required this.multiPitchRouteIds, required this.onNetworkChange});

  final Trip? trip;
  final Spot spot;
  final List<String> multiPitchRouteIds;
  final ValueSetter<bool> onNetworkChange;

  @override
  State<StatefulWidget> createState() => MultiPitchRouteListState();
}

class MultiPitchRouteListState extends State<MultiPitchRouteList> {
  final MultiPitchRouteService multiPitchRouteService = MultiPitchRouteService();

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
    List<String> multiPitchRouteIds = widget.multiPitchRouteIds;

    return FutureBuilder<List<MultiPitchRoute?>>(
      future: multiPitchRouteService.getMultiPitchRoutesOfIds(online, multiPitchRouteIds),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text(snapshot.error.toString());
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        List<MultiPitchRoute> multiPitchRoutes = snapshot.data!.whereType<MultiPitchRoute>().toList();
        multiPitchRoutes.sort((a, b) => a.name.compareTo(b.name));

        updateMultiPitchRouteCallback(MultiPitchRoute route) {
          var index = -1;
          for (int i = 0; i < multiPitchRoutes.length; i++) {
            if (multiPitchRoutes[i].id == route.id) index = i;
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
          return FixedTimeline.tileBuilder(
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
                timeLineElements.add(RouteInfo(route: multiPitchRoute, onNetworkChange: widget.onNetworkChange));
                timeLineElements.add(Rating(rating: multiPitchRoute.rating));
                if (multiPitchRoute.mediaIds.isNotEmpty) {
                  timeLineElements.add(ExpansionTile(
                    leading: const Icon(Icons.image),
                    title: const Text("images"),
                    children: [ImageListView(mediaIds: multiPitchRoute.mediaIds)]
                  ));
                }
                if (multiPitchRoute.pitchIds.isNotEmpty) {
                  timeLineElements.add(MultiPitchInfo(pitchIds: multiPitchRoute.pitchIds, onNetworkChange: widget.onNetworkChange,));
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
          );
        }
        return const SizedBox.shrink();
      }
    );
  }
}