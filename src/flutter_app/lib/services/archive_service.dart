import 'dart:convert';
import 'dart:io';
import 'package:climbing_diary/interfaces/ascent/ascent.dart';
import 'package:climbing_diary/interfaces/ascent/update_ascent.dart';
import 'package:climbing_diary/interfaces/multi_pitch_route/multi_pitch_route.dart';
import 'package:climbing_diary/interfaces/pitch/pitch.dart';
import 'package:climbing_diary/interfaces/pitch/update_pitch.dart';
import 'package:climbing_diary/interfaces/single_pitch_route/single_pitch_route.dart';
import 'package:climbing_diary/interfaces/single_pitch_route/update_single_pitch_route.dart';
import 'package:climbing_diary/interfaces/trip/update_trip.dart';
import 'package:climbing_diary/services/pitch_service.dart';
import 'package:climbing_diary/services/single_pitch_route_service.dart';
import 'package:climbing_diary/services/spot_service.dart';
import 'package:climbing_diary/services/trip_service.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';

import '../interfaces/multi_pitch_route/update_multi_pitch_route.dart';
import '../interfaces/my_base_interface/my_base_interface.dart';
import '../interfaces/spot/spot.dart';
import '../interfaces/spot/update_spot.dart';
import '../interfaces/trip/trip.dart';
import 'ascent_service.dart';
import 'media_service.dart';
import 'multi_pitch_route_service.dart';

class ArchiveService {
  final TripService tripService = TripService();
  final SpotService spotService = SpotService();
  final MultiPitchRouteService multiPitchRouteService = MultiPitchRouteService();
  final SinglePitchRouteService singlePitchRouteService = SinglePitchRouteService();
  final PitchService pitchService = PitchService();
  final AscentService ascentService = AscentService();
  final MediaService mediaService = MediaService();

  Future<Directory?> get _imageDirectory async {
    final path = await _externalPath;
    if (path != null){
      return Directory('$path/img');
    }
    return null;
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/backup.json');
  }

  Future<String?> get _externalPath async {
    if (await _requestPermission(Permission.storage)) {
      Directory? directory = await getExternalStorageDirectory();
      if (directory != null) {
        return directory.path;
      }
    }
    return null;
  }

  Future<File?> get _externalFile async {
    final path = await _externalPath;
    if (path != null){
      return File('$path/backup.json');
    }
    return null;
  }

