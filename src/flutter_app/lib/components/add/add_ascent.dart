import 'package:climbing_diary/interfaces/ascent/ascent_style.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../interfaces/ascent/ascent_type.dart';
import '../../interfaces/ascent/create_ascent.dart';
import '../../interfaces/ascent/ascent.dart';
import '../../interfaces/pitch/pitch.dart';
import '../../services/ascent_service.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class AddAscent extends StatefulWidget {
  const AddAscent({super.key, required this.pitches, this.onAdd});

  final ValueSetter<Ascent>? onAdd;
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

  Pitch? pitchValue;
  AscentStyle? ascentStyleValue;
  AscentType? ascentTypeValue;

  @override
  void initState(){
    pitchValue = widget.pitches[0];
    ascentStyleValue = AscentStyle.lead;
    ascentTypeValue = AscentType.redPoint;
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
                  value: pitchValue,
                  items: widget.pitches.map<DropdownMenuItem<Pitch>>((Pitch pitch) {
                    return DropdownMenuItem<Pitch>(
                      value: pitch,
                      child: Text(pitch.name),
                    );
                  }).toList(),
                  onChanged: (Pitch? pitch) {
                    setState(() {
                      pitchValue = pitch!;
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
              // ascentStyle
              DropdownButton<AscentStyle>(
                  value: ascentStyleValue,
                  items: AscentStyle.values.map<DropdownMenuItem<AscentStyle>>((AscentStyle ascentStyle) {
                    return DropdownMenuItem<AscentStyle>(
                      value: ascentStyle,
                      child: Text("${ascentStyle.toEmoji()} ${ascentStyle.name}"),
                    );
                  }).toList(),
                  onChanged: (AscentStyle? ascentStyle) {
                    setState(() {
                      ascentStyleValue = ascentStyle!;
                    });
                  }
              ),
              // ascentType
              DropdownButton<AscentType>(
                  value: ascentTypeValue,
                  items: AscentType.values.map<DropdownMenuItem<AscentType>>((AscentType ascentType) {
                    return DropdownMenuItem<AscentType>(
                      value: ascentType,
                      child: Text("${ascentType.toEmoji()} ${ascentType.name}"),
                    );
                  }).toList(),
                  onChanged: (AscentType? ascentType) {
                    setState(() {
                      ascentTypeValue = ascentType!;
                    });
                  }
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
                final int? ascentStyleIndex = ascentStyleValue?.index;
                final int? ascentTypeIndex = ascentTypeValue?.index;
                if (ascentStyleIndex != null && ascentTypeIndex != null) {
                  CreateAscent ascent = CreateAscent(
                    comment: controllerComment.text,
                    date: controllerDate.text,
                    style: ascentStyleIndex,
                    type: ascentTypeIndex,
                  );
                  Navigator.popUntil(context, ModalRoute.withName('/'));
                  final pitchValue = this.pitchValue;
                  if (pitchValue != null) {
                    Ascent? createdAscent = await ascentService.createAscent(pitchValue.id, ascent, result);
                    widget.onAdd?.call(createdAscent!);
                  }
                }
              }
            },
            child: const Text("Save"))
      ],
    );
  }
}