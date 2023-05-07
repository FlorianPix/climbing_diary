import 'package:flutter/material.dart';

import '../../interfaces/ascent/ascent.dart';
import '../../interfaces/ascent/update_ascent.dart';
import '../../services/ascent_service.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

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
  final TextEditingController controllerStyle = TextEditingController();
  final TextEditingController controllerType = TextEditingController();

  @override
  void initState(){
    controllerComment.text = widget.ascent.comment;
    controllerDate.text = widget.ascent.date;
    controllerStyle.text = widget.ascent.style as String;
    controllerType.text = widget.ascent.type as String;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text('Edit this ascent'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: controllerComment,
                decoration: const InputDecoration(
                    hintText: "comment", labelText: "comment"),
              ),
            ]
          ),
        ),
      ),
      actions: <Widget>[
        IconButton(
          onPressed: () async {
            bool result = await InternetConnectionChecker().hasConnection;
            if (_formKey.currentState!.validate()) {
              UpdateAscent ascent = UpdateAscent(
                id: widget.ascent.id,
                comment: controllerComment.text,
                date: controllerDate.text,
                style: int.parse(controllerStyle.text),
                type: int.parse(controllerType.text)
              );
              Navigator.popUntil(context, ModalRoute.withName('/'));
              Ascent? updatedAscent = await ascentService.editAscent(ascent);
              if (updatedAscent != null) {
                widget.onUpdate.call(updatedAscent);
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