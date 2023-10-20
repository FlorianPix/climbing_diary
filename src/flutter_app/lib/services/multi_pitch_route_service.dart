import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:climbing_diary/interfaces/multi_pitch_route/create_multi_pitch_route.dart';
import 'package:climbing_diary/services/error_service.dart';
import 'package:climbing_diary/services/pitch_service.dart';
import 'package:climbing_diary/components/common/my_notifications.dart';
import 'package:climbing_diary/config/environment.dart';
import 'package:climbing_diary/interfaces/ascent/ascent.dart';
import 'package:climbing_diary/interfaces/multi_pitch_route/multi_pitch_route.dart';
import 'package:climbing_diary/interfaces/multi_pitch_route/update_multi_pitch_route.dart';
import 'package:climbing_diary/interfaces/pitch/pitch.dart';
import 'package:climbing_diary/data/network/dio_client.dart';
import 'package:climbing_diary/data/sharedprefs/shared_preference_helper.dart';
import 'package:climbing_diary/services/ascent_service.dart';
import 'package:climbing_diary/services/cache_service.dart';
import 'package:climbing_diary/services/locator.dart';

class MultiPitchRouteService {
  final PitchService pitchService = PitchService();
  final AscentService ascentService = AscentService();
  final netWorkLocator = getIt.get<DioClient>();
  final sharedPrefLocator = getIt.get<SharedPreferenceHelper>();
  final String climbingApiHost = Environment().config.climbingApiHost;
  final String mediaApiHost = Environment().config.mediaApiHost;

  /// Get a multi-pitch-route by its id from cache and optionally from the server.
  /// If the parameter [online] is null or false the multi-pitch-route is searched in cache,
  /// otherwise it is requested from the server.
  Future<MultiPitchRoute?> getMultiPitchRoute(String multiPitchRouteId, {bool? online}) async {
    Box box = Hive.box(MultiPitchRoute.boxName);
    if (online == null || !online) return MultiPitchRoute.fromCache(box.get(multiPitchRouteId));
    // request multiPitchRoute from server
    try {
      final Response multiPitchRouteResponse = await netWorkLocator.dio.get('$climbingApiHost/single_pitch_route/$multiPitchRouteId');
      if (multiPitchRouteResponse.statusCode != 200) throw Exception("Error during request of multi pitch route");
      return MultiPitchRoute.fromJson(multiPitchRouteResponse.data);
    } catch (e) {
      ErrorService.handleConnectionErrors(e);
    }
    return null;
  }

  /// Get multi-pitch-routes with given ids from cache and optionally from the server.
  /// If the parameter [online] is null or false the multi-pitch-routes are searched in cache,
  /// otherwise they are requested from the server.
  Future<List<MultiPitchRoute>> getMultiPitchRoutesOfIds(List<String> multiPitchRouteIds, {bool? online}) async {
    List<MultiPitchRoute> multiPitchRoutes = CacheService.getTsFromCache<MultiPitchRoute>(MultiPitchRoute.boxName, MultiPitchRoute.fromCache);
    if(online == null || !online) return multiPitchRoutes.where((multiPitchRoute) => multiPitchRouteIds.contains(multiPitchRoute.id)).toList();
    // request multiPitchRoutes from the server
    try {
      List<MultiPitchRoute> multiPitchRoutes = [];
      Box box = Hive.box(MultiPitchRoute.boxName);
      final Response multiPitchRoutesResponse = await netWorkLocator.dio.post('$climbingApiHost/multi_pitch_route/ids', data: multiPitchRouteIds);
      if (multiPitchRoutesResponse.statusCode != 200) throw Exception("Error during request of multi pitch routes");
      Future.forEach(multiPitchRoutesResponse.data, (dynamic s) {
        MultiPitchRoute multiPitchRoute = MultiPitchRoute.fromJson(s);
        box.put(multiPitchRoute.id, multiPitchRoute.toJson());
        multiPitchRoutes.add(multiPitchRoute);
      });
      return multiPitchRoutes;
    } catch (e) {
      ErrorService.handleConnectionErrors(e);
    }
    return [];
  }

  /// Get all multi-pitch-routes from cache and optionally from the server.
  /// If the parameter [online] is null or false the multi-pitch-routes are searched in cache,
  /// otherwise they are requested from the server.
  Future<List<MultiPitchRoute>> getMultiPitchRoutes({bool? online}) async {
    if(online == null || !online) return CacheService.getTsFromCache<MultiPitchRoute>(MultiPitchRoute.boxName, MultiPitchRoute.fromCache);
    // request multi-pitch-routes from the server
    try {
      List<MultiPitchRoute> multiPitchRoutes = [];
      Box box = Hive.box(MultiPitchRoute.boxName);
      final Response missingMultiPitchRoutesResponse = await netWorkLocator.dio.get('$climbingApiHost/multi_pitch_route');
      if (missingMultiPitchRoutesResponse.statusCode != 200) throw Exception("Error during request of missing multiPitchRoutes");
      Future.forEach(missingMultiPitchRoutesResponse.data, (dynamic s) async {
        MultiPitchRoute multiPitchRoute = MultiPitchRoute.fromJson(s);
        box.put(multiPitchRoute.id, multiPitchRoute.toJson());
        multiPitchRoutes.add(multiPitchRoute);
      });
      return multiPitchRoutes;
    } catch (e) {
      ErrorService.handleConnectionErrors(e);
    }
    return [];
  }

