import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:climbing_diary/services/error_service.dart';
import 'package:climbing_diary/components/common/my_notifications.dart';
import 'package:climbing_diary/config/environment.dart';
import 'package:climbing_diary/interfaces/ascent/ascent.dart';
import 'package:climbing_diary/data/network/dio_client.dart';
import 'package:climbing_diary/data/sharedprefs/shared_preference_helper.dart';
import 'package:climbing_diary/interfaces/single_pitch_route/create_single_pitch_route.dart';
import 'package:climbing_diary/interfaces/single_pitch_route/single_pitch_route.dart';
import 'package:climbing_diary/interfaces/single_pitch_route/update_single_pitch_route.dart';
import 'package:climbing_diary/services/ascent_service.dart';
import 'package:climbing_diary/services/cache_service.dart';
import 'package:climbing_diary/services/locator.dart';

class SinglePitchRouteService {
  final AscentService ascentService = AscentService();
  final netWorkLocator = getIt.get<DioClient>();
  final sharedPrefLocator = getIt.get<SharedPreferenceHelper>();
  final String climbingApiHost = Environment().config.climbingApiHost;
  final String mediaApiHost = Environment().config.mediaApiHost;

  /// Get a single-pitch-route by its id from cache and optionally from the server.
  /// If the parameter [online] is null or false the single-pitch-route is searched in cache,
  /// otherwise it is requested from the server.
  Future<SinglePitchRoute?> getSinglePitchRoute(String singlePitchRouteId, {bool? online}) async {
    Box box = Hive.box(SinglePitchRoute.boxName);
    if (online == null || !online) return SinglePitchRoute.fromCache(box.get(singlePitchRouteId));
    // request singlePitchRoute from server
    try {
      // request when the singlePitchRoute was updated the last time
      final Response singlePitchRouteIdUpdatedResponse = await netWorkLocator.dio.get('$climbingApiHost/single_pitch_routeUpdated/$singlePitchRouteId');
      if (singlePitchRouteIdUpdatedResponse.statusCode != 200) throw Exception("Error during request of spot id updated");
      String serverUpdated = singlePitchRouteIdUpdatedResponse.data['updated'];
      // request the singlePitchRoute from the server if it was updated more recently than the one in the cache
      if (!box.containsKey(singlePitchRouteId) || CacheService.isStale(box.get(singlePitchRouteId), serverUpdated)) {
        final Response missingSinglePitchRouteResponse = await netWorkLocator.dio.get('$climbingApiHost/single_pitch_route/$singlePitchRouteId');
        if (missingSinglePitchRouteResponse.statusCode != 200) throw Exception("Error during request of missing spot");
        return SinglePitchRoute.fromJson(missingSinglePitchRouteResponse.data);
      } else {
        return SinglePitchRoute.fromCache(box.get(singlePitchRouteId));
      }
    } catch (e) {
      ErrorService.handleConnectionErrors(e);
    }
    return null;
  }

  /// Get single-pitch-routes with given ids from cache and optionally from the server.
  /// If the parameter [online] is null or false the single-pitch-routes are searched in cache,
  /// otherwise they are requested from the server.
  Future<List<SinglePitchRoute>> getSinglePitchRoutesOfIds(List<String> singlePitchRouteIds, {bool? online}) async {
    List<SinglePitchRoute> singlePitchRoutes = CacheService.getTsFromCache<SinglePitchRoute>(SinglePitchRoute.boxName, SinglePitchRoute.fromCache);
    if(online == null || !online) return singlePitchRoutes.where((singlePitchRoute) => singlePitchRouteIds.contains(singlePitchRoute.id)).toList();
    // request singlePitchRoutes from the server
    try {
      List<SinglePitchRoute> singlePitchRoutes = [];
      Box box = Hive.box(SinglePitchRoute.boxName);
      final Response singlePitchRoutesResponse = await netWorkLocator.dio.put('$climbingApiHost/single_pitch_route/ids', data: singlePitchRouteIds);
      if (singlePitchRoutesResponse.statusCode != 200) throw Exception("Error during request of missing singlePitchRoutes");
      Future.forEach(singlePitchRoutesResponse.data, (dynamic s) async {
        SinglePitchRoute singlePitchRoute = SinglePitchRoute.fromJson(s);
        box.put(singlePitchRoute.id, singlePitchRoute.toJson());
        singlePitchRoutes.add(singlePitchRoute);
      });
      return singlePitchRoutes;
    } catch (e) {
      ErrorService.handleConnectionErrors(e);
    }
    return [];
  }

