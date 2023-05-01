import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../interfaces/pitch/create_pitch.dart';
import '../../interfaces/pitch/pitch.dart';
import '../../services/pitch_service.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../../services/pitch_service.dart';

class AddPitch extends StatefulWidget {
  const AddPitch({super.key});

  @override
  State<StatefulWidget> createState() => _AddPitchState();
}

class _AddPitchState extends State<AddPitch>{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final PitchService pitchService = PitchService();
  final TextEditingController controllerRouteId = TextEditingController();
  final TextEditingController controllerComment = TextEditingController();
  final TextEditingController controllerGrade = TextEditingController();
  final TextEditingController controllerLength = TextEditingController();
  final TextEditingController controllerName = TextEditingController();
  final TextEditingController controllerNum = TextEditingController();
  final TextEditingController controllerRating = TextEditingController();

  double currentSliderValue = 0;

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text('Add a new pitch'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: controllerRouteId,
                decoration: const InputDecoration(
                    hintText: "route id", labelText: "route id"),
              ),
              TextFormField(
                validator: (value) {
                  return value!.isNotEmpty
                      ? null
                      : "please add a name";
                },
                controller: controllerName,
                decoration: const InputDecoration(
                    hintText: "name of the pitch", labelText: "name"),
              ),
              TextFormField(
                controller: controllerNum,
                decoration: const InputDecoration(
                    hintText: "pitch number", labelText: "pitch number"),
              ),
              TextFormField(
                controller: controllerGrade,
                decoration: const InputDecoration(
                    hintText: "grade", labelText: "grade"),
              ),
              TextFormField(
                controller: controllerLength,
                decoration: const InputDecoration(
                    hintText: "length", labelText: "length"),
              ),
              TextFormField(
                controller: controllerComment,
                decoration: const InputDecoration(
                    hintText: "comment", labelText: "comment"),
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
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
            onPressed: () async {
              bool result = await InternetConnectionChecker().hasConnection;
              if (_formKey.currentState!.validate()) {
                CreatePitch pitch = CreatePitch(
                  comment: controllerComment.text,
                  grade: controllerGrade.text,
                  length: int.parse(controllerLength.text),
                  name: controllerName.text,
                  num: int.parse(controllerNum.text),
                  rating: currentSliderValue.toInt(),
                );
                Navigator.of(context).pop();
                Pitch? createdPitch = await pitchService.createPitch(pitch, controllerRouteId.text, result);
              }
            },
            child: const Text("Save"))
      ],
    );
  }
}