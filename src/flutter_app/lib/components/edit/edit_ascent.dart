import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../interfaces/ascent/ascent.dart';
import '../../interfaces/ascent/ascent_style.dart';
import '../../interfaces/ascent/ascent_type.dart';
import '../../interfaces/ascent/update_ascent.dart';
import '../../services/ascent_service.dart';

class EditAscent extends StatefulWidget {
  const EditAscent({super.key, required this.ascent, required this.onUpdate});

  final Ascent ascent;
  final ValueSetter<Ascent> onUpdate;

  @override
  State<StatefulWidget> createState() => _EditAscentState();
}

class _EditAscentState extends State<EditAscent>{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AscentService ascentService = AscentService();
  final TextEditingController controllerComment = TextEditingController();
  final TextEditingController controllerDate = TextEditingController();

  AscentStyle? ascentStyleValue;
  AscentType? ascentTypeValue;

  @override
  void initState(){
    ascentStyleValue = AscentStyle.values[widget.ascent.style];
    ascentTypeValue = AscentType.values[widget.ascent.type];
    controllerComment.text = widget.ascent.comment;
    controllerDate.text = widget.ascent.date;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20),),
      title: const Text('Edit this ascent'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
            ]
          ),
        ),
      ),
      actions: <Widget>[
        IconButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final int? ascentStyleIndex = ascentStyleValue?.index;
              final int? ascentTypeIndex = ascentTypeValue?.index;
              if (ascentStyleIndex != null && ascentTypeIndex != null) {
                UpdateAscent ascent = UpdateAscent(
                  id: widget.ascent.id,
                  comment: controllerComment.text,
                  date: controllerDate.text,
                  style: ascentStyleIndex,
                  type: ascentTypeIndex
                );
                Ascent? updatedAscent = await ascentService.editAscent(ascent);
                if (updatedAscent != null) widget.onUpdate.call(updatedAscent);
                setState(() => Navigator.popUntil(context, ModalRoute.withName('/')));
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