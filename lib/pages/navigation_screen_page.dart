import 'dart:convert';
import 'dart:ffi';

import 'statistic_page.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';


class NavigationScreenPage extends StatefulWidget {
  const NavigationScreenPage({super.key});

  @override
  State<NavigationScreenPage> createState() => _NavigationScreenPage();
}

class _NavigationScreenPage extends State<NavigationScreenPage> {
  int _counter = 0;
  LatLng targetLocation = LatLng(50.746036, 10.642666);
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String address = "";
  List values = [1, 2, 3, 4, 5];

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        body: OpenStreetMapSearchAndPick(
          center: LatLong(50.746036, 10.642666),
          buttonColor: Colors.orange,
          buttonText: 'Set location',
          onPicked: (pickedData) {
            double lat = pickedData.latLong.latitude;
            double long = pickedData.latLong.longitude;
            setState(() {
              targetLocation = LatLng(lat, long);
              address = pickedData.address;
            });
            openFormDialog(context, targetLocation, address);
          },
        )
    );
  }

  Future <void> openFormDialog(BuildContext context, LatLng coordinates, String address) async {
    return await showDialog(
        context: context,
        builder: (context) {
          final TextEditingController _controller = TextEditingController();
          final TextEditingController _controllerAddress = TextEditingController();
          final TextEditingController _controllerLat = TextEditingController();
          final TextEditingController _controllerLong = TextEditingController();
          _controllerAddress.text = address;
          _controllerLat.text = coordinates.latitude.toString();
          _controllerLong.text = coordinates.longitude.toString();
          return AlertDialog(
              title: Text('Add a new spot'),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      validator: (value) {
                        if (value == null) {
                          return "Please add a title";
                        }
                      },
                      controller: _controller,
                      decoration:
                      InputDecoration(hintText: "Name of the spot", labelText: "Title"),
                    ),
                    TextFormField(
                      controller: _controllerAddress,
                      decoration: InputDecoration(labelText: "Address"),
                    ),
                    TextFormField(
                      controller: _controllerLat,
                      decoration: InputDecoration(labelText: "Latitude"),
                    ),
                    TextFormField(
                      controller: _controllerLong,
                      decoration: InputDecoration(labelText: "Longitude"),
                    ),
                    TextFormField(
                      validator: (value) {
                        if (values!.contains(value)) {
                          return "Please add right rating number";
                        }
                      },
                      controller: _controller,
                      decoration: InputDecoration(hintText: "Plese give a rating from 1 to 5 stars", labelText: "Rating"),
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value == null) {
                          return "Please add description";
                        }
                      },
                      controller: _controller,
                      decoration: InputDecoration(hintText: "Description", labelText: "Description"),
                    ),
                    TextFormField(
                      controller: _controller,
                      decoration: InputDecoration(hintText: "in minutes", labelText: "Route by bus"),
                    ),
                    TextFormField(
                      controller: _controller,
                      decoration: InputDecoration(hintText: "in minutes", labelText: "Route by car"),
                    )
                  ],
                ),
              ),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    if(_formKey.currentState!.validate() == true) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text("Save"))
            ],
          );
        }
    );
  }

}