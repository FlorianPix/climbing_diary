import 'package:flutter/material.dart';

import '../../interfaces/ascent/ascent.dart';
import '../../interfaces/pitch/pitch.dart';
import '../../services/ascent_service.dart';
import '../../services/pitch_service.dart';
import '../MyButtonStyles.dart';

class SelectAscent extends StatefulWidget {
  const SelectAscent({super.key, required this.pitch});

  final Pitch pitch;

  @override
  State<StatefulWidget> createState() => _SelectAscentState();
}

class _SelectAscentState extends State<SelectAscent>{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AscentService ascentService = AscentService();
  final PitchService pitchService = PitchService();

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: const Text('Please choose a ascent'),
      content: FutureBuilder<List<Ascent>>(
        future: ascentService.getAscents(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Ascent> ascents = snapshot.data!;
            List<Widget> elements = <Widget>[];

            for (int i = 0; i < ascents.length; i++){
              elements.add(ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_forward, size: 30.0, color: Colors.pink),
                  label: Text(ascents[i].date),
                  onPressed: () {
                    if (!widget.pitch.ascentIds.contains(ascents[i].id)){
                      widget.pitch.ascentIds.add(ascents[i].id);
                      pitchService.editPitch(widget.pitch.toUpdatePitch());
                    }
                    Navigator.of(context).pop();
                  },
                  style: MyButtonStyles.rounded
              ));
            }
            return Column(
              children: elements,
            );
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}