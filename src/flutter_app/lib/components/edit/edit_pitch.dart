import 'package:climbing_diary/interfaces/grading_system.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../interfaces/grade.dart';
import '../../interfaces/pitch/pitch.dart';
import '../../interfaces/pitch/update_pitch.dart';
import '../../services/pitch_service.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class EditPitch extends StatefulWidget {
  const EditPitch({super.key, required this.pitch, required this.onUpdate});

  final Pitch pitch;
  final ValueSetter<Pitch> onUpdate;

  @override
  State<StatefulWidget> createState() => _EditPitchState();
}

class _EditPitchState extends State<EditPitch>{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final PitchService pitchService = PitchService();
  final TextEditingController controllerComment = TextEditingController();
  final TextEditingController controllerGrade = TextEditingController();
  final TextEditingController controllerSystem = TextEditingController();
  final TextEditingController controllerLength = TextEditingController();
  final TextEditingController controllerName = TextEditingController();
  final TextEditingController controllerNum = TextEditingController();

  int currentSliderValue = 0;

  @override
  void initState(){
    controllerComment.text = widget.pitch.comment;
    controllerGrade.text = widget.pitch.grade.grade;
    controllerSystem.text = widget.pitch.grade.system.toString();
    controllerLength.text = widget.pitch.length.toString();
    controllerName.text = widget.pitch.name;
    controllerNum.text = widget.pitch.num.toString();
    currentSliderValue = widget.pitch.rating;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text('Edit this pitch'),
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
                controller: controllerName,
                decoration: const InputDecoration(
                    hintText: "name", labelText: "name"),
              ),
              TextFormField(
                controller: controllerNum,
                decoration: const InputDecoration(
                    hintText: "num", labelText: "num"),
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
            ]
          ),
        ),
      ),
      actions: <Widget>[
        IconButton(
          onPressed: () async {
            bool result = await InternetConnectionChecker().hasConnection;
            if (_formKey.currentState!.validate()) {
              UpdatePitch pitch = UpdatePitch(
                id: widget.pitch.id,
                comment: controllerComment.text,
                grade: Grade(grade: controllerGrade.text, system: GradingSystem.values[int.parse(controllerSystem.text)]),
                length: int.parse(controllerLength.text),
                name: controllerName.text,
                num: int.parse(controllerNum.text),
                rating: currentSliderValue.toInt(),
              );
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              Pitch? updatedPitch = await pitchService.editPitch(pitch);
              if (updatedPitch != null) {
                widget.onUpdate.call(updatedPitch);
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