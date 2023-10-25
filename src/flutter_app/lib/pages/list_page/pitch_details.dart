import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:climbing_diary/components/add/add_image.dart';
import 'package:climbing_diary/components/common/comment.dart';
import 'package:climbing_diary/components/common/image_list_view_add.dart';
import 'package:climbing_diary/components/info/pitch_info.dart';
import 'package:climbing_diary/components/common/my_button_styles.dart';
import 'package:climbing_diary/components/common/rating.dart';
import 'package:uuid/uuid.dart';
import '../../interfaces/media/media.dart';
import '../../interfaces/pitch/pitch.dart';
import '../../interfaces/pitch/update_pitch.dart';
import '../../services/media_service.dart';
import '../../services/pitch_service.dart';

class PitchDetails extends StatefulWidget {
  const PitchDetails({super.key, required this.pitch, required this.onNetworkChange});

  final Pitch pitch;
  final ValueSetter<bool> onNetworkChange;

  @override
  State<StatefulWidget> createState() => _PitchDetailsState();
}

class _PitchDetailsState extends State<PitchDetails>{
  final MediaService mediaService = MediaService();
  final PitchService pitchService = PitchService();

  Future<List<Media>> fetchMedia() {
    List<Future<Media>> futures = [];
    for (var mediaId in widget.pitch.mediaIds) {
      futures.add(mediaService.getMedium(mediaId));
    }
    return Future.wait(futures);
  }

  final ImagePicker picker = ImagePicker();

  Future<void> getImage(ImageSource media) async {
    if (media == ImageSource.camera) {
      XFile? file = await picker.pickImage(source: media);
      if (file != null) {
        Media medium = Media(
          id: const Uuid().v4(),
          userId: '',
          title: file.name,
          createdAt: DateTime.now().toIso8601String(),
          image: await file.readAsBytes(),
        );
        var mediaId = await mediaService.createMedium(medium);
        Pitch pitch = widget.pitch;
        pitch.mediaIds.add(mediaId);
        await pitchService.editPitch(pitch.toUpdatePitch());
      }
    } else {
      List<XFile> files = await picker.pickMultiImage();
      for (XFile file in files){
        Media medium = Media(
          id: const Uuid().v4(),
          userId: '',
          title: file.name,
          createdAt: DateTime.now().toIso8601String(),
          image: await file.readAsBytes(),
        );
        var mediaId = await mediaService.createMedium(medium);
        Pitch pitch = widget.pitch;
        pitch.mediaIds.add(mediaId);
        await pitchService.editPitch(pitch.toUpdatePitch());
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

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Pitch pitch = widget.pitch;
    List<Widget> elements = [];

    elements.add(PitchInfo(pitch: pitch, onNetworkChange: widget.onNetworkChange));
    elements.add(Rating(rating: pitch.rating));

    if (pitch.comment.isNotEmpty) elements.add(Comment(comment: pitch.comment));

    void deleteImageCallback(String mediumId) async {
      widget.pitch.mediaIds.remove(mediumId);
      await pitchService.editPitch(UpdatePitch(
        id: widget.pitch.id,
        mediaIds: widget.pitch.mediaIds
      ));
      setState(() {});
    }

    if (pitch.mediaIds.isNotEmpty) {
      elements.add(ImageListViewAdd(
        onDelete: deleteImageCallback,
        mediaIds: pitch.mediaIds,
        getImage: getImage,
      ));
    } else {
      elements.add(ElevatedButton.icon(
        icon: const Icon(Icons.add, size: 30.0, color: Colors.pink),
        label: const Text('Add image'),
        onPressed: () => addImageDialog(),
        style: ButtonStyle(shape: MyButtonStyles.rounded)
      ));
    }

    return Column(
        children: elements
    );
  }
}