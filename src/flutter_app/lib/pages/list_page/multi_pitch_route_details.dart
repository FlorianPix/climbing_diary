import 'package:climbing_diary/components/my_text_styles.dart';
import 'package:climbing_diary/components/rating.dart';
import 'package:climbing_diary/interfaces/multi_pitch_route/update_multi_pitch_route.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../components/add/add_image.dart';
import '../../components/comment.dart';
import '../../components/image_list_view_add.dart';
import '../../components/info/multi_pitch_route_info.dart';
import '../../components/my_button_styles.dart';
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

  Future<List<String>> fetchURLs() {
    List<Future<String>> futures = [];
    for (var mediaId in widget.route.mediaIds) {
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
        MultiPitchRoute multiPitchRoute = widget.route;
        multiPitchRoute.mediaIds.add(mediaId);
        multiPitchRouteService.editMultiPitchRoute(multiPitchRoute.toUpdateMultiPitchRoute());
      }
    } else {
      List<XFile> images = await picker.pickMultiImage();
      for (XFile img in images){
        var mediaId = await mediaService.uploadMedia(img);
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
        style: MyButtonStyles.rounded
      ));
    }
    return Column(children: elements);
  }
}