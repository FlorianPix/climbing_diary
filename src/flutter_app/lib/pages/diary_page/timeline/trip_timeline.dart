import 'package:climbing_diary/pages/diary_page/timeline/spot_timeline.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:timelines/timelines.dart';

import '../../../components/add/add_trip.dart';
import '../../../components/detail/trip_details.dart';
import 'package:climbing_diary/components/common/image_list_view.dart';
import '../../../components/info/trip_info.dart';
import 'package:climbing_diary/components/common/rating.dart';
import '../../../interfaces/trip/trip.dart';
import '../../../services/trip_service.dart';
import 'my_timeline_theme_data.dart';

class TripTimeline extends StatefulWidget {
  const TripTimeline({super.key, required this.onNetworkChange});
  final ValueSetter<bool> onNetworkChange;

  @override
  State<StatefulWidget> createState() => TripTimelineState();
}

class TripTimelineState extends State<TripTimeline> {
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
    return FutureBuilder<List<Trip>>(
      future: tripService.getTrips(false),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text(snapshot.error.toString());
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        List<Trip> trips = snapshot.data!;
        trips.sort((a, b) => DateTime.parse(b.startDate).compareTo(DateTime.parse(a.startDate)));

        updateTripCallback(Trip trip) {
          var index = -1;
          for (int i = 0; i < trips.length; i++) {
            if (trips[i].id == trip.id) index = i;
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
              onPressed: () => Navigator.push(context, MaterialPageRoute(
                builder: (context) => AddTrip(onAdd: (trip) {
                  trips.add(trip);
                  setState(() {});
                }),
              )),
              label: const Text("add a new trip"),
            ),
            FixedTimeline.tileBuilder(
              theme: MyTimeLineThemeData.defaultTheme,
              builder: TimelineTileBuilder.connected(
                connectionDirection: ConnectionDirection.before,
                itemCount: trips.length,
                contentsBuilder: (_, index) {
                  List<Widget> elements = [];
                  elements.add(TripInfo(trip: trips[index]));
                  elements.add(Rating(rating: trips[index].rating));
                  if (trips[index].mediaIds.isNotEmpty) {
                    elements.add(ExpansionTile(
                      leading: const Icon(Icons.image),
                      title: const Text("images"),
                      children: [ImageListView(mediaIds: trips[index].mediaIds)]
                    ));
                  }
                  if (trips[index].spotIds.isNotEmpty){
                    elements.add(SpotTimeline(
                      trip: trips[index],
                      spotIds: trips[index].spotIds,
                      startDate: DateTime.parse(trips[index].startDate),
                      endDate: DateTime.parse(trips[index].endDate),
                      onNetworkChange: widget.onNetworkChange,
                    ));
                  }
                  return InkWell(
                    onTap: () => showDialog(
                      context: context,
                      builder: (BuildContext context) => Dialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: TripDetails(trip: trips[index],
                          onTripDelete: deleteTripCallback,
                          onTripUpdate: updateTripCallback,
                          onSpotAdd: (spot) {
                            trips[index].spotIds.add(spot.id);
                            setState(() {});
                          },
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
            )
          ],
        );
      }
    );
  }
}