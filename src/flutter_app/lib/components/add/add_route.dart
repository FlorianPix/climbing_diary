import 'package:flutter/material.dart';

import '../../interfaces/route/create_route.dart';
import '../../interfaces/route/route.dart';
import '../../interfaces/spot/spot.dart';
import '../../services/route_service.dart';
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

  double currentSliderValue = 0;
  Spot? dropdownValue;

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
                CreateClimbingRoute route = CreateClimbingRoute(
                  name: controllerName.text,
                  location: controllerLocation.text,
                  rating: currentSliderValue.toInt(),
                  comment: controllerComment.text,
                );
                Navigator.popUntil(context, ModalRoute.withName('/'));
                final dropdownValue = this.dropdownValue;
                if (dropdownValue != null){
                  ClimbingRoute? createdRoute = await routeService.createRoute(route, dropdownValue.id, result);
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