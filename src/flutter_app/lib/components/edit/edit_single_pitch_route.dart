import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../interfaces/grade.dart';
import '../../interfaces/grading_system.dart';
import '../../interfaces/single_pitch_route/single_pitch_route.dart';
import '../../interfaces/single_pitch_route/update_single_pitch_route.dart';
import '../../services/route_service.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class EditSinglePitchRoute extends StatefulWidget {
  const EditSinglePitchRoute({super.key, required this.route, required this.onUpdate});

  final SinglePitchRoute route;
  final ValueSetter<SinglePitchRoute> onUpdate;

  @override
  State<StatefulWidget> createState() => _EditSinglePitchRouteState();
}

class _EditSinglePitchRouteState extends State<EditSinglePitchRoute>{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final RouteService routeService = RouteService();
  final TextEditingController controllerComment = TextEditingController();
  final TextEditingController controllerGrade = TextEditingController();
  final TextEditingController controllerLength = TextEditingController();
  final TextEditingController controllerLocation = TextEditingController();
  final TextEditingController controllerName = TextEditingController();
  final TextEditingController controllerRating = TextEditingController();

  int currentSliderValue = 0;
  GradingSystem? gradingSystem;

  @override
  void initState(){
    controllerComment.text = widget.route.comment;
    controllerGrade.text = widget.route.grade.grade;
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text('Edit this route'),
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
                    : "please add a name";
                },
                controller: controllerName,
                decoration: const InputDecoration(
                    hintText: "name of the route", labelText: "name"),
              ),
              TextFormField(
                controller: controllerGrade,
                decoration: const InputDecoration(
                    hintText: "grade of the route", labelText: "grade"),
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
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                decoration: const InputDecoration(
                    hintText: "length of the route", labelText: "length"),
              ),
              TextFormField(
                controller: controllerLocation,
                decoration: const InputDecoration(labelText: "location"),
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
            if (_formKey.currentState!.validate() && gradingSystem != null) {
              UpdateSinglePitchRoute route = UpdateSinglePitchRoute(
                id: widget.route.id,
                comment: controllerComment.text,
                location: controllerLocation.text,
                name: controllerName.text,
                rating: currentSliderValue.toInt(),
                grade: Grade(grade: controllerGrade.text, system: gradingSystem!),
                length: int.parse(controllerLength.text)
              );
              SinglePitchRoute? updatedRoute = await routeService.editSinglePitchRoute(route);
              if (updatedRoute != null) {
                widget.onUpdate.call(updatedRoute);
              }
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