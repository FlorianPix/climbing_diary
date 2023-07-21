import 'package:flutter/material.dart';

class Rating extends StatelessWidget{
  const Rating({super.key, required this.rating});

  final int rating;

  @override
  Widget build(BuildContext context) {
    List<Widget> ratingRowElements = [];
    for (var i = 0; i < 5; i++){
      if (rating > i) {
        ratingRowElements.add(const Icon(Icons.favorite, size: 30.0, color: Colors.pink));
      } else {
        ratingRowElements.add(const Icon(Icons.favorite, size: 30.0, color: Colors.grey));
      }
    }

    return Center(child: Padding(
        padding: const EdgeInsets.all(10),
        child:Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ratingRowElements,
        )
    ));
  }
}