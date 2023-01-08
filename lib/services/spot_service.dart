
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../interfaces/spot.dart';

Future<List<Spot>> fetchSpots() async {
  final response = await http
      .get(Uri.parse('http://10.0.2.2:8000/spots'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response, then parse the JSON.
    List<Spot> spots = [];
    jsonDecode(response.body).forEach((s) => {
      spots.add(Spot.fromJson(s))
    });
    return spots;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load spots');
  }
}

Future<Spot> fetchSpot(String spotId) async {
  final response = await http
      .get(Uri.parse('http://10.0.2.2:8000/spot-$spotId'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response, then parse the JSON.
    return Spot.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load spots');
  }
}