import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:timelines/timelines.dart';

import '../../../interfaces/spot/spot.dart';
import '../../../services/spot_service.dart';
import '../../components/detail/spot_details.dart';
import '../../components/info/spot_info.dart';
import '../diary_page/image_list_view.dart';
import '../diary_page/rating_row.dart';

class SpotList extends StatefulWidget {
  const SpotList({super.key, required this.spots});

  final List<Spot> spots;

  @override
  State<StatefulWidget> createState() => SpotListState();
}

class SpotListState extends State<SpotList> {
  final SpotService spotService = SpotService();

  @override
  void initState(){
    super.initState();
    checkConnection();
  }

  @override
  Widget build(BuildContext context) {
    List<Spot> spots = widget.spots;
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
                                spot: spots[index],
                                onDelete: (Spot value) {  },
                                onUpdate: (Spot value) {  },
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
  }

  Future<bool> checkConnection() async {
    return await InternetConnectionChecker().hasConnection;
  }
}