  /// Get all single-pitch-routes from cache and optionally from the server.
  /// If the parameter [online] is null or false the single-pitch-routes are searched in cache,
  /// otherwise they are requested from the server.
  Future<List<SinglePitchRoute>> getSinglePitchRoutes({bool? online}) async {
    if(online == null || !online) return CacheService.getTsFromCache<SinglePitchRoute>(SinglePitchRoute.boxName, SinglePitchRoute.fromCache);
    // request single-pitch-routes from the server
    try {
      List<SinglePitchRoute> singlePitchRoutes = [];
      Box box = Hive.box(SinglePitchRoute.boxName);
      final Response singlePitchRoutesResponse = await netWorkLocator.dio.get('$climbingApiHost/single_pitch_route');
      if (singlePitchRoutesResponse.statusCode != 200) throw Exception("Error during request of missing singlePitchRoutes");
      Future.forEach(singlePitchRoutesResponse.data, (dynamic s) {
        SinglePitchRoute singlePitchRoute = SinglePitchRoute.fromJson(s);
        box.put(singlePitchRoute.id, singlePitchRoute.toJson());
        singlePitchRoutes.add(singlePitchRoute);
      });
      return singlePitchRoutes;
    } catch (e) {
      ErrorService.handleConnectionErrors(e);
    }
    return [];
  }

  /// Get all single-pitch-routes from cache and optionally from the server by their name.
  /// If the parameter [online] is null or false the single-pitch-routes are searched in cache,
  /// otherwise they are requested from the server.
  Future<List<SinglePitchRoute>> getSinglePitchRoutesByName(String name, {bool? online}) async {
    List<SinglePitchRoute> singlePitchRoutes = await getSinglePitchRoutes(online: online);
    if (name.isEmpty) return singlePitchRoutes;
    return singlePitchRoutes.where((singlePitchRoute) => singlePitchRoute.name.contains(name)).toList();
  }

  /// Get all single-pitch-routes within a date range from cache and optionally from the server.
  /// If the parameter [online] is null or false the single-pitch-routes are searched in cache,
  /// otherwise they are requested from the server.
  Future<SinglePitchRoute?> getSinglePitchRouteIfWithinDateRange(String routeId, DateTime startDate, DateTime endDate, {bool? online}) async {
    SinglePitchRoute? singlePitchRoute = await getSinglePitchRoute(routeId, online: online);
    if (singlePitchRoute == null) return null;
    List<Ascent> ascents = await ascentService.getAscentsOfIds(singlePitchRoute.ascentIds, online: online);
    for (Ascent ascent in ascents) {
      DateTime dateOfAscent = DateTime.parse(ascent.date);
      if ((dateOfAscent.isAfter(startDate) && dateOfAscent.isBefore(endDate)) || dateOfAscent.isAtSameMomentAs(startDate) || dateOfAscent.isAtSameMomentAs(endDate)){
        return singlePitchRoute;
      }
    }
    return null;
  }

  /// Create a single-pitch-route in cache and optionally on the server.
  /// If the parameter [online] is null or false the single-pitch-route is added to the cache and uploaded later at the next sync.
  /// Otherwise it is added to the cache and to the server.
  Future<SinglePitchRoute?> createSinglePitchRoute(CreateSinglePitchRoute createRoute, String spotId, {bool? online}) async {
    CreateSinglePitchRoute singlePitchRoute = CreateSinglePitchRoute(
      comment: createRoute.comment != null ? createRoute.comment! : "",
      location: createRoute.location,
      name: createRoute.name,
      rating: createRoute.rating,
      grade: createRoute.grade,
      length: createRoute.length
    );
    // add to cache
    // TODO save to which spot it will be added
    Box singlePitchRouteBox = Hive.box(SinglePitchRoute.boxName);
    Box createSinglePitchRouteBox = Hive.box(CreateSinglePitchRoute.boxName);
    SinglePitchRoute tmpSinglePitchRoute = singlePitchRoute.toSinglePitchRoute();
    await singlePitchRouteBox.put(singlePitchRoute.hashCode, tmpSinglePitchRoute.toJson());
    await createSinglePitchRouteBox.put(singlePitchRoute.hashCode, singlePitchRoute.toJson());
    if (online == null || !online) return tmpSinglePitchRoute;
    // try to upload and update cache if successful
    Map data = singlePitchRoute.toJson();
    SinglePitchRoute? uploadedSinglePitchRoute = await uploadSinglePitchRoute(spotId, data);
    if (uploadedSinglePitchRoute == null) return tmpSinglePitchRoute;
    await singlePitchRouteBox.delete(singlePitchRoute.hashCode);
    await createSinglePitchRouteBox.delete(singlePitchRoute.hashCode);
    await singlePitchRouteBox.put(uploadedSinglePitchRoute.id, uploadedSinglePitchRoute.toJson());
    return uploadedSinglePitchRoute;
  }

