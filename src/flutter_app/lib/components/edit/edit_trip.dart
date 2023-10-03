import 'package:climbing_diary/components/common/my_validators.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';

import '../../interfaces/trip/trip.dart';
import '../../interfaces/trip/update_trip.dart';
import '../../services/trip_service.dart';

class EditTrip extends StatefulWidget {
  const EditTrip({super.key, required this.trip, required this.onUpdate, required this.onNetworkChange});

  final Trip trip;
  final ValueSetter<Trip> onUpdate;
  final ValueSetter<bool> onNetworkChange;

  @override
  State<StatefulWidget> createState() => _EditTripState();
}

class _EditTripState extends State<EditTrip>{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TripService tripService = TripService();
  final TextEditingController controllerComment = TextEditingController();
  final TextEditingController controllerEndDate = TextEditingController();
  final TextEditingController controllerName = TextEditingController();
  final TextEditingController controllerStartDate = TextEditingController();
  final TextEditingController controllerDateRange = TextEditingController();
  int currentSliderValue = 0;
  bool online = false;

  void checkConnection() async {
    await InternetConnectionChecker().hasConnection.then((value) {
      widget.onNetworkChange.call(value);
      setState(() => online = value);
    });
  }

  @override
  void initState(){
    super.initState();
    controllerComment.text = widget.trip.comment;
    controllerEndDate.text = widget.trip.endDate;
    controllerName.text = widget.trip.name;
    controllerStartDate.text = widget.trip.startDate;
    controllerDateRange.text = "${widget.trip.startDate} ${widget.trip.endDate}";
    currentSliderValue = widget.trip.rating;
    checkConnection();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Edit this trip'),
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
                decoration: const InputDecoration(hintText: "comment", labelText: "comment"),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        IconButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              UpdateTrip trip = UpdateTrip(
                id: widget.trip.id,
                comment: controllerComment.text,
                endDate: controllerEndDate.text,
                name: controllerName.text,
                rating: currentSliderValue.toInt(),
                startDate: controllerStartDate.text
              );
              Trip? updatedTrip = await tripService.editTrip(trip, false);
              if (updatedTrip != null) widget.onUpdate.call(updatedTrip);
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