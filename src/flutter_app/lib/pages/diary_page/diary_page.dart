import 'package:climbing_diary/pages/diary_page/timeline/trip_timeline.dart';
import 'package:flutter/material.dart';

class DiaryPage extends StatefulWidget {
  const DiaryPage({super.key});

  @override
  State<StatefulWidget> createState() => DiaryPageState();
}

class DiaryPageState extends State<DiaryPage> {

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const TripTimeline();
  }
}