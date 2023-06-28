import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../interfaces/multi_pitch_route/multi_pitch_route.dart';
import '../../interfaces/multi_pitch_route/update_multi_pitch_route.dart';
import '../../interfaces/route/route.dart';
import '../../interfaces/route/update_route.dart';
import '../../services/route_service.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class EditMultiPitchRoute extends StatefulWidget {
  const EditMultiPitchRoute({super.key, required this.route, required this.onUpdate});

  final MultiPitchRoute route;
  final ValueSetter<MultiPitchRoute> onUpdate;

  @override
  State<StatefulWidget> createState() => _EditMultiPitchRouteState();
}

class _EditMultiPitchRouteState extends State<EditMultiPitchRoute>{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final RouteService routeService = RouteService();
  final TextEditingController controllerName = TextEditingController();
  final TextEditingController controllerDate = TextEditingController();
  final TextEditingController controllerLocation = TextEditingController();
  final TextEditingController controllerComment = TextEditingController();

  int currentSliderValue = 0;

  @override
  void initState(){
    controllerName.text = widget.route.name;
    controllerDate.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    controllerLocation.text = widget.route.location;
    currentSliderValue = widget.route.rating;
    controllerComment.text = widget.route.comment;
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
                    : "Please add a title";
                },
                controller: controllerName,
                decoration: const InputDecoration(
                    hintText: "name", labelText: "name"),
              ),
              TextFormField(
                controller: controllerLocation,
                decoration: const InputDecoration(labelText: "location"),
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
                controller: controllerComment,
                decoration: const InputDecoration(
                  hintText: "Description", labelText: "Description"),
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
              UpdateMultiPitchRoute route = UpdateMultiPitchRoute(
                id: widget.route.id,
                comment: controllerComment.text,
                location: controllerLocation.text,
                name: controllerName.text,
                rating: currentSliderValue.toInt(),
              );
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              MultiPitchRoute? updatedRoute = await routeService.editMultiPitchRoute(route);
              if (updatedRoute != null) {
                widget.onUpdate.call(updatedRoute);
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