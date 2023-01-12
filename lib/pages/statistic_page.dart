import 'package:flutter/material.dart';

class StatisticPage extends StatelessWidget {
  const StatisticPage({super.key});

  @override
  //Just a test case for "Save spot" - feature
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      padding: EdgeInsets.all(32),
      child: ElevatedButton(
        child: Text('open a dialog'),
        onPressed: () {
          openFormDialog(context);
        },
      ),
    )
  );
  Future openFormDialog(BuildContext context) => showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Add a new spot'),
      contentPadding: EdgeInsets.zero,
      content: Padding (
        padding: EdgeInsets.all(20.0),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.2) )
          ),
          child: TextField(decoration: InputDecoration(hintText: 'Description'),),
        ),
      ),
    ),
  );
}