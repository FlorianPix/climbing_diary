import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../interfaces/trip/create_trip.dart';
import '../../interfaces/trip/trip.dart';
import '../../services/trip_service.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class AddTrip extends StatefulWidget {
  const AddTrip({super.key, required this.onAdd});
  final ValueSetter<Trip> onAdd;

  @override
  State<StatefulWidget> createState() => _AddTripState();
}

class _AddTripState extends State<AddTrip>{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TripService tripService = TripService();
  final TextEditingController controllerComment = TextEditingController();
  final TextEditingController controllerEndDate = TextEditingController();
  final TextEditingController controllerName = TextEditingController();
  final TextEditingController controllerRating = TextEditingController();
  final TextEditingController controllerStartDate = TextEditingController();
  final TextEditingController controllerDateRange = TextEditingController();

  double currentSliderValue = 0;

  @override
  void initState(){
    controllerEndDate.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    controllerStartDate.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    controllerDateRange.text = "${controllerStartDate.text} ${controllerEndDate.text}";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Add a new trip'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                validator: (value) => value!.isNotEmpty ? null : "please add a name",
                controller: controllerName,
                decoration: const InputDecoration(hintText: "name of the trip", labelText: "name"),
              ),
              TextFormField(
                controller: controllerDateRange,
                decoration: const InputDecoration(
                  icon: Icon(Icons.calendar_today),
                  labelText: "enter date range"
                ),
                readOnly: true,
                onTap: () async {
                  DateTimeRange? pickedDateRange = await showDateRangePicker(
                    context: context, initialDateRange: DateTimeRange(start: DateTime.now(), end: DateTime.now()),
                    firstDate: DateTime(DateTime.now().year - 100),
                    lastDate: DateTime(DateTime.now().year + 100)
                  );
                  if(pickedDateRange != null ){
                    String formattedStartDate = DateFormat('yyyy-MM-dd').format(pickedDateRange.start);
                    String formattedEndDate = DateFormat('yyyy-MM-dd').format(pickedDateRange.end);
                    setState(() {
                      controllerStartDate.text = formattedStartDate;
                      controllerEndDate.text = formattedEndDate;//set output date to TextField value.
                      controllerDateRange.text = "$formattedStartDate $formattedEndDate";
                    });
                  }
                },
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
              TextFormField(
                controller: controllerComment,
                decoration: const InputDecoration(hintText: "comment", labelText: "comment"),
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
              CreateTrip trip = CreateTrip(
                name: controllerName.text,
                endDate: controllerEndDate.text,
                rating: currentSliderValue.toInt(),
                comment: controllerComment.text,
                startDate: controllerStartDate.text,
              );
              Trip? createdTrip = await tripService.createTrip(trip, result);
              if (createdTrip != null) widget.onAdd.call(createdTrip);
              setState(() => Navigator.popUntil(context, ModalRoute.withName('/')));
            }
          },
          child: const Text("Save"))
      ],
    );
  }
}