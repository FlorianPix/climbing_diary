import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:overlay_support/overlay_support.dart';
import '../components/diary_page/timeline.dart';
import '../interfaces/spot/spot.dart';
import '../services/cache.dart';
import '../services/spot_service.dart';

const kTileHeight = 50.0;

class DiaryPage extends StatefulWidget {
  const DiaryPage({super.key});

  @override
  State<StatefulWidget> createState() => DiaryPageState();
}

class DiaryPageState extends State<DiaryPage> {
  late Future<List<Spot>> futureSpots;

  final SpotService spotService = SpotService();

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
            deleteQueuedSpots();
            editQueuedSpots();
            uploadQueuedSpots();
            futureSpots = spotService.getSpots();
            return FutureBuilder<List<Spot>>(
              future: futureSpots,
              builder: (context, snapshot) {
                if(snapshot.hasData) {
                  var spots = snapshot.data!;

                  deleteCallback(spot) {
                    spots.remove(spot);
                    showSimpleNotification(
                      Text('${spot.name} was deleted'),
                      background: Colors.green,
                    );
                    setState(() {});
                  }

                  updateCallback(Spot spot) {
                    var index = -1;
                    for (int i = 0; i < spots.length; i++) {
                      if (spots[i].id == spot.id) {
                        index = i;
                      }
                    }
                    if (index != -1) {
                      spots.removeAt(index);
                      spots.add(spot);
                    }
                    showSimpleNotification(
                      Text('${spot.name} was updated'),
                      background: Colors.green,
                    );
                    setState(() {});
                  }

                  return Timeline(spots: spots, deleteCallback: deleteCallback, updateCallback: updateCallback);
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }
                return const CircularProgressIndicator();
              }
            );
          } else {
            // offline
            List<Spot> spots = getSpotsFromCache();

            deleteCallback(spot) {
              spots.remove(spot);
              setState(() {});
            }

            updateCallback(Spot spot) {
              var index = -1;
              for (int i = 0; i < spots.length; i++) {
                if (spots[i].id == spot.id) {
                  index = i;
                }
              }
              if (index != -1) {
                spots.removeAt(index);
                spots.add(spot);
              }
              setState(() {});
            }

            return Timeline(spots: spots, deleteCallback: deleteCallback, updateCallback: updateCallback);
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