import 'package:climbing_diary/pages/diary_page/timeline/route_timeline.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:timelines/timelines.dart';

import '../../../components/info/spot_info.dart';
import '../../../components/rating.dart';
import '../../../interfaces/spot/spot.dart';
import '../../../interfaces/trip/trip.dart';
import '../../../services/spot_service.dart';
import '../../../services/trip_service.dart';
import '../image_list_view.dart';
import '../spot_details.dart';

class SpotTimeline extends StatefulWidget {
  const SpotTimeline({super.key, required this.spotIds, required this.trip, required this.startDate, required this.endDate, required this.onNetworkChange});

  final Trip trip;
  final List<String> spotIds;
  final DateTime startDate, endDate;
  final ValueSetter<bool> onNetworkChange;

  @override
  State<StatefulWidget> createState() => SpotTimelineState();
}

class SpotTimelineState extends State<SpotTimeline> {
  final SpotService spotService = SpotService();
  final TripService tripService = TripService();

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
    List<String> spotIds = widget.spotIds;
    return FutureBuilder<List<Spot?>>(
      future: spotService.getSpotsOfIds(online, spotIds),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }
        List<Spot> spots = snapshot.data!.whereType<Spot>().toList();
        spots.sort((a, b) => a.name.compareTo(b.name));

        updateSpotCallback(Spot spot) {
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

        deleteSpotCallback(Spot spot) {
          spots.remove(spot);
          widget.trip.spotIds.remove(spot.id);
          setState(() {});
        }

        return Column(children: [ExpansionTile(
          leading: const Icon(Icons.place),
          title: const Text("spots"),
          children: [
            FixedTimeline.tileBuilder(
              theme: TimelineThemeData(
                nodePosition: 0,
                color: const Color(0xff989898),
                indicatorTheme: const IndicatorThemeData(position: 0, size: 20.0),
                connectorTheme: const ConnectorThemeData(thickness: 2.5),
              ),
              builder: TimelineTileBuilder.connected(
                connectionDirection: ConnectionDirection.before,
                itemCount: spots.length,
                contentsBuilder: (_, index) {
                  List<Widget> elements = [];
                  elements.add(SpotInfo(spot: spots[index]));
                  elements.add(Rating(rating: spots[index].rating));
                  if (spots[index].mediaIds.isNotEmpty) {
                    elements.add(ExpansionTile(
                      leading: const Icon(Icons.image),
                      title: const Text("images"),
                      children: [ImageListView(mediaIds: spots[index].mediaIds)]
                    ));
                  }
                  if (spots[index].multiPitchRouteIds.isNotEmpty || spots[index].singlePitchRouteIds.isNotEmpty){
                    elements.add(RouteTimeline(
                      trip: widget.trip,
                      spot: spots[index],
                      singlePitchRouteIds: spots[index].singlePitchRouteIds,
                      multiPitchRouteIds: spots[index].multiPitchRouteIds,
                      startDate: widget.startDate,
                      endDate: widget.endDate,
                      onNetworkChange: widget.onNetworkChange,
                    ));
                  }
                  return InkWell(
                    onTap: () => showDialog(
                      context: context,
                      builder: (BuildContext context) => Dialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: SpotDetails(
                          trip: widget.trip,
                          spot: spots[index],
                          onDelete: deleteSpotCallback,
                          onUpdate: updateSpotCallback,
                          onNetworkChange: widget.onNetworkChange,
                        )
                      ),
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
            )]
        )],
        );
      }
    );
  }
}