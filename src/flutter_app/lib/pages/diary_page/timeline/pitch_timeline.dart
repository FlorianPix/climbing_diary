import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:timelines/timelines.dart';

import '../../../components/detail/pitch_details.dart';
import '../../../components/image_list_view.dart';
import '../../../components/info/pitch_info.dart';
import '../../../components/rating.dart';
import '../../../interfaces/pitch/pitch.dart';
import '../../../interfaces/route/route.dart';
import '../../../interfaces/spot/spot.dart';
import '../../../interfaces/trip/trip.dart';
import '../../../services/pitch_service.dart';
import 'ascent_timeline.dart';
import 'my_timeline_theme_data.dart';

class PitchTimeline extends StatefulWidget {
  const PitchTimeline({super.key, this.trip, required this.spot, required this.route, required this.pitchIds, required this.onNetworkChange});

  final Trip? trip;
  final Spot spot;
  final ClimbingRoute route;
  final List<String> pitchIds;
  final ValueSetter<bool> onNetworkChange;

  @override
  State<StatefulWidget> createState() => PitchTimelineState();
}

class PitchTimelineState extends State<PitchTimeline> {
  final PitchService pitchService = PitchService();

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
    List<String> pitchIds = widget.pitchIds;
    return FutureBuilder<List<Pitch>>(
      future: pitchService.getPitchesOfIds(online, pitchIds),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text(snapshot.error.toString());
        if (!snapshot.hasData) return const CircularProgressIndicator();
        List<Pitch> pitches = snapshot.data!;
        pitches.sort((a, b) {
          if (a.num > b.num) return 1;
          return a.num < b.num ? -1 : 0;
        });

        updatePitchCallback(Pitch pitch) {
          var index = -1;
          for (int i = 0; i < pitches.length; i++) {
            if (pitches[i].id == pitch.id) index = i;
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
              theme: MyTimeLineThemeData.defaultTheme,
              builder: TimelineTileBuilder.connected(
                connectionDirection: ConnectionDirection.before,
                itemCount: pitches.length,
                contentsBuilder: (_, index) {
                  List<Widget> elements = [];
                  elements.add(PitchInfo(pitch: pitches[index], onNetworkChange: widget.onNetworkChange));
                  elements.add(Rating(rating: pitches[index].rating));
                  if (pitches[index].mediaIds.isNotEmpty) {
                    elements.add(ExpansionTile(
                      leading: const Icon(Icons.image),
                      title: const Text("images"),
                      children: [ImageListView(mediaIds: pitches[index].mediaIds)]
                    ));
                  }
                  if (pitches[index].ascentIds.isNotEmpty){
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
                        route: widget.route,
                        pitchId: pitches[index].id,
                        ascentIds: pitches[index].ascentIds,
                        onUpdate: (ascent) {
                          // TODO
                        },
                        onDelete: (ascent) {
                          pitches[index].ascentIds.remove(ascent.id);
                          setState(() {});
                        },
                        startDate: startDate,
                        endDate: endDate,
                        ofMultiPitch: true,
                        onNetworkChange: widget.onNetworkChange,
                      )]
                    ));
                  }
                  return InkWell(
                    onTap: () => showDialog(
                      context: context,
                      builder: (BuildContext context) => Dialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: PitchDetails(
                          trip: widget.trip,
                          spot: widget.spot,
                          route: widget.route,
                          pitch: pitches[index],
                          onDelete: deletePitchCallback,
                          onUpdate: updatePitchCallback,
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
            )
          ])],
        );
      }
    );
  }
}