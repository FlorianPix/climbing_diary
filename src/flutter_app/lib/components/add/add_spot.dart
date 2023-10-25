import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:climbing_diary/components/common/my_text_styles.dart';
import 'package:climbing_diary/interfaces/trip/update_trip.dart';
import 'package:climbing_diary/pages/map_page/location_picker.dart';
import 'package:climbing_diary/interfaces/spot/spot.dart';
import 'package:climbing_diary/interfaces/trip/trip.dart';
import 'package:climbing_diary/services/spot_service.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:climbing_diary/services/trip_service.dart';

class AddSpot extends StatefulWidget {
  const AddSpot({super.key, this.trip, required this.onAdd, required this.onNetworkChange});

  final ValueSetter<Spot> onAdd;
  final Trip? trip;
  final ValueSetter<bool> onNetworkChange;

  @override
  State<StatefulWidget> createState() => _AddSpotState();
}

class _AddSpotState extends State<AddSpot>{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final SpotService spotService = SpotService();
  final TripService tripService = TripService();
  final TextEditingController controllerTitle = TextEditingController();
  final TextEditingController controllerDate = TextEditingController();
  final TextEditingController controllerAddress = TextEditingController();
  final TextEditingController controllerLat = TextEditingController();
  final TextEditingController controllerLong = TextEditingController();
  final TextEditingController controllerComment = TextEditingController();
  final TextEditingController controllerBus = TextEditingController();
  final TextEditingController controllerCar = TextEditingController();

  double currentSliderValue = 0;

  String? numericValidator (String? value){
    if (value != null && value != ""){
      var i = int.tryParse(value);
      if (i == null) return "Must be a number";
    }
    return null;
  }

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
    controllerDate.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    checkConnection();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> elements = [];
    if (widget.trip != null) elements.add(Text(widget.trip!.name, style: MyTextStyles.title));
    elements.add(TextFormField(
      validator: (value) => value!.isNotEmpty ? null : "Please add a name",
      controller: controllerTitle,
      decoration: const InputDecoration(hintText: "name", labelText: "name"),
    ));
    elements.add(TextButton.icon(
      icon: const Icon(Icons.place, size: 30.0),
      onPressed: () => Navigator.push(context,
        MaterialPageRoute(
          builder: (context) => LocationPicker(
            onAdd: (List<String> results) {
              controllerAddress.text = results[0];
              controllerLat.text = results[1];
              controllerLong.text = results[2];
              setState(() {});
            }
          ),
        )
      ),
      label: const Text("select location"),
    ));
    elements.add(TextFormField(
      validator: (value) => value!.isNotEmpty ? null : "Please add an address",
      controller: controllerAddress,
      decoration: const InputDecoration(labelText: "address"),
    ));
    elements.add(TextFormField(
      validator: (value) => value!.isNotEmpty ? null : "Please add a latitude value",
      controller: controllerLat,
      decoration: const InputDecoration(labelText: "latitude"),
    ));
    elements.add(TextFormField(
      validator: (value) => value!.isNotEmpty ? null : "Please add a longitude value",
      controller: controllerLong,
      decoration: const InputDecoration(labelText: "longitude"),
    ));
    elements.add(Align(
      alignment: Alignment.centerLeft,
      child: Padding(padding: const EdgeInsets.only(top: 8.0),
        child: Text(
          "rating",
          style: TextStyle(
            color: Colors.black.withOpacity(0.6),
            fontSize: 16
          )
        ),
      ),
    ));
    elements.add(Slider(
      value: currentSliderValue,
      max: 5,
      divisions: 5,
      label: currentSliderValue.round().toString(),
      onChanged: (value) => setState(() => currentSliderValue = value),
    ));
    elements.add(TextFormField(
      controller: controllerComment,
      decoration: const InputDecoration(hintText: "comment", labelText: "comment"),
    ));
    elements.add(TextFormField(
      validator: (value) => numericValidator(value),
      keyboardType: TextInputType.number,
      controller: controllerBus,
      decoration: const InputDecoration(hintText: "in minutes", labelText: "distance to public transport"
      ),
    ));
    elements.add(TextFormField(
      validator: (value) => numericValidator(value),
      controller: controllerCar,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(hintText: "in minutes", labelText: "distance to parking"),
    ));
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20),),
      title: const Text('Add a new spot'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: elements,
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              var valDistanceParking = int.tryParse(controllerCar.text);
              var valDistancePublicTransport = int.tryParse(controllerBus.text);
              Spot spot = Spot(
                comment: controllerComment.text,
                coordinates: [double.parse(controllerLat.text), double.parse(controllerLong.text)],
                distanceParking: (valDistanceParking != null) ? valDistanceParking : 0,
                distancePublicTransport: (valDistancePublicTransport != null) ? valDistancePublicTransport : 0,
                location: controllerAddress.text,
                name: controllerTitle.text,
                rating: currentSliderValue.toInt(),
                updated: DateTime.now().toIso8601String(),
                mediaIds: [],
                singlePitchRouteIds: [],
                multiPitchRouteIds: [],
                id: const Uuid().v4(),
                userId: '',
              );
              Spot? createdSpot = await spotService.createSpot(spot);
              if (createdSpot != null) {
                if (widget.trip != null) {
                  Trip trip = widget.trip!;
                  UpdateTrip editTrip = trip.toUpdateTrip();
                  editTrip.spotIds?.add(createdSpot.id);
                  await tripService.editTrip(editTrip);
                }
                widget.onAdd.call(createdSpot);
              }
              setState(() => Navigator.popUntil(context, ModalRoute.withName('/')));
            }
          },
          child: const Icon(Icons.save))
      ],
    );
  }
}