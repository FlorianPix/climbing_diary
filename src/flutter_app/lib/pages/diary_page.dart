import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../components/diary_page/timeline.dart';
import '../interfaces/spot.dart';
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
            futureSpots = spotService.getSpots();
            return FutureBuilder<List<Spot>>(
              future: futureSpots,
              builder: (context, snapshot) {
                if(snapshot.hasData) {
                  var spots = snapshot.data!;
                  spots.sort((a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));

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
                    spots.removeAt(index);
                    spots.add(spot);
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
            return const Scaffold(
                body: Center(child: Text('No connection'),)
            );
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