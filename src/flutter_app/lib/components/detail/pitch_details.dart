import 'package:climbing_diary/interfaces/route/route.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../interfaces/pitch/pitch.dart';
import '../../interfaces/pitch/update_pitch.dart';
import '../../interfaces/spot/spot.dart';
import '../../interfaces/trip/trip.dart';
import '../../components/image_list_view.dart';
import '../../pages/diary_page/timeline/ascent_timeline.dart';
import '../../services/media_service.dart';
import '../../services/pitch_service.dart';
import '../add/add_image.dart';
import '../my_button_styles.dart';
import '../add/add_ascent.dart';
import '../edit/edit_pitch.dart';
import '../info/pitch_info.dart';
import '../rating.dart';

class PitchDetails extends StatefulWidget {
  const PitchDetails({super.key, this.trip, required this.spot, required this.route, required this.pitch, required this.onDelete, required this.onUpdate });

  final Trip? trip;
  final Spot spot;
  final ClimbingRoute route;
  final Pitch pitch;
  final ValueSetter<Pitch> onDelete;
  final ValueSetter<Pitch> onUpdate;

  @override
  State<StatefulWidget> createState() => _PitchDetailsState();
}

class _PitchDetailsState extends State<PitchDetails>{
  final MediaService mediaService = MediaService();
  final PitchService pitchService = PitchService();

  Future<List<String>> fetchURLs() {
    List<Future<String>> futures = [];
    for (var mediaId in widget.pitch.mediaIds) {
      futures.add(mediaService.getMediumUrl(mediaId));
    }
    return Future.wait(futures);
  }

  final ImagePicker picker = ImagePicker();

  Future<void> getImage(ImageSource media) async {
    if (media == ImageSource.camera) {
      var img = await picker.pickImage(source: media);
      if (img != null) {
        var mediaId = await mediaService.uploadMedia(img);
        Pitch pitch = widget.pitch;
        pitch.mediaIds.add(mediaId);
        pitchService.editPitch(pitch.toUpdatePitch());
      }
    } else {
      List<XFile> images = await picker.pickMultiImage();
      for (XFile img in images){
        var mediaId = await mediaService.uploadMedia(img);
        Pitch pitch = widget.pitch;
        pitch.mediaIds.add(mediaId);
        pitchService.editPitch(pitch.toUpdatePitch());
      }
    }
    setState(() {});
  }

  void addImageDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AddImage(onAddImage: getImage);
        }
    );
  }

  void editPitchDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditPitch(pitch: widget.pitch, onUpdate: widget.onUpdate);
      });
  }

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Pitch pitch = widget.pitch;
    List<Widget> elements = [];

    // general info
    elements.add(PitchInfo(pitch: pitch));

    elements.add(Rating(rating: pitch.rating));

    if (pitch.comment.isNotEmpty) {
      elements.add(Container(
          margin: const EdgeInsets.all(15.0),
          padding: const EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blueAccent),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            pitch.comment,
          )
      ));
    }

    void deleteImageCallback(String mediumId) {
      widget.spot.mediaIds.remove(mediumId);
      pitchService.editPitch(UpdatePitch(
          id: widget.pitch.id,
          mediaIds: widget.pitch.mediaIds
      ));
      setState(() {});
    }

    if (pitch.mediaIds.isNotEmpty) {
      elements.add(ImageListView(
        onDelete: deleteImageCallback,
        mediaIds: pitch.mediaIds,
        getImage: getImage,
      ));
    } else {
      elements.add(
        ElevatedButton.icon(
            icon: const Icon(Icons.add, size: 30.0, color: Colors.pink),
            label: const Text('Add image'),
            onPressed: () => addImageDialog(),
            style: MyButtonStyles.rounded
        ),
      );
    }
    // add ascent
    elements.add(
      ElevatedButton.icon(
          icon: const Icon(Icons.add, size: 30.0, color: Colors.pink),
          label: const Text('Add new ascent'),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddAscent(
                    pitch: widget.pitch,
                    onAdd: (ascent) {
                      widget.pitch.ascentIds.add(ascent.id);
                      setState(() {});
                    },
                  ),
                )
            );
          },
          style: MyButtonStyles.rounded
      ),
    );
    // delete, edit, close
    elements.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // delete pitch button
            IconButton(
              onPressed: () {
                Navigator.pop(context);
                pitchService.deletePitch(widget.route.id, pitch);
                widget.onDelete.call(pitch);
              },
              icon: const Icon(Icons.delete),
            ),
            IconButton(
              onPressed: () => editPitchDialog(),
              icon: const Icon(Icons.edit),
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
            ),
          ],
        )
    );
    // ascents
    if (pitch.ascentIds.isNotEmpty){
      DateTime startDate = DateTime(1923);
      DateTime endDate = DateTime(2123);
      if (widget.trip != null) {
        DateTime.parse(widget.trip!.startDate);
        DateTime.parse(widget.trip!.endDate);
      }
      elements.add(
          AscentTimeline(
              trip: widget.trip,
              spot: widget.spot,
              route: widget.route,
              pitchId: pitch.id,
              ascentIds: pitch.ascentIds,
              onUpdate: (ascent) {
                // TODO
              },
              onDelete: (ascent) {
                pitch.ascentIds.remove(ascent.id);
                setState(() {});
              },
              startDate: startDate,
              endDate: endDate,
              ofMultiPitch: true,
          )
      );
    }

    return Stack(
        children: <Widget>[
          Container(
              padding: const EdgeInsets.all(20),
              child: ListView(
                  children: elements
              )
          )
        ]
    );
  }
}