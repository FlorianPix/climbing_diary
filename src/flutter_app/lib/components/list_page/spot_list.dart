import 'package:flutter/material.dart';

class SpotList extends StatefulWidget {
  const SpotList({super.key});

  @override
  State<StatefulWidget> createState() => SpotListState();
}

class SpotListState extends State<SpotList> {

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Text("spots"),
    );
  }
}