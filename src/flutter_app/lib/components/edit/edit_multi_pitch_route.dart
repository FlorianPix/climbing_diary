import 'package:climbing_diary/components/my_validators.dart';
import 'package:climbing_diary/interfaces/multi_pitch_route/update_multi_pitch_route.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../interfaces/multi_pitch_route/multi_pitch_route.dart';
import '../../services/multi_pitch_route_service.dart';

class EditMultiPitchRoute extends StatefulWidget {
  const EditMultiPitchRoute({super.key, required this.route, required this.onUpdate});

  final MultiPitchRoute route;
  final ValueSetter<MultiPitchRoute> onUpdate;

  @override
  State<StatefulWidget> createState() => _EditMultiPitchRouteState();
}

class _EditMultiPitchRouteState extends State<EditMultiPitchRoute>{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final MultiPitchRouteService multiPitchRouteService = MultiPitchRouteService();
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
              TextFormField(
                controller: controllerComment,
                decoration: const InputDecoration(hintText: "Description", labelText: "Description"),
              ),
            ]
          ),
        ),
      ),
      actions: <Widget>[
        IconButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              UpdateMultiPitchRoute route = UpdateMultiPitchRoute(
                id: widget.route.id,
                comment: controllerComment.text,
                location: controllerLocation.text,
                name: controllerName.text,
                rating: currentSliderValue.toInt(),
              );
              MultiPitchRoute? updatedRoute = await multiPitchRouteService.editMultiPitchRoute(route);
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