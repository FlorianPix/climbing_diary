import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:climbing_diary/interfaces/single_pitch_route/create_single_pitch_route.dart';
import 'package:climbing_diary/interfaces/single_pitch_route/update_single_pitch_route.dart';
import 'package:climbing_diary/services/trip_service.dart';
import 'package:climbing_diary/components/common/my_notifications.dart';
import 'package:climbing_diary/config/environment.dart';
import 'package:climbing_diary/data/network/dio_client.dart';
import 'package:climbing_diary/data/sharedprefs/shared_preference_helper.dart';
import 'package:climbing_diary/interfaces/ascent/ascent.dart';
import 'package:climbing_diary/interfaces/ascent/create_ascent.dart';
import 'package:climbing_diary/interfaces/ascent/update_ascent.dart';
import 'package:climbing_diary/interfaces/media.dart';
import 'package:climbing_diary/interfaces/multi_pitch_route/create_multi_pitch_route.dart';
import 'package:climbing_diary/interfaces/multi_pitch_route/multi_pitch_route.dart';
import 'package:climbing_diary/interfaces/multi_pitch_route/update_multi_pitch_route.dart';
import 'package:climbing_diary/interfaces/my_base_interface/update_my_base_interface.dart';
import 'package:climbing_diary/interfaces/pitch/create_pitch.dart';
import 'package:climbing_diary/interfaces/pitch/pitch.dart';
import 'package:climbing_diary/interfaces/pitch/update_pitch.dart';
import 'package:climbing_diary/interfaces/single_pitch_route/single_pitch_route.dart';
import 'package:climbing_diary/interfaces/spot/create_spot.dart';
import 'package:climbing_diary/interfaces/spot/spot.dart';
import 'package:climbing_diary/interfaces/spot/update_spot.dart';
import 'package:climbing_diary/interfaces/trip/create_trip.dart';
import 'package:climbing_diary/interfaces/trip/trip.dart';
import 'package:climbing_diary/interfaces/trip/update_trip.dart';
import 'package:climbing_diary/services/locator.dart';

class CacheService{
  final netWorkLocator = getIt.get<DioClient>();
  final sharedPrefLocator = getIt.get<SharedPreferenceHelper>();
  final String climbingApiHost = Environment().config.climbingApiHost;
  final String mediaApiHost = Environment().config.mediaApiHost;
  final TripService tripService = TripService();

  static const List<String> boxNames = [
    Media.boxName, Media.deleteBoxName,
    Trip.boxName, Trip.deleteBoxName, UpdateTrip.boxName, CreateTrip.boxName,
    Spot.boxName, Spot.deleteBoxName, UpdateSpot.boxName, CreateSpot.boxName,
    SinglePitchRoute.boxName, SinglePitchRoute.deleteBoxName, UpdateSinglePitchRoute.boxName, CreateSinglePitchRoute.boxName,
    MultiPitchRoute.boxName, MultiPitchRoute.deleteBoxName, UpdateMultiPitchRoute.boxName, CreateMultiPitchRoute.boxName,
    Pitch.boxName, Pitch.deleteBoxName, UpdatePitch.boxName, CreatePitch.boxName,
    Ascent.boxName, Ascent.deleteBoxName, UpdateAscent.boxName, CreateAscent.boxName
  ];

  static Future<void> initCache(String path) async {
    await Hive.initFlutter(path);
    for (String boxName in boxNames){
      await Hive.openBox(boxName);
    }
  }

  static Future<void> clearCache() async {
    Future.forEach(boxNames, (boxName) async => await Hive.box(boxName).clear());
  }

  static void printCache() {
    for (var boxName in boxNames) {
      print('$boxName: ${Hive.box(boxName).values}');
    }
  }

  /// Apply all changes that were made locally to the server.
  Future<void> applyChanges() async {
    // apply trip creations
    Box createTripBox = Hive.box(CreateTrip.boxName);
    for (int i = 0; i < createTripBox.length; i++){
      Map el = createTripBox.getAt(i);
      CreateTrip trip = CreateTrip.fromCache(el);
      await tripService.createTrip(trip, online: true);
    }
    // apply trip edits
    Box updateTripBox = Hive.box(UpdateTrip.boxName);
    for (int i = 0; i < updateTripBox.length; i++) {
      Map el = updateTripBox.getAt(i);
      UpdateTrip trip = UpdateTrip.fromCache(el);
      await tripService.editTrip(trip, online: true);
    }
    // apply trip deletions
    Box deleteTripBox = Hive.box(Trip.deleteBoxName);
    for (int i = 0; i < deleteTripBox.length; i++) {
      Map el = deleteTripBox.getAt(i);
      Trip trip = Trip.fromCache(el);
      await tripService.deleteTrip(trip, online: true);
    }
  }

  static List<T> getTsFromCache<T>(String boxName, T Function(Map) fromCacheFactory) {
    Box box = Hive.box(boxName);
    List<T> ts = [];
    for(var i = 0; i < box.length; i++){
      var data = box.getAt(i);
      ts.add(fromCacheFactory(data));
    }
    return ts;
  }

  static List<T> getCreateQueue<T>(String boxName, T Function(Map) fromCacheFactory) {
    Box box = Hive.box(boxName);
    List<T> ts = [];
    for(var i = 0; i < box.length; i++){
      ts.add(fromCacheFactory(box.getAt(i)));
    }
    return ts;
  }

  static Future<void> createQueuedTs<T>(String boxName, Future<T?> Function(Map) uploadT) async {
    Box box = Hive.box(boxName);
    var data = [];
    for(var i = 0; i < box.length; i++){
      data.add(box.getAt(i));
    }
    if (data.isEmpty) return;
    Future.forEach(data, (datum) async => await uploadT(datum));
  }

  static Future<void> deleteQueuedTs<T>(String boxName, Future<void> Function(Map) deleteT) async {
    Box box = Hive.box(boxName);
    var data = [];
    for(var i = 0; i < box.length; i++){
      data.add(box.getAt(i));
    }
    if (data.isEmpty) return;
    Future.forEach(data, (datum) async => await deleteT(datum));
  }

  static Future<void> editQueuedTs<T>(String boxName, Future<void> Function(Map) editT) async {
    Box box = Hive.box(boxName);
    var data = [];
    for(var i = 0; i < box.length; i++){
      data.add(box.getAt(i));
    }
    if (data.isEmpty) return;
    Future.forEach(data, (datum) async => await editT(datum));
  }

  static Future<void> editTFromCache<T extends UpdateMyBaseInterface>(String boxName, T t) async {
    return await Hive.box(boxName).put(t.id, t.toJson());
  }

  static bool isStale(Map cache, String serverUpdatedString){
    if (cache['updated'] == null) return true;
    DateTime cachedUpdated = DateTime.parse(cache['updated']);
    DateTime serverUpdated = DateTime.parse(serverUpdatedString);
    if (serverUpdated.compareTo(cachedUpdated) == 1) return true;
    return false;
  }

  static Media getMediumFromCache(String mediaId){
    Box box = Hive.box(Media.boxName);
    Media medium = Media.fromCache(box.get(mediaId));
    return medium;
  }
}