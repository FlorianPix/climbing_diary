import 'package:flutter/material.dart';

class Comment extends StatelessWidget{
  const Comment({super.key, required this.comment});

  final String comment;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(15.0),
      padding: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(comment)
    );
  }
}