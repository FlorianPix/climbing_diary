import 'package:climbing_diary/components/diary_page/image_list_view.dart';
import 'package:climbing_diary/components/diary_page/rating_row.dart';
import 'package:climbing_diary/components/diary_page/timeline/spot_timeline.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:timelines/timelines.dart';

import '../../../interfaces/trip/trip.dart';
import '../../../services/trip_service.dart';
import '../../add/add_trip.dart';
import '../../detail/trip_details.dart';
import '../../info/trip_info.dart';

class TripTimeline extends StatefulWidget {
  const TripTimeline({super.key});

  @override
  State<StatefulWidget> createState() => TripTimelineState();
}

class TripTimelineState extends State<TripTimeline> {
  final TripService tripService = TripService();

  @override
  void initState(){
    super.initState();
    checkConnection();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkConnection(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var online = snapshot.data!;
          if (online) {
            return FutureBuilder<List<Trip>>(
              future: tripService.getTrips(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Trip> trips = snapshot.data!;
                  trips.sort((a, b) => DateTime.parse(b.startDate).compareTo(DateTime.parse(a.startDate)));

                  updateTripCallback(Trip trip) {
                    var index = -1;
                    for (int i = 0; i < trips.length; i++) {
                      if (trips[i].id == trip.id) {
                        index = i;
                      }
                    }
                    trips.removeAt(index);
                    trips.add(trip);
                    setState(() {});
                  }

                  deleteTripCallback(Trip spot) {
                    trips.remove(spot);
                    setState(() {});
                  }

                  return ListView(
                    padding: const EdgeInsets.all(20.0),
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.explore, size: 30.0),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddTrip(
                                  onAdd: (trip) {
                                    trips.add(trip);
                                    setState(() {});
                                  }
                                ),
                              )
                          );
                        },
                        label: const Text("add a new trip"),
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
                          itemCount: trips.length,
                          contentsBuilder: (_, index) {
                            List<Widget> elements = [];
                            // spot info
                            elements.add(TripInfo(trip: trips[index]));
                            // rating as hearts in a row
                            elements.add(RatingRow(rating: trips[index].rating));
                            // images list view
                            if (trips[index].mediaIds.isNotEmpty) {
                              elements.add(
                                  ImageListView(mediaIds: trips[index].mediaIds)
                              );
                            }
                            // spots
                            if (trips[index].spotIds.isNotEmpty){
                              elements.add(
                                SpotTimeline(
                                    trip: trips[index],
                                    spotIds: trips[index].spotIds,
                                    startDate: DateTime.parse(trips[index].startDate),
                                    endDate: DateTime.parse(trips[index].endDate),
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
                                            child: TripDetails(trip: trips[index],
                                                onTripDelete: deleteTripCallback,
                                                onTripUpdate: updateTripCallback,
                                                onSpotAdd: (spot) {
                                                  trips[index].spotIds.add(spot.id);
                                                  setState(() {});
                                                },
                                            )
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