import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:climbing_diary/services/error_service.dart';
import 'package:climbing_diary/services/pitch_service.dart';
import 'package:climbing_diary/services/single_pitch_route_service.dart';
import 'package:climbing_diary/components/common/my_notifications.dart';
import 'package:climbing_diary/config/environment.dart';
import 'package:climbing_diary/interfaces/ascent/ascent.dart';
import 'package:climbing_diary/interfaces/multi_pitch_route/multi_pitch_route.dart';
import 'package:climbing_diary/interfaces/pitch/pitch.dart';
import 'package:climbing_diary/interfaces/single_pitch_route/single_pitch_route.dart';
import 'package:climbing_diary/interfaces/spot/create_spot.dart';
import 'package:climbing_diary/data/network/dio_client.dart';
import 'package:climbing_diary/data/sharedprefs/shared_preference_helper.dart';
import 'package:climbing_diary/interfaces/spot/spot.dart';
import 'package:climbing_diary/interfaces/spot/update_spot.dart';
import 'package:climbing_diary/services/ascent_service.dart';
import 'package:climbing_diary/services/cache_service.dart';
import 'package:climbing_diary/services/locator.dart';
import 'package:climbing_diary/services/multi_pitch_route_service.dart';
import 'package:climbing_diary/interfaces/media/media.dart';
import 'package:climbing_diary/interfaces/trip/trip.dart';

class SpotService {
  final MultiPitchRouteService multiPitchRouteService = MultiPitchRouteService();
  final SinglePitchRouteService singlePitchRouteService = SinglePitchRouteService();
  final PitchService pitchService = PitchService();
  final AscentService ascentService = AscentService();
  final netWorkLocator = getIt.get<DioClient>();
  final sharedPrefLocator = getIt.get<SharedPreferenceHelper>();
  final String climbingApiHost = Environment().config.climbingApiHost;
  final String mediaApiHost = Environment().config.mediaApiHost;

  /// Get a spot by its id from cache and optionally from the server.
  /// If the parameter [online] is null or false the spot is searched in cache,
  /// otherwise it is requested from the server.
  Future<Spot?> getSpot(String spotId, {bool? online}) async {
    Box box = Hive.box(Spot.boxName);
    if (online == null || !online) return Spot.fromCache(box.get(spotId));
    // request spot from server
    try {
      final Response spotResponse = await netWorkLocator.dio.post('$climbingApiHost/spot/$spotId');
      if (spotResponse.statusCode != 200) throw Exception("Error during request of missing spot");
      return Spot.fromJson(spotResponse.data);
    } catch (e) {
      ErrorService.handleConnectionErrors(e);
    }
    return null;
  }

  /// Get spots with given ids from cache and optionally from the server.
  /// If the parameter [online] is null or false the spots are searched in cache,
  /// otherwise they are requested from the server.
  Future<List<Spot>> getSpotsOfIds(List<String> spotIds, {bool? online}) async {
    List<Spot> spots = CacheService.getTsFromCache<Spot>(Spot.boxName, Spot.fromCache);
    if(online == null || !online) return spots.where((spot) => spotIds.contains(spot.id)).toList();
    // request spots from the server
    try {
      List<Spot> spots = [];
      Box box = Hive.box(Spot.boxName);
      final Response missingSpotsResponse = await netWorkLocator.dio.post('$climbingApiHost/spot/ids', data: spotIds);
      if (missingSpotsResponse.statusCode != 200) throw Exception("Error during request of missing spots");
      Future.forEach(missingSpotsResponse.data, (dynamic s) async {
        Spot spot = Spot.fromJson(s);
        await box.put(spot.id, spot.toJson());
        spots.add(spot);
      });
      return spots;
    } catch (e) {
      ErrorService.handleConnectionErrors(e);
    }
    return [];
  }

  /// Get all spots from cache and optionally from the server.
  /// If the parameter [online] is null or false the spots are searched in cache,
  /// otherwise they are requested from the server.
  Future<List<Spot>> getSpots({bool? online}) async {
    if(online == null || !online) return CacheService.getTsFromCache<Spot>(Spot.boxName, Spot.fromCache);
    // request spots from the server
    try {
      List<Spot> spots = [];
      Box box = Hive.box(Spot.boxName);
      final Response missingSpotsResponse = await netWorkLocator.dio.get('$climbingApiHost/spot');
      if (missingSpotsResponse.statusCode != 200) throw Exception("Error during request of missing spots");
      Future.forEach(missingSpotsResponse.data, (dynamic s) async {
        Spot spot = Spot.fromJson(s);
        box.put(spot.id, spot.toJson());
        spots.add(spot);
      });
      return spots;
    } catch (e) {
      ErrorService.handleConnectionErrors(e);
    }
    return [];
  }

