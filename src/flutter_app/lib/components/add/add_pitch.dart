import 'package:flutter/material.dart';
import 'package:climbing_diary/interfaces/grading_system.dart';
import 'package:climbing_diary/interfaces/grade.dart';
import 'package:climbing_diary/interfaces/pitch/pitch.dart';
import 'package:climbing_diary/interfaces/route/route.dart';
import 'package:climbing_diary/services/pitch_service.dart';
import 'package:climbing_diary/components/common/my_text_styles.dart';
import 'package:uuid/uuid.dart';

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
  final TextEditingController controllerLength = TextEditingController();
  final TextEditingController controllerName = TextEditingController();
  final TextEditingController controllerNum = TextEditingController();
  final TextEditingController controllerRating = TextEditingController();

  double currentSliderValue = 0;
  GradingSystem gradingSystem = GradingSystem.french;
  String grade = Grade.translationTable[GradingSystem.french.index][0];

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Add a new pitch'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.route.name, style: MyTextStyles.title),
              TextFormField(
                validator: (value) => value!.isNotEmpty ? null : "please add a name",
                controller: controllerName,
                decoration: const InputDecoration(hintText: "name of the pitch", labelText: "name"),
              ),
              TextFormField(
                validator: (value) {
                  if (value!.isEmpty) return "please add a pitch number";
                  if (!isNumeric(value)) return "pitch number must be a number";
                  return null;
                },
                controller: controllerNum,
                decoration: const InputDecoration(hintText: "pitch number", labelText: "pitch number"),
              ),
              DropdownButton<String>(
                value: grade,
                items: Grade.translationTable[gradingSystem.index].toSet().map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value)
                  );
                }).toList(),
                onChanged: (String? value) => setState(() => grade = value!),
              ),
              DropdownButton<GradingSystem>(
                value: gradingSystem,
                items: GradingSystem.values.map<DropdownMenuItem<GradingSystem>>((GradingSystem value) {
                  return DropdownMenuItem<GradingSystem>(
                    value: value,
                    child: Text(value.toShortString())
                  );
                }).toList(),
                onChanged: (GradingSystem? value) => setState(() {
                  int oldIndex = Grade.translationTable[gradingSystem.index].indexOf(grade);
                  gradingSystem = value!;
                  grade = Grade.translationTable[gradingSystem.index][oldIndex];
                }),
              ),
              TextFormField(
                controller: controllerLength,
                decoration: const InputDecoration(hintText: "length in m", labelText: "length"),
              ),
              TextFormField(
                controller: controllerComment,
                decoration: const InputDecoration(hintText: "comment", labelText: "comment"),
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
                onChanged: (value) => setState(() => currentSliderValue = value),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              Pitch pitch = Pitch(
                comment: controllerComment.text,
                grade: Grade(grade: grade, system: gradingSystem),
                length: int.parse(controllerLength.text),
                name: controllerName.text,
                num: int.parse(controllerNum.text),
                rating: currentSliderValue.toInt(),
                updated: DateTime.now().toIso8601String(),
                ascentIds: [],
                mediaIds: [],
                id: const Uuid().v4(),
                userId: '',
              );
              await pitchService.createPitch(pitch, widget.route.id);
              setState(() => Navigator.popUntil(context, ModalRoute.withName('/')));
            }
          },
          child: const Text("Save"))
      ],
    );
  }
}