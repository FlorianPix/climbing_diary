import 'package:flutter/material.dart';
import '../components/diary_page/trip_timeline.dart';

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