  /// Get all spots from cache and optionally from the server by their name.
  /// If the parameter [online] is null or false the spots are searched in cache,
  /// otherwise they are requested from the server.
  Future<List<Spot>> getSpotsByName(String name, {bool? online}) async {
    List<Spot> spots = await getSpots(online: online);
    if (name.isEmpty) return spots;
    return spots.where((spot) => spot.name.contains(name)).toList();
  }

  /// Get all spots within a date range from cache and optionally from the server.
  /// If the parameter [online] is null or false the spots are searched in cache,
  /// otherwise they are requested from the server.
  Future<Spot?> getSpotIfWithinDateRange(String spotId, DateTime startDate, DateTime endDate, {bool? online}) async {
    Spot? spot = await getSpot(spotId, online: online);
    if (spot == null) return null;
    List<MultiPitchRoute> multiPitchRoutes = await multiPitchRouteService.getMultiPitchRoutesOfIds(spot.multiPitchRouteIds, online: online);
    for (MultiPitchRoute multiPitchRoute in multiPitchRoutes) {
      List<Pitch> pitches = await pitchService.getPitchesOfIds(multiPitchRoute.pitchIds, online: online);
      for (Pitch pitch in pitches){
        List<Ascent> ascents = await ascentService.getAscentsOfIds(pitch.ascentIds, online: online);
        for (Ascent ascent in ascents){
          DateTime dateOfAscent = DateTime.parse(ascent.date);
          if ((dateOfAscent.isAfter(startDate) && dateOfAscent.isBefore(endDate)) || dateOfAscent.isAtSameMomentAs(startDate) || dateOfAscent.isAtSameMomentAs(endDate)){
            return spot;
          }
        }
      }
    }
    List<SinglePitchRoute> singlePitchRoutes = await singlePitchRouteService.getSinglePitchRoutesOfIds(spot.singlePitchRouteIds, online: online);
    for (SinglePitchRoute singlePitchRoute in singlePitchRoutes) {
      List<Ascent> ascents = await ascentService.getAscentsOfIds(singlePitchRoute.ascentIds, online: online);
      for (Ascent ascent in ascents){
        DateTime dateOfAscent = DateTime.parse(ascent.date);
        if ((dateOfAscent.isAfter(startDate) &&
            dateOfAscent.isBefore(endDate)) ||
            dateOfAscent.isAtSameMomentAs(startDate) ||
            dateOfAscent.isAtSameMomentAs(endDate)) {
          return spot;
        }
      }
    }
    return null;
  }

  /// Create a spot in cache and optionally on the server.
  /// If the parameter [online] is null or false the spot is added to the cache and uploaded later at the next sync.
  /// Otherwise it is added to the cache and to the server.
  Future<Spot?> createSpot(Spot spot, {bool? online}) async {
    // add to cache
    Box spotBox = Hive.box(Spot.boxName);
    Box createSpotBox = Hive.box(CreateSpot.boxName);
    await spotBox.put(spot.id, spot.toJson());
    await createSpotBox.put(spot.id, spot.toJson());
    if (online == null || !online) return spot;
    // try to upload and update cache if successful
    Spot? uploadedSpot = await uploadSpot(spot.toJson());
    if (uploadedSpot == null) return spot;
    await spotBox.delete(spot.id);
    await createSpotBox.delete(spot.id);
    await spotBox.put(uploadedSpot.id, uploadedSpot.toJson());
    return uploadedSpot;
  }

  /// Edit a spot in cache and optionally on the server.
  /// If the parameter [online] is null or false the spot is edited only in the cache and later on the server at the next sync.
  /// Otherwise it is edited in cache and on the server immediately.
  Future<Spot?> editSpot(UpdateSpot updateSpot, {bool? online}) async {
    // add to cache
    Box spotBox = Hive.box(Spot.boxName);
    Box updateSpotBox = Hive.box(UpdateSpot.boxName);
    Spot oldSpot = Spot.fromCache(spotBox.get(updateSpot.id));
    Spot tmpSpot = updateSpot.toSpot(oldSpot);
    await spotBox.put(updateSpot.id, tmpSpot.toJson());
    await updateSpotBox.put(updateSpot.id, tmpSpot.toJson());
    if (online == null || !online) return tmpSpot;
    // try to upload and update cache if successful
    try {
      final Response response = await netWorkLocator.dio.put('$climbingApiHost/spot/${updateSpot.id}', data: updateSpot.toJson());
      if (response.statusCode != 200) throw Exception('Failed to edit spot');
      Spot spot = Spot.fromJson(response.data);
      await spotBox.put(updateSpot.id, updateSpot.toJson());
      await updateSpotBox.delete(updateSpot.id);
      return spot;
    } catch (e) {
      ErrorService.handleConnectionErrors(e);
    }
    return null;
  }

