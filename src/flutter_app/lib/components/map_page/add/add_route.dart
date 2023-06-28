import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../interfaces/grade.dart';
import '../../../interfaces/grading_system.dart';
import '../../../interfaces/multi_pitch_route/create_multi_pitch_route.dart';
import '../../../interfaces/route/route.dart';
import '../../../interfaces/single_pitch_route/create_single_pitch_route.dart';
import '../../../interfaces/spot/spot.dart';
import '../../../services/route_service.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class AddRoute extends StatefulWidget {
  const AddRoute({super.key, required this.spots, this.onAdd});

  final List<Spot> spots;
  final ValueSetter<ClimbingRoute>? onAdd;

  @override
  State<StatefulWidget> createState() => _AddRouteState();
}

class _AddRouteState extends State<AddRoute>{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final RouteService routeService = RouteService();
  final TextEditingController controllerSpotId = TextEditingController();
  final TextEditingController controllerComment = TextEditingController();
  final TextEditingController controllerLocation = TextEditingController();
  final TextEditingController controllerName = TextEditingController();
  final TextEditingController controllerRating = TextEditingController();
  final TextEditingController controllerGrade = TextEditingController();
  final TextEditingController controllerLength = TextEditingController();

  double currentSliderValue = 0;
  Spot? dropdownValue;
  GradingSystem? gradingSystem;
  bool isMultiPitch = false;

  @override
  void initState(){
    dropdownValue = widget.spots[0];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text('Add a new route'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(children: [
                const Text("Multi-pitch"),
                Switch(
                  value: isMultiPitch,
                  onChanged: (bool value) {
                    setState(() {
                      isMultiPitch = value;
                    });
                  }
                )]
              ),
              Visibility(
                visible: !isMultiPitch,
                child: TextFormField(
                  controller: controllerGrade,
                  decoration: const InputDecoration(
                      hintText: "grade of the route", labelText: "grade"),
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
                  onChanged: (GradingSystem? value) {
                    setState(() {
                      gradingSystem = value!;
                    });
                  },
                )
              ),
              Visibility(
                visible: !isMultiPitch,
                child:TextFormField(
                  controller: controllerLength,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  decoration: const InputDecoration(
                      hintText: "length of the route", labelText: "length"),
                ),
              ),
              DropdownButton<Spot>(
                  value: dropdownValue,
                  items: widget.spots.map<DropdownMenuItem<Spot>>((Spot spot) {
                    return DropdownMenuItem<Spot>(
                        value: spot,
                        child: Text(spot.name),
                    );
                  }).toList(),
                  onChanged: (Spot? spot) {
                    setState(() {
                      dropdownValue = spot!;
                    });
                  }
              ),
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
                controller: controllerLocation,
                decoration: const InputDecoration(
                    hintText: "location of the route", labelText: "location"),
              ),
              TextFormField(
                controller: controllerComment,
                decoration: const InputDecoration(
                    hintText: "comment about the route", labelText: "comment"),
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
                Navigator.popUntil(context, ModalRoute.withName('/'));
                final dropdownValue = this.dropdownValue;
                if (dropdownValue != null){
                  ClimbingRoute? createdRoute;
                  if (isMultiPitch){
                    CreateMultiPitchRoute route = CreateMultiPitchRoute(
                      name: controllerName.text,
                      location: controllerLocation.text,
                      rating: currentSliderValue.toInt(),
                      comment: controllerComment.text,
                    );
                    createdRoute = await routeService.createMultiPitchRoute(route, dropdownValue.id, result);
                  } else {
                    CreateSinglePitchRoute route = CreateSinglePitchRoute(
                      name: controllerName.text,
                      location: controllerLocation.text,
                      rating: currentSliderValue.toInt(),
                      comment: controllerComment.text,
                      grade: Grade(grade: controllerGrade.text, system: gradingSystem!),
                      length: int.parse(controllerLength.text)
                    );
                    createdRoute = await routeService.createSinglePitchRoute(route, dropdownValue.id, result);
                  }
                  widget.onAdd?.call(createdRoute!);
                  setState(() {});
                }
              }
            },
            child: const Text("Save"))
      ],
    );
  }
}