  /// Edit a single-pitch-route in cache and optionally on the server.
  /// If the parameter [online] is null or false the single-pitch-route is edited only in the cache and later on the server at the next sync.
  /// Otherwise it is edited in cache and on the server immediately.
  Future<SinglePitchRoute?> editSinglePitchRoute(UpdateSinglePitchRoute updateSinglePitchRoute, {bool? online}) async {
    // add to cache
    Box singlePitchRouteBox = Hive.box(SinglePitchRoute.boxName);
    Box updateSinglePitchRouteBox = Hive.box(UpdateSinglePitchRoute.boxName);
    SinglePitchRoute oldSinglePitchRoute = SinglePitchRoute.fromCache(singlePitchRouteBox.get(updateSinglePitchRoute.id));
    SinglePitchRoute tmpSinglePitchRoute = updateSinglePitchRoute.toSinglePitchRoute(oldSinglePitchRoute);
    await singlePitchRouteBox.put(updateSinglePitchRoute.id, tmpSinglePitchRoute.toJson());
    await updateSinglePitchRouteBox.put(updateSinglePitchRoute.id, updateSinglePitchRoute.toJson());
    if (online == null || !online) return tmpSinglePitchRoute;
    // try to upload and update cache if successful
    try {
      final Response response = await netWorkLocator.dio.put('$climbingApiHost/single_pitch_route/${updateSinglePitchRoute.id}', data: updateSinglePitchRoute.toJson());
      if (response.statusCode != 200) throw Exception('Failed to edit route');
      SinglePitchRoute singlePitchRoute = SinglePitchRoute.fromJson(response.data);
      await singlePitchRouteBox.put(updateSinglePitchRoute.id, updateSinglePitchRoute.toJson());
      await updateSinglePitchRouteBox.delete(updateSinglePitchRoute.id);
      return singlePitchRoute;
    } catch (e) {
      ErrorService.handleConnectionErrors(e);
    }
    return null;
  }

  /// Delete a single-pitch-route its media, pitch and ascents in cache and optionally on the server.
  /// Also remove its id from the associated spot. 
  /// If the parameter [online] is null or false the data is deleted only from the cache and later from the server at the next sync.
  /// Otherwise it is deleted from cache and from the server immediately.
  Future<void> deleteSinglePitchRoute(SinglePitchRoute singlePitchRoute, String spotId, {bool? online}) async {
    Box singlePitchRouteBox = Hive.box(SinglePitchRoute.boxName);
    Box deleteSinglePitchRouteBox = Hive.box(SinglePitchRoute.deleteBoxName);
    await singlePitchRouteBox.delete(singlePitchRoute.id);
    await deleteSinglePitchRouteBox.put(singlePitchRoute.id, singlePitchRoute.toJson());
    // TODO delete media from cache
    // TODO delete pitches from cache
    // TODO delete ascents from cache
    if (online == null || !online) return;
    try {
      // delete media
      for (var id in singlePitchRoute.mediaIds) {
        final Response mediaResponse = await netWorkLocator.dio.delete('$mediaApiHost/media/$id');
        if (mediaResponse.statusCode != 204) throw Exception('Failed to delete medium');
      }
      // delete single-pitch-route
      final Response routeResponse = await netWorkLocator.dio.delete('$climbingApiHost/single_pitch_route/${singlePitchRoute.id}/spot/$spotId');
      if (routeResponse.statusCode != 204) throw Exception('Failed to delete route');
      await deleteSinglePitchRouteBox.delete(singlePitchRoute.id);
      MyNotifications.showPositiveNotification('Single pitch route was deleted: ${routeResponse.data['name']}');
    } catch (e) {
      ErrorService.handleConnectionErrors(e);
    }
  }

  /// Upload a single-pitch-route to the server.
  Future<SinglePitchRoute?> uploadSinglePitchRoute(String spotId, Map data) async {
    try {
      final Response response = await netWorkLocator.dio.post('$climbingApiHost/single_pitch_route/spot/$spotId', data: data);
      if (response.statusCode != 201) throw Exception('Failed to create single pitch route');
      MyNotifications.showPositiveNotification('Created new single pitch route: ${response.data['name']}');
      return SinglePitchRoute.fromJson(response.data);
    } catch (e) {
      ErrorService.handleCreationErrors(e, 'single pitch route');
    }
    return null;
  }
}
