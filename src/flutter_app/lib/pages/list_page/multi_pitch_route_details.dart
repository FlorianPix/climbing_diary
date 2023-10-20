import 'package:climbing_diary/components/common/my_text_styles.dart';
import 'package:climbing_diary/components/common/rating.dart';
import 'package:climbing_diary/interfaces/multi_pitch_route/update_multi_pitch_route.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../components/add/add_image.dart';
import '../../components/common/comment.dart';
import '../../components/common/image_list_view_add.dart';
import '../../components/info/multi_pitch_route_info.dart';
import 'package:climbing_diary/components/common/my_button_styles.dart';
import '../../interfaces/media/media.dart';
import '../../interfaces/multi_pitch_route/multi_pitch_route.dart';
import '../../services/media_service.dart';
import '../../services/multi_pitch_route_service.dart';
import '../../services/pitch_service.dart';

class MultiPitchRouteDetails extends StatefulWidget {
  const MultiPitchRouteDetails({super.key, required this.route, required this.onNetworkChange});

  final MultiPitchRoute route;
  final ValueSetter<bool> onNetworkChange;

  @override
  State<StatefulWidget> createState() => _MultiPitchRouteDetailsState();
}

class _MultiPitchRouteDetailsState extends State<MultiPitchRouteDetails>{
  final MediaService mediaService = MediaService();
  final MultiPitchRouteService multiPitchRouteService = MultiPitchRouteService();
  final PitchService pitchService = PitchService();

  Future<List<Media>> fetchMedia() {
    List<Future<Media>> futures = [];
    for (var mediaId in widget.route.mediaIds) {
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
        MultiPitchRoute multiPitchRoute = widget.route;
        multiPitchRoute.mediaIds.add(mediaId);
        multiPitchRouteService.editMultiPitchRoute(multiPitchRoute.toUpdateMultiPitchRoute());
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
        MultiPitchRoute multiPitchRoute = widget.route;
        multiPitchRoute.mediaIds.add(mediaId);
        multiPitchRouteService.editMultiPitchRoute(multiPitchRoute.toUpdateMultiPitchRoute());
      }
    }
    setState(() {});
  }

  void addImageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AddImage(onAddImage: getImage)
    );
  }

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> elements = [];
    MultiPitchRoute route = widget.route;

    elements.addAll([
      Text(route.name, style: MyTextStyles.title),
      MultiPitchInfo(
        pitchIds: route.pitchIds,
        onNetworkChange: widget.onNetworkChange,
      ),
      Text(route.location, style: MyTextStyles.description),
      Rating(rating: route.rating)
    ]);
    if (route.comment.isNotEmpty) Comment(comment: route.comment);

    void deleteImageCallback(String mediumId) {
      widget.route.mediaIds.remove(mediumId);
      multiPitchRouteService.editMultiPitchRoute(UpdateMultiPitchRoute(
        id: widget.route.id,
        mediaIds: widget.route.mediaIds
      ));
      setState(() {});
    }

    if (route.mediaIds.isNotEmpty) {
      elements.add(ImageListViewAdd(
        onDelete: deleteImageCallback,
        mediaIds: route.mediaIds,
        getImage: getImage
      ));
    } else {
      elements.add(ElevatedButton.icon(
        icon: const Icon(Icons.add, size: 30.0, color: Colors.pink),
        label: const Text('Add image'),
        onPressed: () => addImageDialog(),
        style: ButtonStyle(shape: MyButtonStyles.rounded)
      ));
    }
    return Column(children: elements);
  }
}