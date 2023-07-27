import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:timelines/timelines.dart';

import '../../../components/detail/pitch_details.dart';
import '../../../components/info/pitch_info.dart';
import '../../../components/rating.dart';
import '../../../interfaces/pitch/pitch.dart';
import '../../../interfaces/route/route.dart';
import '../../../interfaces/spot/spot.dart';
import '../../../interfaces/trip/trip.dart';
import '../../../services/pitch_service.dart';
import '../image_list_view.dart';

class PitchTimeline extends StatefulWidget {
  const PitchTimeline({super.key, this.trip, required this.spot, required this.route, required this.pitchIds});

  final Trip? trip;
  final Spot spot;
  final ClimbingRoute route;
  final List<String> pitchIds;

  @override
  State<StatefulWidget> createState() => PitchTimelineState();
}

class PitchTimelineState extends State<PitchTimeline> {
  final PitchService pitchService = PitchService();

  @override
  void initState(){
    super.initState();
    checkConnection();
  }

  @override
  Widget build(BuildContext context) {
    List<String> pitchIds = widget.pitchIds;
    return FutureBuilder<bool>(
      future: checkConnection(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var online = snapshot.data!;
          if (online) {
            return FutureBuilder<List<Pitch>>(
              future: pitchService.getPitchesOfIds(online, pitchIds),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Pitch> pitches = snapshot.data!;
                  pitches.sort((a, b) {
                    if (a.num > b.num) {
                      return 1;
                    } else {
                      return a.num < b.num ? -1 : 0;
                    }
                  });

                  updatePitchCallback(Pitch pitch) {
                    var index = -1;
                    for (int i = 0; i < pitches.length; i++) {
                      if (pitches[i].id == pitch.id) {
                        index = i;
                      }
                    }
                    pitches.removeAt(index);
                    pitches.add(pitch);
                    setState(() {});
                  }

                  deletePitchCallback(Pitch pitch) {
                    pitches.remove(pitch);
                    setState(() {});
                  }

                  return Column(children: [ExpansionTile(
                    leading: const Icon(Icons.commit),
                    title: const Text("pitches"),
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
                          itemCount: pitches.length,
                          contentsBuilder: (_, index) {
                            List<Widget> elements = [];
                            // pitch info
                            elements.add(PitchInfo(pitch: pitches[index]));
                            // rating as hearts in a row
                            elements.add(Rating(rating: pitches[index].rating));
                            // images list view
                            if (pitches[index].mediaIds.isNotEmpty) {
                              elements.add(ExpansionTile(
                                  leading: const Icon(Icons.image),
                                  title: const Text("images"),
                                  children: [ImageListView(mediaIds: pitches[index].mediaIds)]
                              ));
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
                                            child: PitchDetails(trip: widget.trip, spot: widget.spot, route: widget.route, pitch: pitches[index],
                                                onDelete: deletePitchCallback,
                                                onUpdate: updatePitchCallback)
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
                    ])],
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