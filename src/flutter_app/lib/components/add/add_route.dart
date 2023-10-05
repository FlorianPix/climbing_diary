import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:climbing_diary/interfaces/grade.dart';
import 'package:climbing_diary/interfaces/grading_system.dart';
import 'package:climbing_diary/interfaces/multi_pitch_route/create_multi_pitch_route.dart';
import 'package:climbing_diary/interfaces/multi_pitch_route/multi_pitch_route.dart';
import 'package:climbing_diary/interfaces/single_pitch_route/create_single_pitch_route.dart';
import 'package:climbing_diary/interfaces/single_pitch_route/single_pitch_route.dart';
import 'package:climbing_diary/interfaces/spot/spot.dart';
import 'package:climbing_diary/services/multi_pitch_route_service.dart';
import 'package:climbing_diary/services/single_pitch_route_service.dart';
import 'package:climbing_diary/components/common/my_text_styles.dart';

class AddRoute extends StatefulWidget {
  const AddRoute({super.key, required this.spot, this.onAddMultiPitchRoute, this.onAddSinglePitchRoute});

  final Spot spot;
  final ValueSetter<MultiPitchRoute>? onAddMultiPitchRoute;
  final ValueSetter<SinglePitchRoute>? onAddSinglePitchRoute;

  @override
  State<StatefulWidget> createState() => _AddRouteState();
}

class _AddRouteState extends State<AddRoute>{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final MultiPitchRouteService multiPitchRouteService = MultiPitchRouteService();
  final SinglePitchRouteService singlePitchRouteService = SinglePitchRouteService();
  final TextEditingController controllerComment = TextEditingController();
  final TextEditingController controllerLocation = TextEditingController();
  final TextEditingController controllerName = TextEditingController();
  final TextEditingController controllerRating = TextEditingController();
  final TextEditingController controllerLength = TextEditingController();

  double currentSliderValue = 0;
  GradingSystem gradingSystem = GradingSystem.french;
  String grade = Grade.translationTable[GradingSystem.french.index][0];
  bool isMultiPitch = false;

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Spot spot = widget.spot;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Add a new route'),
      content: SingleChildScrollView(child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(spot.name, style: MyTextStyles.title),
              TextFormField(
                validator: (value) => value!.isNotEmpty ? null : "please add a name",
                controller: controllerName,
                decoration: const InputDecoration(hintText: "name of the route", labelText: "name"),
              ),
              Row(children: [
                const Text("Multi-pitch"),
                Switch(
                  value: isMultiPitch,
                  onChanged: (bool value) => setState(() => isMultiPitch = value)
                )]
              ),
              Visibility(
                visible: !isMultiPitch,
                child: DropdownButton<String>(
                  value: grade,
                  items: Grade.translationTable[gradingSystem.index].toSet().map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value)
                    );
                  }).toList(),
                  onChanged: (String? value) => setState(() => grade = value!),
                ),
              ),
              Visibility(
                visible: !isMultiPitch,
                child: DropdownButton<GradingSystem>(
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
                )
              ),
              Visibility(
                visible: !isMultiPitch,
                child:TextFormField(
                  validator: (value) => value!.isNotEmpty ? null : "please add the length",
                  controller: controllerLength,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(hintText: "length", labelText: "length"),
                ),
              ),
              TextFormField(
                controller: controllerLocation,
                decoration: const InputDecoration(hintText: "location", labelText: "location"),
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
                if (isMultiPitch){
                  CreateMultiPitchRoute route = CreateMultiPitchRoute(
                    name: controllerName.text,
                    location: controllerLocation.text,
                    rating: currentSliderValue.toInt(),
                    comment: controllerComment.text,
                  );
                  MultiPitchRoute? createdRoute = await multiPitchRouteService.createMultiPitchRoute(route, spot.id);
                  widget.onAddMultiPitchRoute?.call(createdRoute!);
                } else {
                  CreateSinglePitchRoute route = CreateSinglePitchRoute(
                    name: controllerName.text,
                    location: controllerLocation.text,
                    rating: currentSliderValue.toInt(),
                    comment: controllerComment.text,
                    grade: Grade(grade: grade, system: gradingSystem),
                    length: int.parse(controllerLength.text)
                  );
                  SinglePitchRoute? createdRoute = await singlePitchRouteService.createSinglePitchRoute(route, spot.id);
                  widget.onAddSinglePitchRoute?.call(createdRoute!);
                }
                setState(() => Navigator.popUntil(context, ModalRoute.withName('/')));
              }
            },
            child: const Text("Save"))
      ],
    );
  }
}