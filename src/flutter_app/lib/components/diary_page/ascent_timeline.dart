import 'package:climbing_diary/components/diary_page/image_list_view.dart';
import 'package:climbing_diary/interfaces/route/route.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:timelines/timelines.dart';

import '../../interfaces/ascent/ascent.dart';
import '../../interfaces/pitch/pitch.dart';
import '../../interfaces/trip/trip.dart';
import '../../interfaces/spot/spot.dart';
import '../../services/ascent_service.dart';
import '../detail/ascent_details.dart';
import '../info/ascent_info.dart';

class AscentTimeline extends StatefulWidget {
  const AscentTimeline({super.key, this.trip, required this.spot, required this.route, required this.pitch, required this.ascentIds, required this.onDelete, required this.onUpdate});

  final Trip? trip;
  final Spot spot;
  final ClimbingRoute route;
  final Pitch pitch;
  final List<String> ascentIds;
  final ValueSetter<Ascent> onDelete;
  final ValueSetter<Ascent> onUpdate;

  @override
  State<StatefulWidget> createState() => AscentTimelineState();
}

class AscentTimelineState extends State<AscentTimeline> {
  final AscentService ascentService = AscentService();

  @override
  void initState(){
    super.initState();
    checkConnection();
  }

  @override
  Widget build(BuildContext context) {
    List<String> ascentIds = widget.ascentIds;
    return FutureBuilder<bool>(
      future: checkConnection(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var online = snapshot.data!;
          if (online) {
            return FutureBuilder<List<Ascent>>(
              future: Future.wait(ascentIds.map((ascentId) => ascentService.getAscent(ascentId))),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Ascent> ascents = snapshot.data!;
                  ascents.sort((a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));

                  updateAscentCallback(Ascent ascent) {
                    var index = -1;
                    for (int i = 0; i < ascents.length; i++) {
                      if (ascents[i].id == ascent.id) {
                        index = i;
                      }
                    }
                    ascents.removeAt(index);
                    ascents.add(ascent);
                    widget.onUpdate.call(ascent);
                    setState(() {});
                  }

                  deleteAscentCallback(Ascent ascent) {
                    ascents.remove(ascent);
                    ascentIds.remove(ascent.id);
                    widget.onDelete.call(ascent);
                    setState(() {});
                  }

                  return Column(
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
                          itemCount: ascents.length,
                          contentsBuilder: (_, index) {
                            List<Widget> elements = [];
                            // ascent info
                            elements.add(AscentInfo(ascent: ascents[index]));
                            // images list view
                            if (ascents[index].mediaIds.isNotEmpty) {
                              elements.add(
                                  ImageListView(mediaIds: ascents[index].mediaIds)
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
                                            child: AscentDetails(
                                                pitch: widget.pitch,
                                                ascent: ascents[index],
                                                onDelete: deleteAscentCallback,
                                                onUpdate: updateAscentCallback
                                            ),
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