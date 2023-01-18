import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../interfaces/create_spot.dart';
import '../services/spot_service.dart';

class AddSpot extends StatefulWidget {
  const AddSpot({super.key, required this.coordinates, required this.address});

  final LatLng coordinates;
  final String address;

  @override
  State<StatefulWidget> createState() => _AddSpotState();
}

class _AddSpotState extends State<AddSpot>{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final SpotService spotService = SpotService();
  double currentSliderValue = 0;

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController controllerTitle = TextEditingController();
    final TextEditingController controllerAddress = TextEditingController();
    final TextEditingController controllerLat = TextEditingController();
    final TextEditingController controllerLong = TextEditingController();
    final TextEditingController controllerDescription = TextEditingController();
    final TextEditingController controllerBus = TextEditingController();
    final TextEditingController controllerCar = TextEditingController();
    controllerAddress.text = widget.address;
    controllerLat.text = widget.coordinates.latitude.toString();
    controllerLong.text = widget.coordinates.longitude.toString();
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text('Add a new spot'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                validator: (value) {
                  return value!.isNotEmpty
                      ? null
                      : "Please add a title";
                },
                controller: controllerTitle,
                decoration: const InputDecoration(
                    hintText: "Name of the spot", labelText: "Title"),
              ),
              TextFormField(
                controller: controllerAddress,
                decoration: const InputDecoration(labelText: "Address"),
              ),
              TextFormField(
                controller: controllerLat,
                decoration: const InputDecoration(labelText: "Latitude"),
              ),
              TextFormField(
                controller: controllerLong,
                decoration: const InputDecoration(labelText: "Longitude"),
              ),
              Slider(
                value: currentSliderValue,
                max: 5,
                divisions: 5,
                label: currentSliderValue.round().toString(),
                onChanged: (value) {
                  setState(() {
                    currentSliderValue = value;
                  });
                },
              ),
              TextFormField(
                validator: (value) {
                  if (value == null) {
                    return "Please add description";
                  }
                  return null;
                },
                controller: controllerDescription,
                decoration: const InputDecoration(
                    hintText: "Description", labelText: "Description"),
              ),
              TextFormField(
                validator: (value) {
                  if (value.runtimeType != String) {
                    return "Just a number please";
                  }
                  return null;
                },
                controller: controllerBus,
                decoration: const InputDecoration(
                    hintText: "in minutes",
                    labelText: "Distance to public transport station"),
              ),
              TextFormField(
                validator: (value) {
                  if (value.runtimeType != String) {
                    return "Just a number please";
                  }
                  return null;
                },
                controller: controllerCar,
                decoration: const InputDecoration(
                    hintText: "in minutes",
                    labelText: "Distance to parking"),
              )
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                var now = DateTime.now();
                var formatter = DateFormat('yyyy-MM-dd');
                String formattedDate = formatter.format(now);
                CreateSpot spot = CreateSpot(date: formattedDate, name: controllerTitle.text, coordinates: [widget.coordinates.latitude, widget.coordinates.longitude], location: [widget.address], routes: [], rating: currentSliderValue.toInt(), distanceParking: int.parse(controllerCar.text), distancePublicTransport: int.parse(controllerBus.text), comment: controllerDescription.text, mediaIds: []);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                await spotService.createSpot(spot);
              }
            },
            child: const Text("Save"))
      ],
    );
  }
}