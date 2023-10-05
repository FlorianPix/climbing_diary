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
      // request when the multiPitchRoute was updated the last time
      final Response multiPitchRouteIdUpdatedResponse = await netWorkLocator.dio.get('$climbingApiHost/single_pitch_routeUpdated/$multiPitchRouteId');
      if (multiPitchRouteIdUpdatedResponse.statusCode != 200) throw Exception("Error during request of spot id updated");
      String serverUpdated = multiPitchRouteIdUpdatedResponse.data['updated'];
      // request the multiPitchRoute from the server if it was updated more recently than the one in the cache
      if (!box.containsKey(multiPitchRouteId) || CacheService.isStale(box.get(multiPitchRouteId), serverUpdated)) {
        final Response missingMultiPitchRouteResponse = await netWorkLocator.dio.get('$climbingApiHost/single_pitch_route/$multiPitchRouteId');
        if (missingMultiPitchRouteResponse.statusCode != 200) throw Exception("Error during request of missing spot");
        return MultiPitchRoute.fromJson(missingMultiPitchRouteResponse.data);
      } else {
        return MultiPitchRoute.fromCache(box.get(multiPitchRouteId));
      }
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
      final Response multiPitchRouteIdsUpdatedResponse = await netWorkLocator.dio.post('$climbingApiHost/single_pitch_routeUpdated/ids', data: multiPitchRouteIds);
      if (multiPitchRouteIdsUpdatedResponse.statusCode != 200) throw Exception("Error during request of multiPitchRoute ids updated");
      List<MultiPitchRoute> multiPitchRoutes = [];
      List<String> missingMultiPitchRouteIds = [];
      Box box = Hive.box(MultiPitchRoute.boxName);
      multiPitchRouteIdsUpdatedResponse.data.forEach((idWithDatetime) {
        String id = idWithDatetime['_id'];
        String serverUpdated = idWithDatetime['updated'];
        if (!box.containsKey(id) || CacheService.isStale(box.get(id), serverUpdated)) {
          missingMultiPitchRouteIds.add(id);
        } else {
          multiPitchRoutes.add(MultiPitchRoute.fromCache(box.get(id)));
        }
      });
      if (missingMultiPitchRouteIds.isEmpty) return multiPitchRoutes;
      // request missing or stale multiPitchRoutes from the server
      final Response missingMultiPitchRoutesResponse = await netWorkLocator.dio.post('$climbingApiHost/single_pitch_route/ids', data: missingMultiPitchRouteIds);
      if (missingMultiPitchRoutesResponse.statusCode != 200) throw Exception("Error during request of missing multiPitchRoutes");
      Future.forEach(missingMultiPitchRoutesResponse.data, (dynamic s) {
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
      // request when the multi-pitch-routes were updated the last time
      final Response multiPitchRouteIdsResponse = await netWorkLocator.dio.get('$climbingApiHost/multi_pitch_routeUpdated');
      if (multiPitchRouteIdsResponse.statusCode != 200) throw Exception("Error during request of multiPitchRoute ids");
      // find missing or stale (updated more recently on the server than in the cache) multi-pitch-routes
      List<MultiPitchRoute> multiPitchRoutes = [];
      List<String> missingMultiPitchRouteIds = [];
      Box box = Hive.box(MultiPitchRoute.boxName);
      multiPitchRouteIdsResponse.data.forEach((idWithDatetime) {
        String id = idWithDatetime['_id'];
        String serverUpdated = idWithDatetime['updated'];
        if (!box.containsKey(id) || CacheService.isStale(box.get(id), serverUpdated)) {
          missingMultiPitchRouteIds.add(id);
        } else {
          multiPitchRoutes.add(MultiPitchRoute.fromCache(box.get(id)));
        }
      });
      if (missingMultiPitchRouteIds.isEmpty) return multiPitchRoutes;
      // request missing or stale multi-pitch-routes from the server
      final Response missingMultiPitchRoutesResponse = await netWorkLocator.dio.post('$climbingApiHost/multi_pitch_route/ids', data: missingMultiPitchRouteIds);
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

  Future<MultiPitchRoute?> getMultiPitchRouteIfWithinDateRange(String routeId, DateTime startDate, DateTime endDate, bool online) async {
    MultiPitchRoute? multiPitchRoute = await getMultiPitchRoute(routeId, online);
    if (multiPitchRoute == null) return null;
    List<Pitch> pitches = await pitchService.getPitchesOfIds(multiPitchRoute.pitchIds, online);
    for (Pitch pitch in pitches){
      List<Ascent> ascents = await ascentService.getAscentsOfIds(pitch.ascentIds, online);
      for (Ascent ascent in ascents){
        DateTime dateOfAscent = DateTime.parse(ascent.date);
        if ((dateOfAscent.isAfter(startDate) && dateOfAscent.isBefore(endDate)) || dateOfAscent.isAtSameMomentAs(startDate) || dateOfAscent.isAtSameMomentAs(endDate)){
          return multiPitchRoute;
        }
      }
    }
    return null;
  }

  Future<MultiPitchRoute?> createMultiPitchRoute(CreateMultiPitchRoute createRoute, String spotId, bool hasConnection) async {
    CreateMultiPitchRoute route = CreateMultiPitchRoute(
      comment: (createRoute.comment != null) ? createRoute.comment! : "",
      location: createRoute.location,
      name: createRoute.name,
      rating: createRoute.rating,
    );
    if (hasConnection) {
      var data = route.toJson();
      return uploadMultiPitchRoute(spotId, data);
    } else {
      // save to cache
      Box box = Hive.box('upload_later_routes');
      Map routeJson = route.toJson();
      box.put(routeJson.hashCode, routeJson);
    }
    return null;
  }

  Future<MultiPitchRoute?> editMultiPitchRoute(UpdateMultiPitchRoute route) async {
    try {
      final Response response = await netWorkLocator.dio
          .put('$climbingApiHost/multi_pitch_route/${route.id}', data: route.toJson());
      if (response.statusCode == 200) {
        // TODO deleteRouteFromEditQueue(route.hashCode);
        return MultiPitchRoute.fromJson(response.data);
      } else {
        throw Exception('Failed to edit route');
      }
    } catch (e) {
      if (e is DioError) {
        if (e.error.toString().contains('OS Error: No address associated with hostname, errno = 7')){
          // this means we are offline so queue this route and edit later
          Box box = Hive.box('edit_later_routes');
          Map routeJson = route.toJson();
          box.put(routeJson.hashCode, routeJson);
        }
      }
    } finally {
      // TODO editRouteFromCache(route);
    }
    return null;
  }

  Future<void> deleteMultiPitchRoute(MultiPitchRoute route, String spotId) async {
    try {
      for (var id in route.mediaIds) {
        final Response mediaResponse =
        await netWorkLocator.dio.delete('$mediaApiHost/media/$id');
        if (mediaResponse.statusCode != 204) {
          throw Exception('Failed to delete medium');
        }
      }

      final Response routeResponse =
      await netWorkLocator.dio.delete('$climbingApiHost/multi_pitch_route/${route.id}/spot/$spotId');
      if (routeResponse.statusCode != 204) {
        throw Exception('Failed to delete route');
      }
      MyNotifications.showPositiveNotification('Multi pitch route was deleted: ${routeResponse.data['name']}');
      // TODO deleteRouteFromDeleteQueue(route.toJson().hashCode);
      return routeResponse.data;
    } catch (e) {
      if (e is DioError) {
        if (e.error.toString().contains('OS Error: No address associated with hostname, errno = 7')){
          // this means we are offline so queue this route and delete later
          Box box = Hive.box('delete_later_routes');
          Map routeJson = route.toJson();
          box.put(routeJson.hashCode, routeJson);
        }
      }
    } finally {
      // TODO deleteRouteFromCache(route.id);
    }
  }

  Future<MultiPitchRoute?> uploadMultiPitchRoute(String spotId, Map data) async {
    try {
      final Response response = await netWorkLocator.dio
          .post('$climbingApiHost/multi_pitch_route/spot/$spotId', data: data);
      if (response.statusCode == 201) {
        MyNotifications.showPositiveNotification('Created new multi pitch route: ${response.data['name']}');
        return MultiPitchRoute.fromJson(response.data);
      } else {
        throw Exception('Failed to create route');
      }
    } catch (e) {
      if (e is DioError) {
        final response = e.response;
        if (response != null) {
          switch (response.statusCode) {
            case 409:
              MyNotifications.showNegativeNotification('This route already exists!');
              break;
            default:
              throw Exception('Failed to create route');
          }
        }
      }
    } finally {
      // TODO deleteRouteFromUploadQueue(data.hashCode);
    }
    return null;
  }

  Future<Ascent?> getBestAscent(MultiPitchRoute route, bool online) async {
    List<Ascent> bestPitchAscents = [];
    List<Pitch> pitches = await pitchService.getPitchesOfIds(route.pitchIds, online);
    for (Pitch pitch in pitches){
      int pitchStyle = 6;
      int pitchType = 4;
      Ascent? bestPitchAscent;
      List<Ascent> ascents = await ascentService.getAscentsOfIds(pitch.ascentIds, online);
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
