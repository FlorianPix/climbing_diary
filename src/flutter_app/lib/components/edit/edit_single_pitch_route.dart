import 'package:climbing_diary/components/common/my_validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../interfaces/grade.dart';
import '../../interfaces/grading_system.dart';
import '../../interfaces/single_pitch_route/single_pitch_route.dart';
import '../../interfaces/single_pitch_route/update_single_pitch_route.dart';
import '../../services/single_pitch_route_service.dart';

class EditSinglePitchRoute extends StatefulWidget {
  const EditSinglePitchRoute({super.key, required this.route, required this.onUpdate});

  final SinglePitchRoute route;
  final ValueSetter<SinglePitchRoute> onUpdate;

  @override
  State<StatefulWidget> createState() => _EditSinglePitchRouteState();
}

class _EditSinglePitchRouteState extends State<EditSinglePitchRoute>{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final SinglePitchRouteService singlePitchRouteService = SinglePitchRouteService();
  final TextEditingController controllerComment = TextEditingController();
  final TextEditingController controllerLength = TextEditingController();
  final TextEditingController controllerLocation = TextEditingController();
  final TextEditingController controllerName = TextEditingController();
  final TextEditingController controllerRating = TextEditingController();

  int currentSliderValue = 0;
  GradingSystem gradingSystem = GradingSystem.french;
  String grade = Grade.translationTable[GradingSystem.french.index][0];

  @override
  void initState(){
    controllerComment.text = widget.route.comment;
    grade = widget.route.grade.grade;
    gradingSystem = widget.route.grade.system;
    controllerLength.text = widget.route.length.toString();
    controllerLocation.text = widget.route.location;
    controllerName.text = widget.route.name;
    currentSliderValue = widget.route.rating;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Edit this route'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                validator: (value) => MyValidators.notEmpty(value, "name"),
                controller: controllerName,
                decoration: const InputDecoration(hintText: "name", labelText: "name"),
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
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(hintText: "length of the route", labelText: "length"),
              ),
              TextFormField(
                controller: controllerLocation,
                decoration: const InputDecoration(labelText: "location"),
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
                    style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 16)
                  ),
                ),
              ),
              Slider(
                value: currentSliderValue.toDouble(),
                max: 5,
                divisions: 5,
                label: currentSliderValue.round().toString(),
                onChanged: (value) => setState(() => currentSliderValue = value.toInt()),
              ),
            ]
          ),
        ),
      ),
      actions: <Widget>[
        IconButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              UpdateSinglePitchRoute route = UpdateSinglePitchRoute(
                id: widget.route.id,
                comment: controllerComment.text,
                location: controllerLocation.text,
                name: controllerName.text,
                rating: currentSliderValue.toInt(),
                grade: Grade(grade: grade, system: gradingSystem),
                length: int.parse(controllerLength.text)
              );
              SinglePitchRoute? updatedRoute = await singlePitchRouteService.editSinglePitchRoute(route);
              if (updatedRoute != null) widget.onUpdate.call(updatedRoute);
              setState(() => Navigator.popUntil(context, ModalRoute.withName('/')));
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