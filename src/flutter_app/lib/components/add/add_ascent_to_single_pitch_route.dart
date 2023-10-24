import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:climbing_diary/interfaces/ascent/ascent_style.dart';
import 'package:climbing_diary/interfaces/single_pitch_route/single_pitch_route.dart';
import 'package:climbing_diary/interfaces/ascent/ascent_type.dart';
import 'package:climbing_diary/interfaces/ascent/ascent.dart';
import 'package:climbing_diary/services/ascent_service.dart';
import 'package:uuid/uuid.dart';

class AddAscentToSinglePitchRoute extends StatefulWidget {
  const AddAscentToSinglePitchRoute({super.key, required this.singlePitchRoutes, this.onAdd});

  final ValueSetter<Ascent>? onAdd;
  final List<SinglePitchRoute> singlePitchRoutes;

  @override
  State<StatefulWidget> createState() => _AddAscentToSinglePitchRouteState();
}

class _AddAscentToSinglePitchRouteState extends State<AddAscentToSinglePitchRoute>{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AscentService ascentService = AscentService();
  final TextEditingController controllerPitchId = TextEditingController();
  final TextEditingController controllerComment = TextEditingController();
  final TextEditingController controllerDate = TextEditingController();

  SinglePitchRoute? singlePitchRouteValue;
  AscentStyle ascentStyleValue = AscentStyle.lead;
  AscentType ascentTypeValue = AscentType.redPoint;

  @override
  void initState(){
    singlePitchRouteValue = widget.singlePitchRoutes[0];
    controllerDate.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Add a new ascent'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<SinglePitchRoute>(
                value: singlePitchRouteValue,
                items: widget.singlePitchRoutes.map<DropdownMenuItem<SinglePitchRoute>>((SinglePitchRoute singlePitchRoute) {
                  return DropdownMenuItem<SinglePitchRoute>(
                    value: singlePitchRoute,
                    child: Text(singlePitchRoute.name),
                  );
                }).toList(),
                onChanged: (SinglePitchRoute? singlePitchRoute) => setState(() => singlePitchRouteValue = singlePitchRoute!)
              ),
              TextFormField(
                controller: controllerComment,
                decoration: const InputDecoration(hintText: "comment", labelText: "comment"),
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
                    setState(() => controllerDate.text = formattedDate);
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
                onChanged: (AscentStyle? ascentStyle) => setState(() => ascentStyleValue = ascentStyle!)
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
                onChanged: (AscentType? ascentType) => setState(() => ascentTypeValue = ascentType!)
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              Ascent ascent = Ascent(
                comment: controllerComment.text,
                date: controllerDate.text,
                style: ascentStyleValue.index,
                type: ascentTypeValue.index,
                updated: DateTime.now().toIso8601String(),
                mediaIds: [],
                id: const Uuid().v4(),
                userId: '',
              );
              final singlePitchRouteValue = this.singlePitchRouteValue;
              if (singlePitchRouteValue != null) {
                Ascent? createdAscent = await ascentService.createAscentForSinglePitchRoute(ascent, singlePitchRouteValue.id);
                widget.onAdd?.call(createdAscent!);
              }
              setState(() => Navigator.popUntil(context, ModalRoute.withName('/')));
            }
          },
          child: const Text("Save"))
      ],
    );
  }
}