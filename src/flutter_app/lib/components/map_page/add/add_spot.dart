import 'package:climbing_diary/interfaces/trip/update_trip.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../../interfaces/spot/create_spot.dart';
import '../../../interfaces/spot/spot.dart';
import '../../../interfaces/trip/trip.dart';
import '../../../services/spot_service.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../../../services/trip_service.dart';

class AddSpot extends StatefulWidget {
  const AddSpot({super.key, required this.trips, required this.coordinates, required this.address, required this.onAdd});

  final LatLng coordinates;
  final String address;
  final ValueSetter<Spot> onAdd;
  final List<Trip> trips;

  @override
  State<StatefulWidget> createState() => _AddSpotState();
}

class _AddSpotState extends State<AddSpot>{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final SpotService spotService = SpotService();
  final TripService tripService = TripService();
  final TextEditingController controllerTitle = TextEditingController();
  final TextEditingController controllerDate = TextEditingController();
  final TextEditingController controllerAddress = TextEditingController();
  final TextEditingController controllerLat = TextEditingController();
  final TextEditingController controllerLong = TextEditingController();
  final TextEditingController controllerComment = TextEditingController();
  final TextEditingController controllerBus = TextEditingController();
  final TextEditingController controllerCar = TextEditingController();

  double currentSliderValue = 0;
  Trip? dropdownValue;

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

    List<Widget> elements = [];

    elements.add(
        TextFormField(
          validator: (value) {
            return value!.isNotEmpty
                ? null
                : "Please add a name";
          },
          controller: controllerTitle,
          decoration: const InputDecoration(
              hintText: "name", labelText: "name"),
        )
    );
    elements.add(DropdownButton<Trip>(
        isExpanded: true,
        value: dropdownValue,
        items: widget.trips.map<DropdownMenuItem<Trip>>((Trip trip) {
          return DropdownMenuItem<Trip>(
            value: trip,
            child: Text(trip.name),
          );
        }).toList(),
        onChanged: (Trip? trip) {
          setState(() {
            dropdownValue = trip!;
          });
        }
    ));
    elements.add(TextFormField(
      controller: controllerAddress,
      decoration: const InputDecoration(labelText: "address"),
    ));
    elements.add(TextFormField(
      controller: controllerLat,
      decoration: const InputDecoration(labelText: "latitude"),
    ));
    elements.add(TextFormField(
      controller: controllerLong,
      decoration: const InputDecoration(labelText: "longitude"),
    ));
    elements.add(Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(
            "rating",
            style: TextStyle(
                color: Colors.black.withOpacity(0.6),
                fontSize: 16
            )
        ),
      ),
    ));
    elements.add(Slider(
      value: currentSliderValue,
      max: 5,
      divisions: 5,
      label: currentSliderValue.round().toString(),
      onChanged: (value) {
        setState(() {
          currentSliderValue = value;
        });
      },
    ));
    elements.add(TextFormField(
      controller: controllerComment,
      decoration: const InputDecoration(
          hintText: "comment", labelText: "comment"
      ),
    ));
    elements.add(TextFormField(
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
          labelText: "Distance to public transport station"
      ),
    ));
    elements.add(TextFormField(
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
          labelText: "Distance to parking"
      ),
    ));

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
                children: elements,
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
                comment: controllerComment.text,
                coordinates: [double.parse(controllerLat.text), double.parse(controllerLong.text)],
                distanceParking: (valDistanceParking != null) ? valDistanceParking : 0,
                distancePublicTransport: (valDistancePublicTransport != null) ? valDistancePublicTransport : 0,
                location: controllerAddress.text,
                name: controllerTitle.text,
                rating: currentSliderValue.toInt(),
              );
              Navigator.popUntil(context, ModalRoute.withName('/'));
              Spot? createdSpot = await spotService.createSpot(spot, result);
              UpdateTrip editTrip = dropdownValue!.toUpdateTrip();
              if (createdSpot != null) {
                editTrip.spotIds?.add(createdSpot.id);
                Trip? editedTrip = await tripService.editTrip(editTrip);
                widget.onAdd.call(createdSpot);
              }
            }
          },
          child: const Icon(Icons.save))
      ],
    );
  }
}