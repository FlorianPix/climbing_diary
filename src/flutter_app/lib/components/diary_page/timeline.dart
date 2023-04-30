import 'package:climbing_diary/components/diary_page/image_list_view.dart';
import 'package:climbing_diary/components/diary_page/rating_row.dart';
import 'package:climbing_diary/components/diary_page/spot_info.dart';
import 'package:flutter/material.dart';
import 'package:timelines/timelines.dart';

import '../../interfaces/spot.dart';
import '../spot_details.dart';
import 'inner_timeline.dart';

class Timeline extends StatelessWidget {
  const Timeline({super.key,
    required this.spots,
    required this.deleteCallback,
    required this.updateCallback
  });

  final List<Spot> spots;
  final ValueSetter<Spot> deleteCallback;
  final ValueSetter<Spot> updateCallback;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [FixedTimeline.tileBuilder(
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

            // TODO routes
            elements.add(
                InnerTimeline(routes: spots[index].routeIds)
            );

            return InkWell(
              onTap: () =>
                  showDialog(
                    context: context,
                    builder: (BuildContext context) =>
                        Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: SpotDetails(spot: spots[index],
                                onDelete: deleteCallback,
                                onUpdate: updateCallback)
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
          const SolidLineConnector(
            color: Color(0xff66c97f),
          ),
        ),
      )
      ],
    );
  }
}