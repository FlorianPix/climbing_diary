import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:overlay_support/overlay_support.dart';
import '../components/diary_page/timeline.dart';
import '../interfaces/trip/trip.dart';
import '../interfaces/trip/trip.dart';
import '../services/cache.dart';
import '../services/trip_service.dart';

const kTileHeight = 50.0;

class DiaryPage extends StatefulWidget {
  const DiaryPage({super.key});

  @override
  State<StatefulWidget> createState() => DiaryPageState();
}

class DiaryPageState extends State<DiaryPage> {

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
      builder: (context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.hasData) {
          var online = snapshot.data!;
          if (online) {
            // TODO deleteQueuedTrips();
            // TODO editQueuedTrips();
            // TODO uploadQueuedTrips();
            return FutureBuilder<List<Trip>>(
              future:  tripService.getTrips(),
              builder: (context, snapshot) {
                if(snapshot.hasData) {
                  var trips = snapshot.data!;

                  deleteCallback(trip) {
                    trips.remove(trip);
                    showSimpleNotification(
                      Text('${trip.name} was deleted'),
                      background: Colors.green,
                    );
                    setState(() {});
                  }

                  updateCallback(Trip trip) {
                    var index = -1;
                    for (int i = 0; i < trips.length; i++) {
                      if (trips[i].id == trip.id) {
                        index = i;
                      }
                    }
                    if (index != -1) {
                      trips.removeAt(index);
                      trips.add(trip);
                    }
                    showSimpleNotification(
                      Text('${trip.name} was updated'),
                      background: Colors.green,
                    );
                    setState(() {});
                  }

                  return Timeline(trips: trips, deleteCallback: deleteCallback, updateCallback: updateCallback);
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }
                return const CircularProgressIndicator();
              }
            );
          } else {
            // offline
            List<Trip> trips = getTripsFromCache();

            deleteCallback(Trip trip) {
              trips.remove(trip);
              setState(() {});
            }

            updateCallback(Trip trip) {
              var index = -1;
              for (int i = 0; i < trips.length; i++) {
                if (trips[i].id == trip.id) {
                  index = i;
                }
              }
              if (index != -1) {
                trips.removeAt(index);
                trips.add(trip);
              }
              setState(() {});
            }

            return Timeline(trips: trips, deleteCallback: deleteCallback, updateCallback: updateCallback);
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