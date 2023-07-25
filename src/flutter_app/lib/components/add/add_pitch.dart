import 'package:climbing_diary/interfaces/grading_system.dart';
import 'package:flutter/material.dart';

import '../../interfaces/grade.dart';
import '../../interfaces/pitch/create_pitch.dart';
import '../../interfaces/pitch/pitch.dart';
import '../../interfaces/route/route.dart';
import '../../services/pitch_service.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../my_text_styles.dart';

class AddPitch extends StatefulWidget {
  const AddPitch({super.key, required this.route});

  final ClimbingRoute route;

  @override
  State<StatefulWidget> createState() => _AddPitchState();
}

class _AddPitchState extends State<AddPitch>{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final PitchService pitchService = PitchService();
  final TextEditingController controllerComment = TextEditingController();
  final TextEditingController controllerGrade = TextEditingController();
  final TextEditingController controllerLength = TextEditingController();
  final TextEditingController controllerName = TextEditingController();
  final TextEditingController controllerNum = TextEditingController();
  final TextEditingController controllerRating = TextEditingController();

  double currentSliderValue = 0;
  GradingSystem gradingSystem = GradingSystem.french;

  bool isNumeric(String s) {
    return double.tryParse(s) != null;
  }

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
              Text(
                widget.route.name,
                style: MyTextStyles.title,
              ),
              TextFormField(
                validator: (value) {
                  return value!.isNotEmpty ? null : "please add a name";
                },
                controller: controllerName,
                decoration: const InputDecoration(
                    hintText: "name of the pitch", labelText: "name"),
              ),
              TextFormField(
                validator: (value) {
                  if (value!.isEmpty){
                    return "please add a pitch number";
                  }
                  if (!isNumeric(value)){
                    return "pitch number must be a number";
                  }
                  return null;
                },
                controller: controllerNum,
                decoration: const InputDecoration(
                    hintText: "pitch number", labelText: "pitch number"),
              ),
              TextFormField(
                controller: controllerGrade,
                decoration: const InputDecoration(
                    hintText: "grade", labelText: "grade"),
              ),
              DropdownButton<GradingSystem>(
                value: gradingSystem,
                items: GradingSystem.values.map<DropdownMenuItem<GradingSystem>>((GradingSystem value) {
                  return DropdownMenuItem<GradingSystem>(
                    value: value,
                    child: Text(value.toShortString())
                  );
                }).toList(),
                onChanged: (GradingSystem? value) {
                  setState(() {
                    gradingSystem = value!;
                  });
                },
              ),
              TextFormField(
                controller: controllerLength,
                decoration: const InputDecoration(
                    hintText: "length in m", labelText: "length"),
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
                  grade: Grade(grade: controllerGrade.text, system: gradingSystem),
                  length: int.parse(controllerLength.text),
                  name: controllerName.text,
                  num: int.parse(controllerNum.text),
                  rating: currentSliderValue.toInt(),
                );
                Pitch? createdPitch = await pitchService.createPitch(pitch, widget.route.id, result);
                setState(() => Navigator.popUntil(context, ModalRoute.withName('/')));
              }
            },
            child: const Text("Save"))
      ],
    );
  }
}