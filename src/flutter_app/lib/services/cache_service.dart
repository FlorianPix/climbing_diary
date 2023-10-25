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
      print('$boxName ${Hive.box(boxName).length}: ${Hive.box(boxName).keys}');
    }
    print('--- End ---');
  }

  static void printCacheVerbose() {
    print('--- Cache ---');
    for (var boxName in boxNames) {
      print('$boxName ${Hive.box(boxName).length}: ${Hive.box(boxName).values}');
    }
    print('--- End ---');
  }

  /// Apply all changes that were made locally to the server.
  Future<void> applyChanges() async {
    await applyTripChanges();
    MyNotifications.showPositiveNotification("applied your trip changes");
    await applySpotChanges();
    MyNotifications.showPositiveNotification("applied your spot changes");
    await applySinglePitchRouteChanges();
    MyNotifications.showPositiveNotification("applied your single pitch route changes");
    await applyMultiPitchRouteChanges();
    MyNotifications.showPositiveNotification("applied your multi pitch route changes");
    await applyPitchChanges();
    MyNotifications.showPositiveNotification("applied your pitch changes");
    await applyAscentChanges();
    MyNotifications.showPositiveNotification("applied your ascent changes");
    await applyMediaChanges();
    MyNotifications.showPositiveNotification("applied your media changes");
  }

  Future<void> applyTripChanges() async {
    // apply trip creations
    Box createTripBox = Hive.box(CreateTrip.boxName);
    while (createTripBox.length > 0){
      Map el = createTripBox.getAt(0);
      Trip trip = Trip.fromCache(el);
      await tripService.createTrip(trip, online: true);
    }
    // apply trip edits
    Box updateTripBox = Hive.box(UpdateTrip.boxName);
    while (updateTripBox.length > 0) {
      Map el = updateTripBox.getAt(0);
      UpdateTrip trip = UpdateTrip.fromCache(el);
      await tripService.editTrip(trip, online: true);
    }
    // apply trip deletions
    Box deleteTripBox = Hive.box(Trip.deleteBoxName);
    while(deleteTripBox.length > 0) {
      Map el = deleteTripBox.getAt(0);
      Trip trip = Trip.fromCache(el);
      await tripService.deleteTrip(trip, online: true);
    }
  }

  Future<void> applySpotChanges() async {
    // apply spot creations
    Box createSpotBox = Hive.box(CreateSpot.boxName);
    while (createSpotBox.length > 0){
      Map el = createSpotBox.getAt(0);
      Spot spot = Spot.fromCache(el);
      await spotService.createSpot(spot, online: true);
    }
    // apply spot edits
    Box updateSpotBox = Hive.box(UpdateSpot.boxName);
    while (updateSpotBox.length > 0) {
      Map el = updateSpotBox.getAt(0);
      UpdateSpot spot = UpdateSpot.fromCache(el);
      await spotService.editSpot(spot, online: true);
    }
    // apply spot deletions
    Box deleteSpotBox = Hive.box(Spot.deleteBoxName);
    while (deleteSpotBox.length > 0) {
      Map el = deleteSpotBox.getAt(0);
      Spot spot = Spot.fromCache(el);
      await spotService.deleteSpot(spot, online: true);
    }
  }

  Future<void> applySinglePitchRouteChanges() async {
    // apply spot creations
    Box createSinglePitchRouteBox = Hive.box(SinglePitchRoute.createBoxName);
    while (createSinglePitchRouteBox.length > 0){
      Map el = createSinglePitchRouteBox.getAt(0);
      SinglePitchRoute singlePitchRoute = SinglePitchRoute.fromCache(el);
      await singlePitchRouteService.createSinglePitchRoute(singlePitchRoute, el['spotId'], online: true);
    }
    // apply singlePitchRoute edits
    Box updateSinglePitchRouteBox = Hive.box(UpdateSinglePitchRoute.boxName);
    while (updateSinglePitchRouteBox.length > 0) {
      Map el = updateSinglePitchRouteBox.getAt(0);
      UpdateSinglePitchRoute singlePitchRoute = UpdateSinglePitchRoute.fromCache(el);
      await singlePitchRouteService.editSinglePitchRoute(singlePitchRoute, online: true);
    }
    // apply singlePitchRoute deletions
    Box deleteSinglePitchRouteBox = Hive.box(SinglePitchRoute.deleteBoxName);
    while (deleteSinglePitchRouteBox.length > 0) {
      Map el = deleteSinglePitchRouteBox.getAt(0);
      SinglePitchRoute singlePitchRoute = SinglePitchRoute.fromCache(el);
      await singlePitchRouteService.deleteSinglePitchRoute(singlePitchRoute, el['spotId'], online: true);
    }
  }

  Future<void> applyMultiPitchRouteChanges() async {
    // apply multiPitchRoute creations
    Box createMultiPitchRouteBox = Hive.box(CreateMultiPitchRoute.boxName);
    while (createMultiPitchRouteBox.length > 0){
      Map el = createMultiPitchRouteBox.getAt(0);
      MultiPitchRoute multiPitchRoute = MultiPitchRoute.fromCache(el);
      await multiPitchRouteService.createMultiPitchRoute(multiPitchRoute, el['spotId'], online: true);
    }
    // apply multiPitchRoute edits
    Box updateMultiPitchRouteBox = Hive.box(UpdateMultiPitchRoute.boxName);
    while (updateMultiPitchRouteBox.length > 0) {
      Map el = updateMultiPitchRouteBox.getAt(0);
      UpdateMultiPitchRoute multiPitchRoute = UpdateMultiPitchRoute.fromCache(el);
      await multiPitchRouteService.editMultiPitchRoute(multiPitchRoute, online: true);
    }
    // apply multiPitchRoute deletions
    Box deleteMultiPitchRouteBox = Hive.box(MultiPitchRoute.deleteBoxName);
    while (deleteMultiPitchRouteBox.length > 0) {
      Map el = deleteMultiPitchRouteBox.getAt(0);
      MultiPitchRoute multiPitchRoute = MultiPitchRoute.fromCache(el);
      await multiPitchRouteService.deleteMultiPitchRoute(multiPitchRoute, el['spotId'], online: true);
    }
  }

  Future<void> applyPitchChanges() async {
    // apply pitch creations
    Box createPitchBox = Hive.box(CreatePitch.boxName);
    while (createPitchBox.length > 0){
      Map el = createPitchBox.getAt(0);
      Pitch pitch = Pitch.fromCache(el);
      await pitchService.createPitch(pitch, el['routeId'], online: true);
    }
    // apply pitch edits
    Box updatePitchBox = Hive.box(UpdatePitch.boxName);
    while (updatePitchBox.length > 0) {
      Map el = updatePitchBox.getAt(0);
      UpdatePitch pitch = UpdatePitch.fromCache(el);
      await pitchService.editPitch(pitch, online: true);
    }
    // apply pitch deletions
    Box deletePitchBox = Hive.box(Pitch.deleteBoxName);
    while (deletePitchBox.length > 0) {
      Map el = deletePitchBox.getAt(0);
      Pitch pitch = Pitch.fromCache(el);
      await pitchService.deletePitch(pitch, el['routeId'], online: true);
    }
  }

  Future<void> applyAscentChanges() async {
    // apply ascent creations
    Box createAscentBox = Hive.box(CreateAscent.boxName);
    while (createAscentBox.length > 0){
      Map el = createAscentBox.getAt(0);
      Ascent ascent = Ascent.fromCache(el);
      if (el['ofPitch']) {
        await ascentService.createAscentForPitch(ascent, el['parentId'], online: true);
      } else {
        await ascentService.createAscentForSinglePitchRoute(ascent, el['parentId'], online: true);
      }
    }
    // apply ascent edits
    Box updateAscentBox = Hive.box(UpdateAscent.boxName);
    while (updateAscentBox.length > 0) {
      Map el = updateAscentBox.getAt(0);
      UpdateAscent ascent = UpdateAscent.fromCache(el);
      await ascentService.editAscent(ascent, online: true);
    }
    // apply ascent deletions
    Box deleteAscentBox = Hive.box(Ascent.deleteBoxName);
    while (deleteAscentBox.length > 0) {
      Map el = deleteAscentBox.getAt(0);
      Ascent ascent = Ascent.fromCache(el);
      if (el['ofPitch']) {
        await ascentService.deleteAscentOfPitch(ascent, el['parentId'], online: true);
      } else {
        await ascentService.deleteAscentOfSinglePitchRoute(ascent, el['parentId'], online: true);
      }
    }
  }

  Future<void> applyMediaChanges() async {
    // apply media creations
    Box createMediaBox = Hive.box(Media.createBoxName);
    while (createMediaBox.length > 0){
      Map el = createMediaBox.getAt(0);
      Media medium = Media.fromCache(el);
      await mediaService.createMedium(medium, online: true);
    }
    // apply media deletions
    Box deleteMediaBox = Hive.box(Media.deleteBoxName);
    while (deleteMediaBox.length > 0) {
      Map el = deleteMediaBox.getAt(0);
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