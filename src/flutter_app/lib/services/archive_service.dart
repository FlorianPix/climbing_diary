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
import 'package:climbing_diary/services/route_service.dart';
import 'package:climbing_diary/services/spot_service.dart';
import 'package:climbing_diary/services/trip_service.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../interfaces/multi_pitch_route/update_multi_pitch_route.dart';
import '../interfaces/spot/spot.dart';
import '../interfaces/spot/update_spot.dart';
import '../interfaces/trip/trip.dart';
import 'ascent_service.dart';
import 'media_service.dart';

class ArchiveService {
  final TripService tripService = TripService();
  final SpotService spotService = SpotService();
  final RouteService routeService = RouteService();
  final PitchService pitchService = PitchService();
  final AscentService ascentService = AscentService();
  final MediaService mediaService = MediaService();

  Future<Directory> get _imageDirectory async {
    final path = await _localPath;
    return Directory('$path/img');
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/backup.json');
  }

  Future<File> writeBackup() async {
    List<Trip> trips = await tripService.getTrips();
    List<Spot> spots = await spotService.getSpots();
    List<SinglePitchRoute> singlePitchRoutes = await routeService.getSinglePitchRoutes();
    List<MultiPitchRoute> multiPitchRoutes = await routeService.getMultiPitchRoutes();
    List<Pitch> pitches = await pitchService.getPitches();
    List<Ascent> ascents = await ascentService.getAscents();
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

    // trip images
    for(Trip t in trips){
      for(String mediaId in t.mediaIds){
        String imageURL = await mediaService.getMediumUrl(mediaId);
        Response response = await get(Uri.parse(imageURL));
        String directoryPath = await _localPath;
        directoryPath += '/img';
        String filePath = '$directoryPath/$mediaId.jpg';
        await Directory(directoryPath).create(recursive: true);
        File file = File(filePath);
        file.writeAsBytesSync(response.bodyBytes);
      }
    }
    // trip images
    for(Trip t in trips){
      for(String mediaId in t.mediaIds){
        String imageURL = await mediaService.getMediumUrl(mediaId);
        Response response = await get(Uri.parse(imageURL));
        String directoryPath = await _localPath;
        directoryPath += '/img';
        String filePath = '$directoryPath/$mediaId.jpg';
        await Directory(directoryPath).create(recursive: true);
        File file = File(filePath);
        file.writeAsBytesSync(response.bodyBytes);
      }
    }
    // trip images
    for(Trip t in trips){
      for(String mediaId in t.mediaIds){
        String imageURL = await mediaService.getMediumUrl(mediaId);
        Response response = await get(Uri.parse(imageURL));
        String directoryPath = await _localPath;
        directoryPath += '/img';
        String filePath = '$directoryPath/$mediaId.jpg';
        await Directory(directoryPath).create(recursive: true);
        File file = File(filePath);
        file.writeAsBytesSync(response.bodyBytes);
      }
    }
    // trip images
    for(Trip t in trips){
      for(String mediaId in t.mediaIds){
        String imageURL = await mediaService.getMediumUrl(mediaId);
        Response response = await get(Uri.parse(imageURL));
        String directoryPath = await _localPath;
        directoryPath += '/img';
        String filePath = '$directoryPath/$mediaId.jpg';
        await Directory(directoryPath).create(recursive: true);
        File file = File(filePath);
        file.writeAsBytesSync(response.bodyBytes);
      }
    }
    // images
    writeImages(trips);
    writeImages(spots);
    writeImages(singlePitchRoutes);
    writeImages(multiPitchRoutes);
    writeImages(pitches);
    writeImages(ascents);

    return writeJson(json);
  }

  Future<File> writeJson(Map<String, dynamic> json) async {
    final file = await _localFile;
    return file.writeAsString(jsonEncode(json));
  }

