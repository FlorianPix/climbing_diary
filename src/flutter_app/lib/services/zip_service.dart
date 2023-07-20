import 'dart:convert';
import 'dart:io';
import 'package:climbing_diary/interfaces/ascent/ascent.dart';
import 'package:climbing_diary/interfaces/multi_pitch_route/multi_pitch_route.dart';
import 'package:climbing_diary/interfaces/pitch/pitch.dart';
import 'package:climbing_diary/interfaces/single_pitch_route/single_pitch_route.dart';
import 'package:climbing_diary/interfaces/trip/update_trip.dart';
import 'package:climbing_diary/services/pitch_service.dart';
import 'package:climbing_diary/services/route_service.dart';
import 'package:climbing_diary/services/spot_service.dart';
import 'package:climbing_diary/services/trip_service.dart';
import 'package:path_provider/path_provider.dart';

import '../interfaces/spot/spot.dart';
import '../interfaces/trip/trip.dart';
import 'ascent_service.dart';

class ZipService {
  final TripService tripService = TripService();
  final SpotService spotService = SpotService();
  final RouteService routeService = RouteService();
  final PitchService pitchService = PitchService();
  final AscentService ascentService = AscentService();

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
    return writeJson(json);
  }

  Future<File> writeJson(Map<String, dynamic> json) async {
    final file = await _localFile;
    return file.writeAsString(jsonEncode(json));
  }

  Future<Map<String, dynamic>> readBackup() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
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

      Map<String, String> idTranslation = {};
      for (Spot s in spots) {
        Spot? createdSpot = await spotService.uploadSpot(s.toJson());
        for (String singlePitchRouteId in s.singlePitchRouteIds){
          SinglePitchRoute? singlePitchRoute = getSinglePitchRouteById(singlePitchRouteId, singlePitchRoutes);
          if (singlePitchRoute != null && createdSpot != null){
            idTranslation[s.id] = createdSpot.id;
            SinglePitchRoute? createdSinglePitchRoute = await routeService.uploadSinglePitchRoute(createdSpot.id, singlePitchRoute.toJson());
            for (String ascentId in singlePitchRoute.ascentIds){
              Ascent? ascent = getAscentById(ascentId, ascents);
              if (ascent != null && createdSinglePitchRoute != null) {
                ascentService.uploadAscentForSinglePitchRoute(createdSinglePitchRoute.id, ascent.toJson());
              }
            }
          }
        }
        for (String multiPitchRouteId in s.multiPitchRouteIds){
          MultiPitchRoute? multiPitchRoute = getMultiPitchRouteById(multiPitchRouteId, multiPitchRoutes);
          if (multiPitchRoute != null && createdSpot != null){
            idTranslation[s.id] = createdSpot.id;
            MultiPitchRoute? createdMultiPitchRoute = await routeService.uploadMultiPitchRoute(createdSpot.id, multiPitchRoute.toJson());
            for (String pitchId in multiPitchRoute.pitchIds){
              Pitch? pitch = getPitchById(pitchId, pitches);
              if (pitch != null && createdMultiPitchRoute != null) {
                Pitch? createdPitch = await pitchService.uploadPitch(createdMultiPitchRoute.id, pitch.toJson());
                for (String ascentId in pitch.ascentIds){
                  Ascent? ascent = getAscentById(ascentId, ascents);
                  if (ascent != null && createdPitch != null) {
                    ascentService.uploadAscent(createdPitch.id, ascent.toJson());
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
        if (createdTrip != null) {
          tripService.editTrip(UpdateTrip(id: createdTrip.id, spotIds: spotIds));
        }
      }

      return json;
    } catch (e) {
      print(e);
      return {};
    }
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