  /// Get all multi-pitch-routes from cache and optionally from the server by their name.
  /// If the parameter [online] is null or false the multi-pitch-routes are searched in cache,
  /// otherwise they are requested from the server.
  Future<List<MultiPitchRoute>> getMultiPitchRoutesByName(String name, {bool? online}) async {
    List<MultiPitchRoute> multiPitchRoutes = await getMultiPitchRoutes(online: online);
    if (name.isEmpty) return multiPitchRoutes;
    return multiPitchRoutes.where((multiPitchRoute) => multiPitchRoute.name.contains(name)).toList();
  }

  /// Get all multi-pitch-routes within a date range from cache and optionally from the server.
  /// If the parameter [online] is null or false the multi-pitch-routes are searched in cache,
  /// otherwise they are requested from the server.
  Future<MultiPitchRoute?> getMultiPitchRouteIfWithinDateRange(String routeId, DateTime startDate, DateTime endDate, {bool? online}) async {
    MultiPitchRoute? multiPitchRoute = await getMultiPitchRoute(routeId, online: online);
    if (multiPitchRoute == null) return null;
    List<Pitch> pitches = await pitchService.getPitchesOfIds(multiPitchRoute.pitchIds, online: online);
    for (Pitch pitch in pitches){
      List<Ascent> ascents = await ascentService.getAscentsOfIds(pitch.ascentIds, online: online);
      for (Ascent ascent in ascents){
        DateTime dateOfAscent = DateTime.parse(ascent.date);
        if ((dateOfAscent.isAfter(startDate) && dateOfAscent.isBefore(endDate)) || dateOfAscent.isAtSameMomentAs(startDate) || dateOfAscent.isAtSameMomentAs(endDate)){
          return multiPitchRoute;
        }
      }
    }
    return null;
  }

  /// Create a multi-pitch-route in cache and optionally on the server.
  /// If the parameter [online] is null or false the multi-pitch-route is added to the cache and uploaded later at the next sync.
  /// Otherwise it is added to the cache and to the server.
  Future<MultiPitchRoute?> createMultiPitchRoute(CreateMultiPitchRoute createRoute, String spotId, {bool? online}) async {
    CreateMultiPitchRoute multiPitchRoute = CreateMultiPitchRoute(
      comment: createRoute.comment != null ? createRoute.comment! : "",
      location: createRoute.location,
      name: createRoute.name,
      rating: createRoute.rating,
    );
    // add to cache
    // TODO save to which spot it will be added
    Box multiPitchRouteBox = Hive.box(MultiPitchRoute.boxName);
    Box createMultiPitchRouteBox = Hive.box(CreateMultiPitchRoute.boxName);
    MultiPitchRoute tmpMultiPitchRoute = multiPitchRoute.toMultiPitchRoute();
    await multiPitchRouteBox.put(multiPitchRoute.hashCode, tmpMultiPitchRoute.toJson());
    await createMultiPitchRouteBox.put(multiPitchRoute.hashCode, multiPitchRoute.toJson());
    if (online == null || !online) return tmpMultiPitchRoute;
    // try to upload and update cache if successful
    Map data = multiPitchRoute.toJson();
    MultiPitchRoute? uploadedMultiPitchRoute = await uploadMultiPitchRoute(spotId, data);
    if (uploadedMultiPitchRoute == null) return tmpMultiPitchRoute;
    await multiPitchRouteBox.delete(multiPitchRoute.hashCode);
    await createMultiPitchRouteBox.delete(multiPitchRoute.hashCode);
    await multiPitchRouteBox.put(uploadedMultiPitchRoute.id, uploadedMultiPitchRoute.toJson());
    return uploadedMultiPitchRoute;
  }

  /// Edit a multi-pitch-route in cache and optionally on the server.
  /// If the parameter [online] is null or false the multi-pitch-route is edited only in the cache and later on the server at the next sync.
  /// Otherwise it is edited in cache and on the server immediately.
  Future<MultiPitchRoute?> editMultiPitchRoute(UpdateMultiPitchRoute updateMultiPitchRoute, {bool? online}) async {
    // add to cache
    Box multiPitchRouteBox = Hive.box(MultiPitchRoute.boxName);
    Box updateMultiPitchRouteBox = Hive.box(UpdateMultiPitchRoute.boxName);
    MultiPitchRoute oldMultiPitchRoute = MultiPitchRoute.fromCache(multiPitchRouteBox.get(updateMultiPitchRoute.id));
    MultiPitchRoute tmpMultiPitchRoute = updateMultiPitchRoute.toMultiPitchRoute(oldMultiPitchRoute);
    await multiPitchRouteBox.put(updateMultiPitchRoute.id, tmpMultiPitchRoute.toJson());
    await updateMultiPitchRouteBox.put(updateMultiPitchRoute.id, updateMultiPitchRoute.toJson());
    if (online == null || !online) return tmpMultiPitchRoute;
    // try to upload and update cache if successful
    try {
      final Response response = await netWorkLocator.dio.put('$climbingApiHost/multi_pitch_route/${updateMultiPitchRoute.id}', data: updateMultiPitchRoute.toJson());
      if (response.statusCode != 200) throw Exception('Failed to edit route');
      MultiPitchRoute multiPitchRoute = MultiPitchRoute.fromJson(response.data);
      await multiPitchRouteBox.put(updateMultiPitchRoute.id, updateMultiPitchRoute.toJson());
      await updateMultiPitchRouteBox.delete(updateMultiPitchRoute.id);
      return multiPitchRoute;
    } catch (e) {
      ErrorService.handleConnectionErrors(e);
    }
    return null;
  }

