import 'package:climbing_diary/components/info/single_pitch_route_info.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:climbing_diary/components/add/add_image.dart';
import 'package:climbing_diary/components/common/comment.dart';
import 'package:climbing_diary/components/common/image_list_view_add.dart';
import 'package:climbing_diary/components/common/my_button_styles.dart';
import 'package:climbing_diary/components/common/rating.dart';
import '../../interfaces/single_pitch_route/single_pitch_route.dart';
import '../../interfaces/single_pitch_route/update_single_pitch_route.dart';
import '../../services/media_service.dart';
import '../../services/pitch_service.dart';
import '../../services/single_pitch_route_service.dart';

class SinglePitchRouteDetails extends StatefulWidget {
  const SinglePitchRouteDetails({super.key, required this.route, required this.onNetworkChange});

  final SinglePitchRoute route;
  final ValueSetter<bool> onNetworkChange;

  @override
  State<StatefulWidget> createState() => _SinglePitchRouteDetailsState();
}

class _SinglePitchRouteDetailsState extends State<SinglePitchRouteDetails>{
  final MediaService mediaService = MediaService();
  final SinglePitchRouteService singlePitchRouteService = SinglePitchRouteService();
  final PitchService pitchService = PitchService();

  Future<List<String>> fetchURLs() {
    List<Future<String>> futures = [];
    for (var mediaId in widget.route.mediaIds) {
      futures.add(mediaService.getMediumUrl(mediaId));
    }
    return Future.wait(futures);
  }

  XFile? image;
  final ImagePicker picker = ImagePicker();

  Future<void> getImage(ImageSource media) async {
    if (media == ImageSource.camera) {
      var img = await picker.pickImage(source: media);
      if (img != null) {
        var mediaId = await mediaService.uploadMedia(img);
        SinglePitchRoute singlePitchRoute = widget.route;
        singlePitchRoute.mediaIds.add(mediaId);
        singlePitchRouteService.editSinglePitchRoute(singlePitchRoute.toUpdateSinglePitchRoute());
      }
    } else {
      List<XFile> images = await picker.pickMultiImage();
      for (XFile img in images){
        var mediaId = await mediaService.uploadMedia(img);
        SinglePitchRoute singlePitchRoute = widget.route;
        singlePitchRoute.mediaIds.add(mediaId);
        singlePitchRouteService.editSinglePitchRoute(singlePitchRoute.toUpdateSinglePitchRoute());
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
    SinglePitchRoute route = widget.route;

    elements.add(SinglePitchRouteInfo(route: route, onNetworkChange: widget.onNetworkChange));
    elements.add(Rating(rating: route.rating));
    if (route.comment.isNotEmpty) elements.add(Comment(comment: route.comment));

    void deleteImageCallback(String mediumId) {
      widget.route.mediaIds.remove(mediumId);
      singlePitchRouteService.editSinglePitchRoute(UpdateSinglePitchRoute(
        id: widget.route.id,
        mediaIds: widget.route.mediaIds
      ));
      setState(() {});
    }

    if (route.mediaIds.isNotEmpty) {
      elements.add(ImageListViewAdd(
        onDelete: deleteImageCallback,
        mediaIds: widget.route.mediaIds,
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

    return Column(children: elements);
  }
}