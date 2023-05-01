import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../interfaces/trip/trip.dart';
import '../../interfaces/trip/update_trip.dart';
import '../../services/trip_service.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class EditTrip extends StatefulWidget {
  const EditTrip({super.key, required this.trip, required this.onUpdate});

  final Trip trip;
  final ValueSetter<Trip> onUpdate;

  @override
  State<StatefulWidget> createState() => _EditTripState();
}

class _EditTripState extends State<EditTrip>{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TripService tripService = TripService();
  final TextEditingController controllerTitle = TextEditingController();
  final TextEditingController controllerDate = TextEditingController();
  final TextEditingController controllerAddress = TextEditingController();
  final TextEditingController controllerLat = TextEditingController();
  final TextEditingController controllerLong = TextEditingController();
  final TextEditingController controllerDescription = TextEditingController();
  final TextEditingController controllerBus = TextEditingController();
  final TextEditingController controllerCar = TextEditingController();

  int currentSliderValue = 0;

  @override
  void initState(){
    controllerTitle.text = widget.trip.name;
    controllerDate.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    currentSliderValue = widget.trip.rating;
    controllerDescription.text = widget.trip.comment;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text('Edit this trip'),
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
                    hintText: "Name of the trip", labelText: "Title"),
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
                value: currentSliderValue.toDouble(),
                max: 5,
                divisions: 5,
                label: currentSliderValue.round().toString(),
                onChanged: (value) {
                  setState(() {
                    currentSliderValue = value.toInt();
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
        IconButton(
          onPressed: () async {
            bool result = await InternetConnectionChecker().hasConnection;
            if (_formKey.currentState!.validate()) {
              var valDistanceParking = int.tryParse(controllerCar.text);
              var valDistancePublicTransport = int.tryParse(controllerBus.text);
              UpdateTrip trip = UpdateTrip(
                id: widget.trip.id,
                name: controllerTitle.text,
                rating: currentSliderValue.toInt(),
                comment: controllerDescription.text,
              );
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              Trip? updatedTrip = await tripService.editTrip(trip);
              if (updatedTrip != null) {
                widget.onUpdate.call(updatedTrip);
              }
            }
          },
          icon: const Icon(Icons.save)
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }
}