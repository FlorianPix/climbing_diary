import 'package:climbing_diary/interfaces/single_pitch_route/single_pitch_route.dart';
import 'package:climbing_diary/pages/diary_page/timeline/my_timeline_theme_data.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:timelines/timelines.dart';

import '../../../interfaces/spot/spot.dart';
import '../../../interfaces/trip/trip.dart';
import 'package:climbing_diary/components/detail/single_pitch_route_details.dart';
import 'package:climbing_diary/components/info/single_pitch_route_info.dart';
import 'package:climbing_diary/components/common/rating.dart';
import 'package:climbing_diary/components/common/image_list_view.dart';
import '../../services/single_pitch_route_service.dart';
import '../diary_page/timeline/ascent_timeline.dart';

class SinglePitchRouteList extends StatefulWidget {
  const SinglePitchRouteList({super.key, this.trip, required this.spot, required this.singlePitchRouteIds, required this.onNetworkChange});

  final Trip? trip;
  final Spot spot;
  final List<String> singlePitchRouteIds;
  final ValueSetter<bool> onNetworkChange;

  @override
  State<StatefulWidget> createState() => SinglePitchRouteListState();
}

class SinglePitchRouteListState extends State<SinglePitchRouteList> {
  final SinglePitchRouteService singlePitchRouteService = SinglePitchRouteService();

  void checkConnection() async {
    await InternetConnectionChecker().hasConnection.then((value) {
      widget.onNetworkChange.call(value);
      setState(() {});
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

    return FutureBuilder<List<SinglePitchRoute?>>(
      future: singlePitchRouteService.getSinglePitchRoutesOfIds(singlePitchRouteIds),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text(snapshot.error.toString());
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        List<SinglePitchRoute> singlePitchRoutes = snapshot.data!.whereType<SinglePitchRoute>().toList();
        singlePitchRoutes.sort((a, b) => a.name.compareTo(b.name));

        void updateSinglePitchRouteCallback(SinglePitchRoute route) {
          var index = -1;
          for (int i = 0; i < singlePitchRoutes.length; i++) {
            if (singlePitchRoutes[i].id == route.id) index = i;
          }
          singlePitchRoutes.removeAt(index);
          singlePitchRoutes.add(route);
          setState(() {});
        }

        void deleteSinglePitchRouteCallback(SinglePitchRoute route) {
          singlePitchRoutes.remove(route);
          singlePitchRouteIds.remove(route.id);
          setState(() {});
        }

        if (singlePitchRoutes.isNotEmpty){
          return FixedTimeline.tileBuilder(
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
                        setState(() {});
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
          );
        }
        return const SizedBox.shrink();
      }
    );
  }
}