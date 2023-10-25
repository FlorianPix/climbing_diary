import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:timelines/timelines.dart';
import 'package:climbing_diary/interfaces/route/route.dart';
import 'package:climbing_diary/components/detail/ascent_details.dart';
import 'package:climbing_diary/components/info/ascent_info.dart';
import 'package:climbing_diary/interfaces/ascent/ascent.dart';
import 'package:climbing_diary/interfaces/trip/trip.dart';
import 'package:climbing_diary/interfaces/spot/spot.dart';
import 'package:climbing_diary/services/ascent_service.dart';
import 'package:climbing_diary/components/common/image_list_view.dart';
import 'package:climbing_diary/pages/diary_page/timeline/my_timeline_theme_data.dart';

class AscentTimeline extends StatefulWidget {
  const AscentTimeline({super.key, this.trip, required this.spot, required this.route, required this.pitchId, required this.ascentIds, required this.onDelete, required this.onUpdate, required this.startDate, required this.endDate, required this.ofMultiPitch, required this.onNetworkChange});

  final Trip? trip;
  final Spot spot;
  final ClimbingRoute route;
  final String pitchId;
  final List<String> ascentIds;
  final ValueSetter<Ascent> onDelete, onUpdate;
  final DateTime startDate, endDate;
  final bool ofMultiPitch;
  final ValueSetter<bool> onNetworkChange;

  @override
  State<StatefulWidget> createState() => AscentTimelineState();
}

class AscentTimelineState extends State<AscentTimeline> {
  final AscentService ascentService = AscentService();

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
    List<String> ascentIds = widget.ascentIds;
    return FutureBuilder<List<Ascent>>(
      future: ascentService.getAscentsOfIds(ascentIds),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text(snapshot.error.toString());
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        List<Ascent> ascents = snapshot.data!;
        ascents.retainWhere((ascent) {
          DateTime dateOfAscent = DateTime.parse(ascent.date);
          if ((dateOfAscent.isAfter(widget.startDate) && dateOfAscent.isBefore(widget.endDate))) return true;
          if (dateOfAscent.isAtSameMomentAs(widget.startDate)) return true;
          if (dateOfAscent.isAtSameMomentAs(widget.endDate)) return true;
          return false;
        });
        ascents.sort((a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));

        void updateAscentCallback(Ascent ascent) {
          var index = -1;
          for (int i = 0; i < ascents.length; i++) {
            if (ascents[i].id == ascent.id) index = i;
          }
          ascents.removeAt(index);
          ascents.add(ascent);
          widget.onUpdate.call(ascent);
          setState(() {});
        }

        void deleteAscentCallback(Ascent ascent) {
          ascents.remove(ascent);
          ascentIds.remove(ascent.id);
          widget.onDelete.call(ascent);
          setState(() {});
        }

        return Column(children: [FixedTimeline.tileBuilder(
          theme: MyTimeLineThemeData.defaultTheme,
          builder: TimelineTileBuilder.connected(
            connectionDirection: ConnectionDirection.before,
            itemCount: ascents.length,
            contentsBuilder: (_, index) {
              List<Widget> elements = [];
              elements.add(AscentInfo(ascent: ascents[index]));
              if (ascents[index].mediaIds.isNotEmpty) {
                elements.add(ExpansionTile(
                  leading: const Icon(Icons.image),
                  title: const Text("images"),
                  children: [ImageListView(mediaIds: ascents[index].mediaIds)]
                ));
              }
              return InkWell(onTap: () => showDialog(
                context: context,
                builder: (BuildContext context) => Dialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: AscentDetails(
                    pitchId: widget.pitchId,
                    ascent: ascents[index],
                    onDelete: deleteAscentCallback,
                    onUpdate: updateAscentCallback,
                    ofMultiPitch: widget.ofMultiPitch,
                  ),
                )),
                child: Ink(child: Padding(padding: const EdgeInsets.only(left: 8.0), child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: elements,
                ))),
              );
            },
            indicatorBuilder: (_, __) => const OutlinedDotIndicator(borderWidth: 2.5, color: Colors.green),
            connectorBuilder: (_, __, ___) => const SolidLineConnector(color: Colors.green),
          ),
        )]);
      }
    );
  }
}