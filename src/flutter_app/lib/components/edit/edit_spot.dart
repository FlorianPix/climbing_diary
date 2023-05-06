import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../interfaces/spot/spot.dart';
import '../../interfaces/spot/update_spot.dart';
import '../../services/spot_service.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class EditSpot extends StatefulWidget {
  const EditSpot({super.key, required this.spot, required this.onUpdate});

  final Spot spot;
  final ValueSetter<Spot> onUpdate;

  @override
  State<StatefulWidget> createState() => _EditSpotState();
}

class _EditSpotState extends State<EditSpot>{
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

  int currentSliderValue = 0;

  @override
  void initState(){
    controllerTitle.text = widget.spot.name;
    controllerDate.text = widget.spot.date;
    controllerAddress.text = widget.spot.location;
    controllerLat.text = widget.spot.coordinates[0].toString();
    controllerLong.text = widget.spot.coordinates[1].toString();
    currentSliderValue = widget.spot.rating;
    controllerDescription.text = widget.spot.comment;
    controllerBus.text = widget.spot.distancePublicTransport.toString();
    controllerCar.text = widget.spot.distanceParking.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text('Edit this spot'),
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
              UpdateSpot spot = UpdateSpot(
                id: widget.spot.id,
                name: controllerTitle.text,
                coordinates: [double.parse(controllerLat.text), double.parse(controllerLong.text)],
                location: controllerAddress.text,
                rating: currentSliderValue.toInt(),
                distanceParking: (valDistanceParking != null) ? valDistanceParking : 0,
                distancePublicTransport: (valDistancePublicTransport != null) ? valDistancePublicTransport : 0,
                comment: controllerDescription.text,
              );
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              Spot? updatedSpot = await spotService.editSpot(spot);
              if (updatedSpot != null) {
                widget.onUpdate.call(updatedSpot);
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