import 'package:climbing_diary/interfaces/ascent/delete_ascent.dart';
import 'package:climbing_diary/services/media_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:climbing_diary/services/ascent_service.dart';
import 'package:climbing_diary/services/multi_pitch_route_service.dart';
import 'package:climbing_diary/services/pitch_service.dart';
import 'package:climbing_diary/services/single_pitch_route_service.dart';
import 'package:climbing_diary/services/spot_service.dart';
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
import 'package:climbing_diary/interfaces/media/media.dart';
import 'package:climbing_diary/interfaces/multi_pitch_route/create_multi_pitch_route.dart';
import 'package:climbing_diary/interfaces/multi_pitch_route/multi_pitch_route.dart';
import 'package:climbing_diary/interfaces/multi_pitch_route/update_multi_pitch_route.dart';
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
  final SpotService spotService = SpotService();
  final SinglePitchRouteService singlePitchRouteService = SinglePitchRouteService();
  final MultiPitchRouteService multiPitchRouteService = MultiPitchRouteService();
  final PitchService pitchService = PitchService();
  final AscentService ascentService = AscentService();
  final MediaService mediaService = MediaService();

  static const List<String> boxNames = [
    Media.boxName, Media.deleteBoxName, Media.createBoxName,
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
    print('--- Cache ---');
    for (var boxName in boxNames) {
      print('$boxName ${Hive.box(boxName).length}: ${Hive.box(boxName).values}');
    }
    print('--- End ---');
  }

  /// Apply all changes that were made locally to the server.
  Future<void> applyChanges() async {
    await applyTripChanges();
    MyNotifications.showPositiveNotification("synced your trip changes");
    await applySpotChanges();
    MyNotifications.showPositiveNotification("synced your spot changes");
    await applySinglePitchRouteChanges();
    MyNotifications.showPositiveNotification("synced your single pitch route changes");
    await applyMultiPitchRouteChanges();
    MyNotifications.showPositiveNotification("synced your multi pitch route changes");
    await applyPitchChanges();
    MyNotifications.showPositiveNotification("synced your pitch changes");
    await applyAscentChanges();
    MyNotifications.showPositiveNotification("synced your ascent changes");
    await applyMediaChanges();
    MyNotifications.showPositiveNotification("synced your media changes");
  }

  Future<void> applyTripChanges() async {
    // apply trip creations
    Box createTripBox = Hive.box(CreateTrip.boxName);
    for (int i = 0; i < createTripBox.length; i++){
      Map el = createTripBox.getAt(i);
      Trip trip = Trip.fromCache(el);
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

  Future<void> applySpotChanges() async {
    // apply spot creations
    Box createSpotBox = Hive.box(CreateSpot.boxName);
    for (int i = 0; i < createSpotBox.length; i++){
      Map el = createSpotBox.getAt(i);
      Spot spot = Spot.fromCache(el);
      await spotService.createSpot(spot, online: true);
    }
    // apply spot edits
    Box updateSpotBox = Hive.box(UpdateSpot.boxName);
    for (int i = 0; i < updateSpotBox.length; i++) {
      Map el = updateSpotBox.getAt(i);
      UpdateSpot spot = UpdateSpot.fromCache(el);
      await spotService.editSpot(spot, online: true);
    }
    // apply spot deletions
    Box deleteSpotBox = Hive.box(Spot.deleteBoxName);
    for (int i = 0; i < deleteSpotBox.length; i++) {
      Map el = deleteSpotBox.getAt(i);
      Spot spot = Spot.fromCache(el);
      await spotService.deleteSpot(spot, online: true);
    }
  }

  Future<void> applySinglePitchRouteChanges() async {

  }

  Future<void> applyMultiPitchRouteChanges() async {

  }

  Future<void> applyPitchChanges() async {

  }

  Future<void> applyAscentChanges() async {
    // apply ascent creations
    Box createAscentBox = Hive.box(CreateAscent.boxName);
    for (int i = 0; i < createAscentBox.length; i++){
      Map el = createAscentBox.getAt(i);
      String id = createAscentBox.keyAt(i);
      CreateAscent ascent = CreateAscent.fromCache(el);
      await ascentService.createAscentForPitch(id, ascent, online: true);
      await ascentService.createAscentForSinglePitchRoute(id, ascent, online: true);
    }
    // apply ascent edits
    Box updateAscentBox = Hive.box(UpdateAscent.boxName);
    for (int i = 0; i < updateAscentBox.length; i++) {
      Map el = updateAscentBox.getAt(i);
      UpdateAscent ascent = UpdateAscent.fromCache(el);
      await ascentService.editAscent(ascent, online: true);
    }
    // apply ascent deletions
    Box deleteAscentBox = Hive.box(Ascent.deleteBoxName);
    for (int i = 0; i < deleteAscentBox.length; i++) {
      Map el = deleteAscentBox.getAt(i);
      DeleteAscent deleteAscent = DeleteAscent.fromCache(el);
      String pitchId = deleteAscent.pitchId;
      Ascent ascent = deleteAscent.ascent;
      if (deleteAscent.ofPitch) {
        await ascentService.deleteAscentOfPitch(pitchId, ascent, online: true);
      } else {
        await ascentService.deleteAscentOfSinglePitchRoute(pitchId, ascent, online: true);
      }
    }
  }

  Future<void> applyMediaChanges() async {
    // apply media creations
    Box createMediaBox = Hive.box(Media.createBoxName);
    for (int i = 0; i < createMediaBox.length; i++){
      Map el = createMediaBox.getAt(i);
      Media medium = Media.fromCache(el);
      await mediaService.createMedium(medium, online: true);
    }
    // apply media deletions
    Box deleteMediaBox = Hive.box(Media.deleteBoxName);
    for (int i = 0; i < deleteMediaBox.length; i++) {
      Map el = deleteMediaBox.getAt(i);
      Media media = Media.fromCache(el);
      await mediaService.deleteMedium(media, online: true);
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

  static List<Media> getMediaFromCache(Media Function(Map) fromCacheFactory) {
    Box box = Hive.box(Media.boxName);
    List<Media> ts = [];
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

  static bool isStale(Map cache, String serverUpdatedString){
    if (cache['updated'] == null) return true;
    DateTime cachedUpdated = DateTime.parse(cache['updated']);
    DateTime serverUpdated = DateTime.parse(serverUpdatedString);
    if (serverUpdated.compareTo(cachedUpdated) == 1) return true;
    return false;
  }
}