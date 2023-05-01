import 'package:climbing_diary/components/diary_page/image_list_view.dart';
import 'package:climbing_diary/components/diary_page/rating_row.dart';
import 'package:climbing_diary/components/info/spot_info.dart';
import 'package:flutter/material.dart';
import 'package:timelines/timelines.dart';

import '../../interfaces/spot/spot.dart';
import '../../interfaces/trip/trip.dart';
import '../detail/spot_details.dart';
import '../detail/trip_details.dart';
import '../info/trip_info.dart';
import 'inner_timeline.dart';

class Timeline extends StatelessWidget {
  const Timeline({super.key,
    required this.trips,
    required this.deleteCallback,
    required this.updateCallback
  });

  final List<Trip> trips;
  final ValueSetter<Trip> deleteCallback;
  final ValueSetter<Trip> updateCallback;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20.0),
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
            itemCount: trips.length,
            contentsBuilder: (_, index) {
              List<Widget> elements = [];

              // spot info
              elements.add(TripInfo(trip: trips[index]));

              // rating as hearts in a row
              elements.add(RatingRow(rating: trips[index].rating));

              // images list view
              if (trips[index].mediaIds.isNotEmpty) {
                elements.add(ImageListView(mediaIds: trips[index].mediaIds));

              }
              // spots
              if (trips[index].spotIds.isNotEmpty){
                elements.add(InnerTimeline(spots: trips[index].spotIds));
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
                              child: TripDetails(trip: trips[index],
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