
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../interfaces/spot.dart';

Future<Spot> fetchSpot() async {
  final response = await http
      .get(Uri.parse('http://10.0.2.2:8000/spot-63b99ed93ee7caef721029cd'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Spot.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load spots');
  }
}