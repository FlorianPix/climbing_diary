import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../interfaces/create_spot.dart';
import '../interfaces/spot.dart';
import '../services/spot_service.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class AddSpot extends StatefulWidget {
  const AddSpot({super.key, required this.coordinates, required this.address, required this.onAdd});

  final LatLng coordinates;
  final String address;
  final ValueSetter<Spot> onAdd;

  @override
  State<StatefulWidget> createState() => _AddSpotState();
}

class _AddSpotState extends State<AddSpot>{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final SpotService spotService = SpotService();
  final TextEditingController controllerTitle = TextEditingController();
  final TextEditingController controllerDate = TextEditingController();
  final TextEditingController controllerAddress = TextEditingController();
  final TextEditingController controllerLat = TextEditingController();
  final TextEditingController controllerLong = TextEditingController();
  final TextEditingController controllerDescription = TextEditingController();
  final TextEditingController controllerBus = TextEditingController();
  final TextEditingController controllerCar = TextEditingController();

  double currentSliderValue = 0;

  @override
  void initState(){
    controllerDate.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                controller: controllerDate,
                decoration: const InputDecoration(
                  icon: Icon(Icons.calendar_today),
                  labelText: "Enter Date"
                ),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                      context: context, initialDate: DateTime.now(),
                      firstDate: DateTime(1923),
                      lastDate: DateTime(2123)
                  );
                  if(pickedDate != null ){
                    String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                    setState(() {
                      controllerDate.text = formattedDate; //set output date to TextField value.
                    });
                  }
                },
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
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    "Rating",
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.6),
                      fontSize: 16
                    )
                  ),
                ),
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
                controller: controllerDescription,
                decoration: const InputDecoration(
                  hintText: "Description", labelText: "Description"),
              ),
              TextFormField(
                validator: (value) {
                  if (value != null && value != ""){
                    var i = int.tryParse(value);
                    if (i == null) {
                      return "Must be a number";
                    }
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
                  if (value != null && value != ""){
                    var i = int.tryParse(value);
                    if (i == null) {
                      return "Must be a number";
                    }
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
            bool result = await InternetConnectionChecker().hasConnection;
            if (_formKey.currentState!.validate()) {
              var valDistanceParking = int.tryParse(controllerCar.text);
              var valDistancePublicTransport = int.tryParse(controllerBus.text);
              CreateSpot spot = CreateSpot(
                date: controllerDate.text,
                name: controllerTitle.text,
                coordinates: [widget.coordinates.latitude, widget.coordinates.longitude],
                location: [widget.address],
                rating: currentSliderValue.toInt(),
                distanceParking: (valDistanceParking != null) ? valDistanceParking : 0,
                distancePublicTransport: (valDistancePublicTransport != null) ? valDistancePublicTransport : 0,
                comment: controllerDescription.text,
              );
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              Spot? createdSpot = await spotService.createSpot(spot, result);
              if (createdSpot != null) {
                widget.onAdd.call(createdSpot);
              }
            }
          },
          child: const Text("Save"))
      ],
    );
  }
}