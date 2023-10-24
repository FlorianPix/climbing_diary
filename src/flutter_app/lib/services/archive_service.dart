import 'dart:convert';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:climbing_diary/interfaces/ascent/ascent.dart';
import 'package:climbing_diary/interfaces/multi_pitch_route/multi_pitch_route.dart';
import 'package:climbing_diary/interfaces/pitch/pitch.dart';
import 'package:climbing_diary/interfaces/single_pitch_route/single_pitch_route.dart';
import 'package:climbing_diary/services/pitch_service.dart';
import 'package:climbing_diary/services/single_pitch_route_service.dart';
import 'package:climbing_diary/services/spot_service.dart';
import 'package:climbing_diary/services/trip_service.dart';
import 'package:climbing_diary/interfaces/media/media.dart';
import 'package:climbing_diary/interfaces/my_base_interface/my_base_interface.dart';
import 'package:climbing_diary/interfaces/spot/spot.dart';
import 'package:climbing_diary/interfaces/trip/trip.dart';
import 'package:climbing_diary/services/ascent_service.dart';
import 'package:climbing_diary/services/media_service.dart';
import 'package:climbing_diary/services/multi_pitch_route_service.dart';
import 'package:climbing_diary/components/common/my_notifications.dart';

class ArchiveService {
  final TripService tripService = TripService();
  final SpotService spotService = SpotService();
  final MultiPitchRouteService multiPitchRouteService = MultiPitchRouteService();
  final SinglePitchRouteService singlePitchRouteService = SinglePitchRouteService();
  final PitchService pitchService = PitchService();
  final AscentService ascentService = AscentService();
  final MediaService mediaService = MediaService();

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

  /// save all data to a user picked directory
  Future<void> export() async {
    if (! await _requestPermission(Permission.storage)) return;
    // pick a directory to export to
    String? directoryPath = await FilePicker.platform.getDirectoryPath();
    if (directoryPath == null) return;
    // export trips
    List<Trip> trips = await tripService.getTrips();
    File file = File('$directoryPath/${Trip.boxName}.json');
    await file.writeAsString(jsonEncode(trips));
    // export spots
    List<Spot> spots = await spotService.getSpots();
    file = File('$directoryPath/${Spot.boxName}.json');
    await file.writeAsString(jsonEncode(spots));
    // export singlePitchRoutes
    List<SinglePitchRoute> singlePitchRoutes = await singlePitchRouteService.getSinglePitchRoutes();
    file = File('$directoryPath/${SinglePitchRoute.boxName}.json');
    await file.writeAsString(jsonEncode(singlePitchRoutes));
    // export multiPitchRoutes
    List<MultiPitchRoute> multiPitchRoutes = await multiPitchRouteService.getMultiPitchRoutes();
    file = File('$directoryPath/${MultiPitchRoute.boxName}.json');
    await file.writeAsString(jsonEncode(multiPitchRoutes));
    // export pitches
    List<Pitch> pitches = await pitchService.getPitches();
    file = File('$directoryPath/${Pitch.boxName}.json');
    await file.writeAsString(jsonEncode(pitches));
    // export ascents
    List<Ascent> ascents = await ascentService.getAscents();
    file = File('$directoryPath/${Ascent.boxName}.json');
    await file.writeAsString(jsonEncode(ascents));
    // export media
    List<Media> media = await mediaService.getMedia();
    file = File('$directoryPath/${Media.boxName}.json');
    await file.writeAsString(jsonEncode(media));
    MyNotifications.showPositiveNotification("exported to $directoryPath");
  }

