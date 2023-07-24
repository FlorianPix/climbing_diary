import 'package:climbing_diary/components/my_text_styles.dart';
import 'package:flutter/material.dart';

import '../interfaces/spot/spot.dart';
import '../interfaces/trip/trip.dart';
import '../services/spot_service.dart';

import '../services/trip_service.dart';
import 'my_button_styles.dart';

class SelectSpot extends StatefulWidget {
  const SelectSpot({super.key, required this.trip, required this.onAdd});

  final Trip trip;
  final ValueSetter<Spot> onAdd;

  @override
  State<StatefulWidget> createState() => _SelectSpotState();
}

class _SelectSpotState extends State<SelectSpot>{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController controllerSearch = TextEditingController();
  final SpotService spotService = SpotService();
  final TripService tripService = TripService();

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget search = Form(
      key: _formKey,
      child:
      Padding(
        padding: const EdgeInsets.all(20),
        child: TextFormField(
            controller: controllerSearch,
            decoration: const InputDecoration(
                icon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  borderSide: BorderSide(color: Colors.blue),
                ),
                hintText: "name",
                labelText: "name"
            ),
            onChanged: (String s) {
              setState(() {});
            }
        ),
      ),
    );

    Widget spotList = FutureBuilder<List<Spot>>(
        future: spotService.getSpotsByName(controllerSearch.text),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Spot> spots = snapshot.data!;
            List<Widget> elements = [];
            for(Spot spot in spots){
              List<String> location = spot.location.split(",");
              elements.add(Padding(padding: const EdgeInsets.all(2), child: TextButton(
                  onPressed: () async {
                    if (!widget.trip.spotIds.contains(spot.id)){
                      widget.trip.spotIds.add(spot.id);
                      Trip? updatedTrip = await tripService.editTrip(widget.trip.toUpdateTrip());
                      widget.onAdd.call(spot);
                    }
                    setState(() => Navigator.popUntil(context, ModalRoute.withName('/')));
                  },
                  style: MyButtonStyles.rounded,
                  child: Column(children: [
                    Text(spot.name, style: MyTextStyles.title,),
                    Text(spot.location, style: MyTextStyles.description),
                  ],))
              ));
            }
            return Expanded(child: ListView(children: elements));
          } else {
            return const CircularProgressIndicator();
          }
        }
    );

    return AlertDialog(
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: const Text('Please choose a spot'),
      content: SizedBox(
          width: 500,
          height: 600,
          child: Column(
          children: [
            search,
            spotList
          ]
      ))
    );
  }
}