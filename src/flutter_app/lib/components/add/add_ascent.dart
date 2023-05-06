import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../interfaces/ascent/create_ascent.dart';
import '../../interfaces/ascent/ascent.dart';
import '../../interfaces/pitch/pitch.dart';
import '../../services/ascent_service.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../../services/ascent_service.dart';

class AddAscent extends StatefulWidget {
  const AddAscent({super.key, required this.pitches});

  final List<Pitch> pitches;

  @override
  State<StatefulWidget> createState() => _AddAscentState();
}

class _AddAscentState extends State<AddAscent>{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AscentService ascentService = AscentService();
  final TextEditingController controllerPitchId = TextEditingController();
  final TextEditingController controllerComment = TextEditingController();
  final TextEditingController controllerDate = TextEditingController();
  final TextEditingController controllerStyle = TextEditingController();
  final TextEditingController controllerType = TextEditingController();

  Pitch? dropdownValue;

  @override
  void initState(){
    controllerDate.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text('Add a new ascent'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<Pitch>(
                  value: dropdownValue,
                  items: widget.pitches.map<DropdownMenuItem<Pitch>>((Pitch pitch) {
                    return DropdownMenuItem<Pitch>(
                      value: pitch,
                      child: Text(pitch.name),
                    );
                  }).toList(),
                  onChanged: (Pitch? pitch) {
                    setState(() {
                      dropdownValue = pitch!;
                    });
                  }
              ),
              TextFormField(
                controller: controllerComment,
                decoration: const InputDecoration(
                    hintText: "comment", labelText: "comment"),
              ),
              TextFormField(
                controller: controllerDate,
                decoration: const InputDecoration(
                    icon: Icon(Icons.calendar_today),
                    labelText: "Enter Date"
                ),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                      context: context, initialDate: DateTime.now(),
                      firstDate: DateTime(1923),
                      lastDate: DateTime(2123)
                  );
                  if(pickedDate != null ){
                    String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                    setState(() {
                      controllerDate.text = formattedDate; //set output date to TextField value.
                    });
                  }
                },
              ),
              TextFormField(
                controller: controllerStyle,
                decoration: const InputDecoration(
                    hintText: "ascent style", labelText: "ascent style"),
              ),
              TextFormField(
                controller: controllerType,
                decoration: const InputDecoration(
                    hintText: "ascent type", labelText: "ascent type"),
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
                CreateAscent ascent = CreateAscent(
                  comment: controllerComment.text,
                  date: controllerDate.text,
                  style: int.parse(controllerStyle.text),
                  type: int.parse(controllerType.text),
                );
                Navigator.of(context).pop();
                final dropdownValue = this.dropdownValue;
                if (dropdownValue != null) {
                  Ascent? createdAscent = await ascentService.createAscent(dropdownValue.id, ascent, result);
                }
              }
            },
            child: const Text("Save"))
      ],
    );
  }
}