  /// Delete a multi-pitch-route its media, pitches and ascents in cache and optionally on the server.
  /// Also remove its id from the associated spot. 
  /// If the parameter [online] is null or false the data is deleted only from the cache and later from the server at the next sync.
  /// Otherwise it is deleted from cache and from the server immediately.
  Future<void> deleteMultiPitchRoute(MultiPitchRoute multiPitchRoute, String spotId, {bool? online}) async {
    Box multiPitchRouteBox = Hive.box(MultiPitchRoute.boxName);
    Box deleteMultiPitchRouteBox = Hive.box(MultiPitchRoute.deleteBoxName);
    await multiPitchRouteBox.delete(multiPitchRoute.id);
    await deleteMultiPitchRouteBox.put(multiPitchRoute.id, multiPitchRoute.toJson());
    // TODO delete media from cache
    // TODO delete pitch from cache
    // TODO delete ascents from cache
    if (online == null || !online) return;
    try {
      // delete media
      for (var id in multiPitchRoute.mediaIds) {
        final Response mediaResponse = await netWorkLocator.dio.delete('$mediaApiHost/media/$id');
        if (mediaResponse.statusCode != 204) throw Exception('Failed to delete medium');
      }
      // delete multi-pitch-route
      final Response routeResponse = await netWorkLocator.dio.delete('$climbingApiHost/multi_pitch_route/${multiPitchRoute.id}/spot/$spotId');
      if (routeResponse.statusCode != 204) throw Exception('Failed to delete route');
      await deleteMultiPitchRouteBox.delete(multiPitchRoute.id);
      MyNotifications.showPositiveNotification('Multi pitch route was deleted: ${routeResponse.data['name']}');
    } catch (e) {
      ErrorService.handleConnectionErrors(e);
    }
  }

  /// Upload a multi-pitch-route to the server.
  Future<MultiPitchRoute?> uploadMultiPitchRoute(String spotId, Map data, {bool? online}) async {
    try {
      final Response response = await netWorkLocator.dio.post('$climbingApiHost/multi_pitch_route/spot/$spotId', data: data);
      if (response.statusCode != 201) throw Exception('Failed to create multi pitch route');
      MyNotifications.showPositiveNotification('Created new multi pitch route: ${response.data['name']}');
      return MultiPitchRoute.fromJson(response.data);
    } catch (e) {
      ErrorService.handleCreationErrors(e, 'multi pitch route');
    }
    return null;
  }

  /// Get the best complete ascent of this multi pitch route,
  /// i.e. for each pitch get the best ascent and return the result of the worst pitch
  Future<Ascent?> getBestAscent(MultiPitchRoute route, {bool? online}) async {
    List<Ascent> bestPitchAscents = [];
    List<Pitch> pitches = await pitchService.getPitchesOfIds(route.pitchIds, online: online);
    for (Pitch pitch in pitches){
      int pitchStyle = 6;
      int pitchType = 4;
      Ascent? bestPitchAscent;
      List<Ascent> ascents = await ascentService.getAscentsOfIds(pitch.ascentIds, online: online);
      for (Ascent ascent in ascents) {
        if (ascent.style < pitchStyle){
          bestPitchAscent = ascent;
          pitchStyle = bestPitchAscent.style;
          pitchType = bestPitchAscent.type;
        }
        if (ascent.style == pitchStyle && ascent.type < pitchType){
          bestPitchAscent = ascent;
          pitchStyle = bestPitchAscent.style;
          pitchType = bestPitchAscent.type;
        }
      }
      if (bestPitchAscent == null){
        return null;
      } else {
        bestPitchAscents.add(bestPitchAscent);
      }
    }
    int routeStyle = 0;
    int routeType = 0;
    Ascent? bestRouteAscent;
    for (Ascent ascent in bestPitchAscents){
      if (ascent.style >= routeStyle){
        bestRouteAscent = ascent;
        routeStyle = bestRouteAscent.style;
        routeType = bestRouteAscent.type;
      }
      if (ascent.style == routeStyle && ascent.type >= routeType){
        bestRouteAscent = ascent;
        routeStyle = bestRouteAscent.style;
        routeType = bestRouteAscent.type;
      }
    }
    return bestRouteAscent;
  }
}