  Future<void> import() async{
    if (! await _requestPermission(Permission.storage)) return;
    // pick a directory to export to
    String? directoryPath = await FilePicker.platform.getDirectoryPath();
    if (directoryPath == null) return;
    // import trips
    File file = File('$directoryPath/${Trip.boxName}.json');
    List<Map<String, dynamic>> jsonTrips = List<Map<String, dynamic>>.from(jsonDecode(await file.readAsString()));
    List<Trip> trips = decodeJsonList<Trip>(jsonTrips, Trip.fromJson);
    for (Trip trip in trips){
      await tripService.createTrip(trip);
    }
    // import spots
    file = File('$directoryPath/${Spot.boxName}.json');
    List<Map<String, dynamic>> jsonSpots = List<Map<String, dynamic>>.from(jsonDecode(await file.readAsString()));
    List<Spot> spots = decodeJsonList<Spot>(jsonSpots, Spot.fromJson);
    for (Spot spot in spots){
      await spotService.createSpot(spot);
    }
    // import singlePitchRoutes
    file = File('$directoryPath/${SinglePitchRoute.boxName}.json');
    List<Map<String, dynamic>> jsonSinglePitchRoutes = List<Map<String, dynamic>>.from(jsonDecode(await file.readAsString()));
    List<SinglePitchRoute> singlePitchRoutes = decodeJsonList<SinglePitchRoute>(jsonSinglePitchRoutes, SinglePitchRoute.fromJson);
    for (SinglePitchRoute singlePitchRoute in singlePitchRoutes){
      Spot? spot = findSpotOfSinglePitchRoute(spots, singlePitchRoute);
      if (spot == null) continue;
      await singlePitchRouteService.createSinglePitchRoute(singlePitchRoute, spot.id);
    }
    // import multiPitchRoutes
    file = File('$directoryPath/${MultiPitchRoute.boxName}.json');
    List<Map<String, dynamic>> jsonMultiPitchRoutes = List<Map<String, dynamic>>.from(jsonDecode(await file.readAsString()));
    List<MultiPitchRoute> multiPitchRoutes = decodeJsonList<MultiPitchRoute>(jsonMultiPitchRoutes, MultiPitchRoute.fromJson);
    for (MultiPitchRoute multiPitchRoute in multiPitchRoutes){
      Spot? spot = findSpotOfMultiPitchRoute(spots, multiPitchRoute);
      if (spot == null) continue;
      await multiPitchRouteService.createMultiPitchRoute(multiPitchRoute, spot.id);
    }
    // import pitches
    file = File('$directoryPath/${Pitch.boxName}.json');
    List<Map<String, dynamic>> jsonPitches = List<Map<String, dynamic>>.from(jsonDecode(await file.readAsString()));
    List<Pitch> pitches = decodeJsonList<Pitch>(jsonPitches, Pitch.fromJson);
    for (Pitch pitch in pitches){
      MultiPitchRoute? multiPitchRoute = findMultiPitchRouteOfPitch(multiPitchRoutes, pitch);
      if (multiPitchRoute == null) continue;
      await pitchService.createPitch(pitch, multiPitchRoute.id);
    }
    // import ascents
    file = File('$directoryPath/${Ascent.boxName}.json');
    List<Map<String, dynamic>> jsonAscents = List<Map<String, dynamic>>.from(jsonDecode(await file.readAsString()));
    List<Ascent> ascents = decodeJsonList<Ascent>(jsonAscents, Ascent.fromJson);
    for (Ascent ascent in ascents){
      Pitch? pitch = findPitchOfAscent(pitches, ascent);
      if (pitch != null) await ascentService.createAscentForPitch(ascent, pitch.id);
      SinglePitchRoute? singlePitchRoute = findSinglePitchRouteOfAscent(singlePitchRoutes, ascent);
      if (singlePitchRoute != null) await ascentService.createAscentForSinglePitchRoute(ascent, singlePitchRoute.id);
    }
    // import media
    file = File('$directoryPath/${Media.boxName}.json');
    List<Map<String, dynamic>> jsonMedia = List<Map<String, dynamic>>.from(jsonDecode(await file.readAsString()));
    List<Media> media = [];
    for (Map<String, dynamic> t in jsonMedia) {
      media.add(Media.fromJson(t));
    }
    for (Media medium in media){
      await mediaService.createMedium(medium);
    }
    MyNotifications.showPositiveNotification("imported from $directoryPath");
  }

  Spot? findSpotOfSinglePitchRoute(List<Spot> spots, SinglePitchRoute singlePitchRoute){
    for (Spot spot in spots){
      for (String id in spot.singlePitchRouteIds){
        if (id == singlePitchRoute.id){
          return spot;
        }
      }
    }
    return null;
  }

  Spot? findSpotOfMultiPitchRoute(List<Spot> spots, MultiPitchRoute multiPitchRoute){
    for (Spot spot in spots){
      for (String id in spot.multiPitchRouteIds){
        if (id == multiPitchRoute.id){
          return spot;
        }
      }
    }
    return null;
  }

  MultiPitchRoute? findMultiPitchRouteOfPitch(List<MultiPitchRoute> multiPitchRoutes, Pitch pitch){
    for (MultiPitchRoute multiPitchRoute in multiPitchRoutes){
      for (String id in multiPitchRoute.pitchIds){
        if (id == pitch.id){
          return multiPitchRoute;
        }
      }
    }
    return null;
  }

  SinglePitchRoute? findSinglePitchRouteOfAscent(List<SinglePitchRoute> singlePitchRoutes, Ascent ascent){
    for (SinglePitchRoute singlePitchRoute in singlePitchRoutes){
      for (String id in singlePitchRoute.ascentIds){
        if (id == ascent.id){
          return singlePitchRoute;
        }
      }
    }
    return null;
  }

  Pitch? findPitchOfAscent(List<Pitch> pitches, Ascent ascent){
    for (Pitch pitch in pitches){
      for (String id in pitch.ascentIds){
        if (id == ascent.id){
          return pitch;
        }
      }
    }
    return null;
  }

  List<T> decodeJsonList<T extends MyBaseInterface>(List<Map<String, dynamic>> jsonList, T Function(Map<String, dynamic>) fromJsonFactory) {
    List<T> ts = [];
    for (Map<String, dynamic> t in jsonList) {
      ts.add(fromJsonFactory(t));
    }
    return ts;
  }


}