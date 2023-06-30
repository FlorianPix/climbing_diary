import 'package:climbing_diary/pages/diary_page/timeline/route_timeline.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:timelines/timelines.dart';

import '../../../components/info/spot_info.dart';
import '../../../interfaces/spot/spot.dart';
import '../../../interfaces/trip/trip.dart';
import '../../../services/spot_service.dart';
import '../../../services/trip_service.dart';
import '../image_list_view.dart';
import '../rating_row.dart';
import '../spot_details.dart';

class SpotTimeline extends StatefulWidget {
  const SpotTimeline({super.key, required this.spotIds, required this.trip, required this.startDate, required this.endDate});

  final Trip trip;
  final List<String> spotIds;
  final DateTime startDate, endDate;

  @override
  State<StatefulWidget> createState() => SpotTimelineState();
}

class SpotTimelineState extends State<SpotTimeline> {
  final SpotService spotService = SpotService();
  final TripService tripService = TripService();

  @override
  void initState(){
    super.initState();
    checkConnection();
  }

  @override
  Widget build(BuildContext context) {
    List<String> spotIds = widget.spotIds;
    return FutureBuilder<bool>(
      future: checkConnection(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var online = snapshot.data!;
          if (online) {

            return FutureBuilder<List<Spot?>>(
              future: Future.wait(spotIds.map((spotId) => spotService.getSpot(spotId))),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
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
                            elements.add(SpotInfo(spot: spots[index]));
                            // rating as hearts in a row
                            elements.add(RatingRow(rating: spots[index].rating));
                            // images list view
                            if (spots[index].mediaIds.isNotEmpty) {
                              elements.add(
                                  ImageListView(mediaIds: spots[index].mediaIds)
                              );
                            }
                            // routes
                            if (spots[index].multiPitchRouteIds.isNotEmpty || spots[index].singlePitchRouteIds.isNotEmpty){
                              elements.add(
                                  RouteTimeline(
                                      trip: widget.trip,
                                      spot: spots[index],
                                      singlePitchRouteIds: spots[index].singlePitchRouteIds,
                                      multiPitchRouteIds: spots[index].multiPitchRouteIds,
                                      startDate: widget.startDate,
                                      endDate: widget.endDate,
                                  )
                              );
                            }
                            return InkWell(
                              onTap: () =>
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        Dialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: SpotDetails(
                                                trip: widget.trip,
                                                spot: spots[index],
                                                onDelete: deleteSpotCallback,
                                                onUpdate: updateSpotCallback)
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
                      )]
                  )],
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