  Future<File?> _pickedFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      String? path = result.files.single.path;
      if (path != null) return File(path);
    } else {
      // User canceled the picker
    }
    return null;
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      }
    }
    return false;
  }

  Future<File?> writeBackup() async {
    List<Trip> trips = await tripService.getTrips(true);
    List<Spot> spots = await spotService.getSpots(true);
    List<SinglePitchRoute> singlePitchRoutes = await singlePitchRouteService.getSinglePitchRoutes(true);
    List<MultiPitchRoute> multiPitchRoutes = await multiPitchRouteService.getMultiPitchRoutes(true);
    List<Pitch> pitches = await pitchService.getPitches(true);
    List<Ascent> ascents = await ascentService.getAscents(true);
    Map<String, dynamic> json = {
      "trips": [],
      "spots": [],
      "single_pitch_routes": [],
      "multi_pitch_routes": [],
      "pitches": [],
      "ascents": []
    };
    json['trips'] = jsonEncode(trips);
    json['spots'] = jsonEncode(spots);
    json['single_pitch_routes'] = jsonEncode(singlePitchRoutes);
    json['multi_pitch_routes'] = jsonEncode(multiPitchRoutes);
    json['pitches'] = jsonEncode(pitches);
    json['ascents'] = jsonEncode(ascents);

    // images
    clearImageDir();
    writeImages(trips);
    writeImages(spots);
    writeImages(singlePitchRoutes);
    writeImages(multiPitchRoutes);
    writeImages(pitches);
    writeImages(ascents);

    return writeJson(json);
  }

  Future<File?> writeJson(Map<String, dynamic> json) async {
    final File? file = await _externalFile;
    if (file != null) {
      return file.writeAsString(jsonEncode(json));
    }
    return null;
  }

  Future<Map<String, dynamic>> readPicked() async {
    return readFile(_pickedFile());
  }

  Future<Map<String, dynamic>> readBackup() async {
    return readFile(_externalFile);
  }

  Future<Map<String, dynamic>> readFile(rFile) async {

    try {
      final File? file = await rFile;
      if (file != null) {
        final String contents = await file.readAsString();
        Map<String, dynamic> json = jsonDecode(contents);

        List<Trip> trips = decodeJsonList<Trip>(json, 'trips', Trip.fromJson);
        List<Spot> spots = decodeJsonList<Spot>(json, 'spots', Spot.fromJson);
        List<SinglePitchRoute> singlePitchRoutes = decodeJsonList<SinglePitchRoute>(json, 'single_pitch_routes', SinglePitchRoute.fromJson);
        List<MultiPitchRoute> multiPitchRoutes = decodeJsonList<MultiPitchRoute>(json, 'multi_pitch_routes', MultiPitchRoute.fromJson);
        List<Pitch> pitches = decodeJsonList<Pitch>(json, 'pitches', Pitch.fromJson);
        List<Ascent> ascents = decodeJsonList<Ascent>(json, 'ascents', Ascent.fromJson);

        // upload media and save translation from old to new id
        final imageDir = await _imageDirectory;
        if (imageDir != null) {
          final List<FileSystemEntity> entities = await imageDir.list().toList();
          final Iterable<File> imageFiles = entities.whereType<File>();
          Map<String, String> mediaIdTranslation = {};
          for (File image in imageFiles){
            String oldImageId = image.path;
            oldImageId = oldImageId.split('/').last;
            oldImageId = oldImageId.split('.')[0];
            String newImageId = await mediaService.uploadMedia(XFile(image.path));
            mediaIdTranslation[oldImageId] = newImageId;
          }

          Map<String, String> idTranslation = {};
          for (Spot spot in spots) {
            Spot? createdSpot = await spotService.uploadSpot(spot.toJson());
            for (String singlePitchRouteId in spot.singlePitchRouteIds){
              SinglePitchRoute? singlePitchRoute = getTById<SinglePitchRoute>(singlePitchRouteId, singlePitchRoutes);
              if (singlePitchRoute != null && createdSpot != null){
                await spotService.editSpot(UpdateSpot(id: createdSpot.id, mediaIds: getMediaIds(mediaIdTranslation, spot)));
                idTranslation[spot.id] = createdSpot.id;
                SinglePitchRoute? createdSinglePitchRoute = await singlePitchRouteService.uploadSinglePitchRoute(createdSpot.id, singlePitchRoute.toJson());
                for (String ascentId in singlePitchRoute.ascentIds){
                  Ascent? ascent = getTById<Ascent>(ascentId, ascents);
                  if (ascent != null && createdSinglePitchRoute != null) {
                    await singlePitchRouteService.editSinglePitchRoute(UpdateSinglePitchRoute(id: createdSinglePitchRoute.id, mediaIds: getMediaIds(mediaIdTranslation, singlePitchRoute)));
                    Ascent? createdAscent = await ascentService.uploadAscentForSinglePitchRoute(createdSinglePitchRoute.id, ascent.toJson());
                    if(createdAscent != null) {
                      await ascentService.editAscent(UpdateAscent(id: createdAscent.id, mediaIds: getMediaIds(mediaIdTranslation, ascent)));
                    }
                  }
                }
              }
            }
            for (String multiPitchRouteId in spot.multiPitchRouteIds){
              MultiPitchRoute? multiPitchRoute = getTById<MultiPitchRoute>(multiPitchRouteId, multiPitchRoutes);
              if (multiPitchRoute != null && createdSpot != null){
                await spotService.editSpot(UpdateSpot(id: createdSpot.id, mediaIds: getMediaIds(mediaIdTranslation, spot)));
                idTranslation[spot.id] = createdSpot.id;
                MultiPitchRoute? createdMultiPitchRoute = await multiPitchRouteService.uploadMultiPitchRoute(createdSpot.id, multiPitchRoute.toJson());
                for (String pitchId in multiPitchRoute.pitchIds){
                  Pitch? pitch = getTById<Pitch>(pitchId, pitches);
                  if (pitch != null && createdMultiPitchRoute != null) {
                    await multiPitchRouteService.editMultiPitchRoute(UpdateMultiPitchRoute(id: createdMultiPitchRoute.id, mediaIds: getMediaIds(mediaIdTranslation, multiPitchRoute)));
                    Pitch? createdPitch = await pitchService.uploadPitch(createdMultiPitchRoute.id, pitch.toJson());
                    for (String ascentId in pitch.ascentIds){
                      Ascent? ascent = getTById<Ascent>(ascentId, ascents);
                      if (ascent != null && createdPitch != null) {
                        await pitchService.editPitch(UpdatePitch(id: createdPitch.id, mediaIds: getMediaIds(mediaIdTranslation, pitch)));
                        Ascent? createdAscent = await ascentService.uploadAscent(createdPitch.id, ascent.toJson());
                        if(createdAscent != null) {
                          await ascentService.editAscent(UpdateAscent(id: createdAscent.id, mediaIds: getMediaIds(mediaIdTranslation, ascent)));
                        }
                      }
                    }
                  }
                }
              }
            }
          }

          for (Trip t in trips) {
            Trip? createdTrip = await tripService.uploadTrip(t.toJson());
            List<String> spotIds = [];
            for (String id in t.spotIds){
              String? newId = idTranslation[id];
              if (newId != null) {
                spotIds.add(newId);
              }
            }
            List<String> mediaIds = getMediaIds(mediaIdTranslation, t);
            if (createdTrip != null) {
              await tripService.editTrip(UpdateTrip(id: createdTrip.id, spotIds: spotIds, mediaIds: mediaIds));
            }
          }

          return json;
        } else {
          return {};
        }
      } else {
        return {};
      }
    } catch (e) {
      return {};
    }
  }

  void clearImageDir() async {
    String? directoryPath = await _externalPath;
    if (directoryPath != null) {
      directoryPath += '/img';
      Directory directory = await Directory(directoryPath).create(recursive: true);
      final List<FileSystemEntity> entities = await directory.list().toList();
      final Iterable<File> toDeleteFiles = entities.whereType<File>();
      for (File toDeleteFile in toDeleteFiles) {
        toDeleteFile.deleteSync();
      }
    }
  }

  void writeImages(List<dynamic> elements) async {
    for(dynamic e in elements){
      for(String mediaId in e.mediaIds){
        String imageURL = await mediaService.getMediumUrl(mediaId);
        Response response = await get(Uri.parse(imageURL));
        String? directoryPath = await _externalPath;
        if (directoryPath != null) {
          directoryPath += '/img';
          String filePath = '$directoryPath/$mediaId.jpg';
          await Directory(directoryPath).create(recursive: true);
          File file = File(filePath);
          file.writeAsBytesSync(response.bodyBytes);
        }
        // TODO handle fail
      }
    }
  }

  List<String> getMediaIds(Map<String, String> mediaIdTranslation, dynamic e){
    List<String> mediaIds = [];
    for (String id in e.mediaIds){
      String? newId = mediaIdTranslation[id];
      if (newId != null) {
        mediaIds.add(newId);
      }
    }
    return mediaIds;
  }

  T? getTById<T extends MyBaseInterface>(String id, List<T> ts){
    for (T t in ts){
      if (t.id == id){
        return t;
      }
    }
    return null;
  }

  List<T> decodeJsonList<T extends MyBaseInterface>(Map<String, dynamic> json, String key, T Function(Map<String, dynamic>) fromJsonFactory) {
    List<T> ts = [];
    for (dynamic t in jsonDecode(json[key]).map((t) => fromJsonFactory(t)).toList()) {
      ts.add(t as T);
    }
    return ts;
  }


}