  Future<Map<String, dynamic>> readBackup() async {
    try {
      final File file = await _localFile;
      final String contents = await file.readAsString();
      Map<String, dynamic> json = jsonDecode(contents);
      List<dynamic> pre = [];
      // trips
      pre = jsonDecode(json['trips']).map((t) => Trip.fromJson(t)).toList();
      List<Trip> trips = [];
      for(dynamic t in pre){
        trips.add(t as Trip);
      }
      // spots
      pre = jsonDecode(json['spots']).map((s) => Spot.fromJson(s)).toList();
      List<Spot> spots = [];
      for(dynamic s in pre) {
        spots.add(s as Spot);
      }
      // single pitch routes
      pre = jsonDecode(json['single_pitch_routes']).map((s) => SinglePitchRoute.fromJson(s)).toList();
      List<SinglePitchRoute> singlePitchRoutes = [];
      for(dynamic s in pre) {
        singlePitchRoutes.add(s as SinglePitchRoute);
      }
      // multi pitch routes
      pre = jsonDecode(json['multi_pitch_routes']).map((m) => MultiPitchRoute.fromJson(m)).toList();
      List<MultiPitchRoute> multiPitchRoutes = [];
      for(dynamic s in pre) {
        multiPitchRoutes.add(s as MultiPitchRoute);
      }
      // pitches
      pre = jsonDecode(json['pitches']).map((p) => Pitch.fromJson(p)).toList();
      List<Pitch> pitches = [];
      for(dynamic s in pre) {
        pitches.add(s as Pitch);
      }
      // ascents
      pre = jsonDecode(json['ascents']).map((a) => Ascent.fromJson(a)).toList();
      List<Ascent> ascents = [];
      for(dynamic s in pre) {
        ascents.add(s as Ascent);
      }

      // upload media and save translation from old to new id
      final imageDir = await _imageDirectory;
      final List<FileSystemEntity> entities = await imageDir.list().toList();
      final Iterable<File> imageFiles = entities.whereType<File>();
      Map<String, String> mediaIdTranslation = {};
      for (File image in imageFiles){
        String oldImageId = image.path;
        oldImageId = oldImageId.split('/')[7];
        oldImageId = oldImageId.split('.')[0];
        String newImageId = await mediaService.uploadMedia(XFile(image.path));
        mediaIdTranslation[oldImageId] = newImageId;
      }

      Map<String, String> idTranslation = {};
      for (Spot spot in spots) {
        Spot? createdSpot = await spotService.uploadSpot(spot.toJson());
        for (String singlePitchRouteId in spot.singlePitchRouteIds){
          SinglePitchRoute? singlePitchRoute = getSinglePitchRouteById(singlePitchRouteId, singlePitchRoutes);
          if (singlePitchRoute != null && createdSpot != null){
            await spotService.editSpot(UpdateSpot(id: createdSpot.id, mediaIds: getMediaIds(mediaIdTranslation, spot)));
            idTranslation[spot.id] = createdSpot.id;
            SinglePitchRoute? createdSinglePitchRoute = await routeService.uploadSinglePitchRoute(createdSpot.id, singlePitchRoute.toJson());
            for (String ascentId in singlePitchRoute.ascentIds){
              Ascent? ascent = getAscentById(ascentId, ascents);
              if (ascent != null && createdSinglePitchRoute != null) {
                await routeService.editSinglePitchRoute(UpdateSinglePitchRoute(id: createdSinglePitchRoute.id, mediaIds: getMediaIds(mediaIdTranslation, singlePitchRoute)));
                Ascent? createdAscent = await ascentService.uploadAscentForSinglePitchRoute(createdSinglePitchRoute.id, ascent.toJson());
                if(createdAscent != null) {
                  await ascentService.editAscent(UpdateAscent(id: createdAscent.id, mediaIds: getMediaIds(mediaIdTranslation, ascent)));
                }
              }
            }
          }
        }
        for (String multiPitchRouteId in spot.multiPitchRouteIds){
          MultiPitchRoute? multiPitchRoute = getMultiPitchRouteById(multiPitchRouteId, multiPitchRoutes);
          if (multiPitchRoute != null && createdSpot != null){
            await spotService.editSpot(UpdateSpot(id: createdSpot.id, mediaIds: getMediaIds(mediaIdTranslation, spot)));
            idTranslation[spot.id] = createdSpot.id;
            MultiPitchRoute? createdMultiPitchRoute = await routeService.uploadMultiPitchRoute(createdSpot.id, multiPitchRoute.toJson());
            for (String pitchId in multiPitchRoute.pitchIds){
              Pitch? pitch = getPitchById(pitchId, pitches);
              if (pitch != null && createdMultiPitchRoute != null) {
                await routeService.editMultiPitchRoute(UpdateMultiPitchRoute(id: createdMultiPitchRoute.id, mediaIds: getMediaIds(mediaIdTranslation, multiPitchRoute)));
                Pitch? createdPitch = await pitchService.uploadPitch(createdMultiPitchRoute.id, pitch.toJson());
                for (String ascentId in pitch.ascentIds){
                  Ascent? ascent = getAscentById(ascentId, ascents);
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
    } catch (e) {
      print(e);
      return {};
    }
  }

  void writeImages(List<dynamic> elements) async {
    for(dynamic e in elements){
      for(String mediaId in e.mediaIds){
        String imageURL = await mediaService.getMediumUrl(mediaId);
        Response response = await get(Uri.parse(imageURL));
        String directoryPath = await _localPath;
        directoryPath += '/img';
        String filePath = '$directoryPath/$mediaId.jpg';
        await Directory(directoryPath).create(recursive: true);
        File file = File(filePath);
        file.writeAsBytesSync(response.bodyBytes);
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

  Trip? getTripById(String id, List<Trip> trips){
    for (Trip t in trips){
      if (t.id == id){
        return t;
      }
    }
    return null;
  }

  SinglePitchRoute? getSinglePitchRouteById(String id, List<SinglePitchRoute> singlePitchRoutes){
    for (SinglePitchRoute r in singlePitchRoutes){
      if (r.id == id){
        return r;
      }
    }
    return null;
  }

  MultiPitchRoute? getMultiPitchRouteById(String id, List<MultiPitchRoute> multiPitchRoutes){
    for (MultiPitchRoute r in multiPitchRoutes){
      if (r.id == id){
        return r;
      }
    }
    return null;
  }

  Pitch? getPitchById(String id, List<Pitch> pitches){
    for (Pitch p in pitches){
      if (p.id == id){
        return p;
      }
    }
    return null;
  }

  Ascent? getAscentById(String id, List<Ascent> ascents){
    for (Ascent a in ascents){
      if (a.id == id){
        return a;
      }
    }
    return null;
  }
}