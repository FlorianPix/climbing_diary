import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:climbing_diary/components/info/ascent_info.dart';
import 'package:climbing_diary/interfaces/ascent/ascent.dart';
import 'package:climbing_diary/interfaces/ascent/update_ascent.dart';
import 'package:climbing_diary/services/media_service.dart';
import 'package:climbing_diary/services/ascent_service.dart';
import 'package:climbing_diary/components/add/add_image.dart';
import 'package:climbing_diary/components/common/comment.dart';
import 'package:climbing_diary/components/common/image_list_view_add.dart';
import 'package:climbing_diary/components/common/my_button_styles.dart';
import 'package:climbing_diary/components/edit/edit_ascent.dart';

class AscentDetails extends StatefulWidget {
  const AscentDetails({super.key, required this.pitchId, required this.ascent, required this.onDelete, required this.onUpdate, required this.ofMultiPitch });

  final String pitchId;
  final Ascent ascent;
  final ValueSetter<Ascent> onDelete, onUpdate;
  final bool ofMultiPitch;

  @override
  State<StatefulWidget> createState() => _AscentDetailsState();
}

class _AscentDetailsState extends State<AscentDetails>{
  final MediaService mediaService = MediaService();
  final AscentService ascentService = AscentService();
  final ImagePicker picker = ImagePicker();

  Future<void> getImage(ImageSource media) async {
    if (media == ImageSource.camera) {
      var img = await picker.pickImage(source: media);
      if (img != null) {
        var mediaId = await mediaService.uploadMedium(img);
        Ascent ascent = widget.ascent;
        ascent.mediaIds.add(mediaId);
        await ascentService.editAscent(ascent.toUpdateAscent());
      }
    } else {
      List<XFile> images = await picker.pickMultiImage();
      for (XFile img in images){
        var mediaId = await mediaService.uploadMedium(img);
        Ascent ascent = widget.ascent;
        ascent.mediaIds.add(mediaId);
        await ascentService.editAscent(ascent.toUpdateAscent());
      }
    }
    setState(() {});
  }

  void editAscentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditAscent(ascent: widget.ascent, onUpdate: widget.onUpdate);
      });
  }

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Ascent ascent = widget.ascent;
    List<Widget> elements = [];
    elements.add(AscentInfo(ascent: ascent));
    if (ascent.comment.isNotEmpty) elements.add(Comment(comment: ascent.comment));

    void deleteImageCallback(String mediumId) {
      widget.ascent.mediaIds.remove(mediumId);
      ascentService.editAscent(UpdateAscent(
        id: widget.ascent.id,
        mediaIds: widget.ascent.mediaIds
      ));
      setState(() {});
    }

    if (ascent.mediaIds.isNotEmpty) {
      elements.add(ImageListViewAdd(
        onDelete: deleteImageCallback,
        mediaIds: widget.ascent.mediaIds,
        getImage: getImage,
      ));
    } else {
      elements.add(
        ElevatedButton.icon(
          icon: const Icon(Icons.add, size: 30.0, color: Colors.pink),
          label: const Text('Add image'),
          onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => AddImage(onAddImage: getImage))
          ),
          style: ButtonStyle(shape: MyButtonStyles.rounded)
        ),
      );
    }
    elements.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () async {
            Navigator.pop(context);
            if (widget.ofMultiPitch) {
              await ascentService.deleteAscentOfPitch(widget.pitchId, ascent);
            } else {
              await ascentService.deleteAscentOfSinglePitchRoute(widget.pitchId, ascent);
            }
            widget.onDelete.call(ascent);
          },
          icon: const Icon(Icons.delete),
        ),
        IconButton(
          onPressed: () => editAscentDialog(),
          icon: const Icon(Icons.edit),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ],
    ));

    return Stack(children: [Container(padding: const EdgeInsets.all(20), child: ListView(children: elements))]);
  }
}