  /// Delete a spot its media, single/multi pitch routes, pitches and ascents in cache and optionally on the server.
  /// If the parameter [online] is null or false the data is deleted only from the cache and later from the server at the next sync.
  /// Otherwise it is deleted from cache and from the server immediately.
  Future<void> deleteSpot(Spot spot, {bool? online}) async {
    Box spotBox = Hive.box(Spot.boxName);
    Box deleteSpotBox = Hive.box(Spot.deleteBoxName);
    // delete spot from cache
    await spotBox.delete(spot.id);
    // add spot to deletion queue for later sync
    await deleteSpotBox.put(spot.id, spot.toJson());
    // remove from create queue (if no sync since)
    Box createSpotBox = Hive.box(Spot.createBoxName);
    await createSpotBox.delete(spot.id);
    // delete spot id from trips
    Box tripBox = Hive.box(Trip.boxName);
    for (var el in tripBox.values) {
      Trip trip = Trip.fromCache(el);
      if (trip.spotIds.contains(spot.id)){
        trip.spotIds.remove(spot.id);
        await tripBox.put(trip.id, trip.toJson());
      }
    }
    // delete media of spot locally (deleted automatically on the server when trip is deleted)
    Box mediaBox = Hive.box(Media.boxName);
    for (String mediaId in spot.mediaIds){
      await mediaBox.delete(mediaId);
    }
    // delete multi pitch routes of spot locally (deleted automatically on the server when spot is deleted)
    Box multiPitchRouteBox = Hive.box(MultiPitchRoute.boxName);
    for (String multiPitchRouteId in spot.multiPitchRouteIds){
      // delete pitches of multi pitch route locally (deleted automatically on the server when spot is deleted)
      Map multiPitchRouteMap = multiPitchRouteBox.get(multiPitchRouteId);
      MultiPitchRoute multiPitchRoute = MultiPitchRoute.fromCache(multiPitchRouteMap);
      for (String mediaId in multiPitchRoute.mediaIds){
        await mediaBox.delete(mediaId);
      }
      Box pitchBox = Hive.box(Pitch.boxName);
      for (String pitchId in multiPitchRoute.pitchIds){
        // delete ascents of pitches locally (deleted automatically on the server when spot is deleted)
        Pitch pitch = Pitch.fromCache(pitchBox.get(pitchId));
        for (String mediaId in pitch.mediaIds){
          await mediaBox.delete(mediaId);
        }
        Box ascentBox = Hive.box(Ascent.boxName);
        for (String ascentId in pitch.ascentIds){
          Ascent ascent = Ascent.fromCache(ascentBox.get(ascentId));
          for (String mediaId in ascent.mediaIds){
            await mediaBox.delete(mediaId);
          }
          await ascentBox.delete(ascentId);
        }
        await pitchBox.delete(pitchId);
      }
      await multiPitchRouteBox.delete(multiPitchRouteId);
    }
    // delete single pitch routes of spot locally (deleted automatically on the server when spot is deleted)
    Box singlePitchRouteBox = Hive.box(SinglePitchRoute.boxName);
    for (String singlePitchRouteId in spot.singlePitchRouteIds){
      // delete ascents of single pitch route locally (deleted automatically on the server when spot is deleted)
      SinglePitchRoute singlePitchRoute = SinglePitchRoute.fromCache(singlePitchRouteBox.get(singlePitchRouteId));
      for (String mediaId in singlePitchRoute.mediaIds){
        await mediaBox.delete(mediaId);
      }
      Box ascentBox = Hive.box(Ascent.boxName);
      for (String ascentId in singlePitchRoute.ascentIds){
        Ascent ascent = Ascent.fromCache(ascentBox.get(ascentId));
        for (String mediaId in ascent.mediaIds){
          await mediaBox.delete(mediaId);
        }
        await ascentBox.delete(ascentId);
      }
      await singlePitchRouteBox.delete(singlePitchRouteId);
    }
    if (online == null || !online) return;
    try {
      // delete spot
      final Response spotResponse = await netWorkLocator.dio.delete('$climbingApiHost/spot/${spot.id}');
      if (spotResponse.statusCode != 200) throw Exception('Failed to delete spot');
      await deleteSpotBox.delete(spot.id);
      MyNotifications.showPositiveNotification('Spot was deleted: ${spotResponse.data['name']}');
    } catch (e) {
      ErrorService.handleConnectionErrors(e);
    }
  }

  /// Upload a spot to the server.
  Future<Spot?> uploadSpot(Map data) async {
    try {
      final Response response = await netWorkLocator.dio.post('$climbingApiHost/spot', data: data);
      if (response.statusCode != 201) throw Exception('Failed to create spot');
      MyNotifications.showPositiveNotification('Created new spot: ${response.data['name']}');
      return Spot.fromJson(response.data);
    } catch (e) {
      if (e is DioError) {
        final response = e.response;
        if (response != null) {
          switch (response.statusCode) {
            case 409:
              MyNotifications.showNegativeNotification('This spot already exists!');
              Box createSpotBox = Hive.box(CreateSpot.boxName);
              await createSpotBox.delete(data['_id']);
              break;
            default:
              throw Exception('Failed to create spot');
          }
        }
      }
    }
    return null;
  }
}
