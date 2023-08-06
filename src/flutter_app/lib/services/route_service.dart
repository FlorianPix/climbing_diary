import 'package:climbing_diary/interfaces/multi_pitch_route/create_multi_pitch_route.dart';
import 'package:climbing_diary/services/pitch_service.dart';
import 'package:hive/hive.dart';

import '../components/my_notifications.dart';
import '../config/environment.dart';
import '../interfaces/ascent/ascent.dart';
import '../interfaces/multi_pitch_route/multi_pitch_route.dart';
import '../interfaces/multi_pitch_route/update_multi_pitch_route.dart';
import '../interfaces/pitch/pitch.dart';
import 'package:dio/dio.dart';

import '../data/network/dio_client.dart';
import '../data/sharedprefs/shared_preference_helper.dart';
import '../interfaces/single_pitch_route/create_single_pitch_route.dart';
import '../interfaces/single_pitch_route/single_pitch_route.dart';
import '../interfaces/single_pitch_route/update_single_pitch_route.dart';
import 'ascent_service.dart';
import 'cache_service.dart';
import 'locator.dart';

class RouteService {
  final CacheService cacheService = CacheService();
  final PitchService pitchService = PitchService();
  final AscentService ascentService = AscentService();
  final netWorkLocator = getIt.get<DioClient>();
  final sharedPrefLocator = getIt.get<SharedPreferenceHelper>();
  final String climbingApiHost = Environment().config.climbingApiHost;
  final String mediaApiHost = Environment().config.mediaApiHost;

  Future<MultiPitchRoute?> getMultiPitchRoute(String routeId, bool online) async {
    try {
      Box box = Hive.box('spots');
      if (online) {
        final Response multiPitchRouteIdUpdatedResponse = await netWorkLocator.dio.get('$climbingApiHost/multi_pitch_routeUpdated/$routeId');
        if (multiPitchRouteIdUpdatedResponse.statusCode != 200) throw Exception("Error during request of spot id updated");
        String id = multiPitchRouteIdUpdatedResponse.data['_id'];
        String serverUpdated = multiPitchRouteIdUpdatedResponse.data['updated'];
        if (!box.containsKey(id) || cacheService.isStale(box.get(id), serverUpdated)) {
          final Response missingMultiPitchRouteResponse = await netWorkLocator.dio.post('$climbingApiHost/multi_pitch_route/$routeId');
          if (missingMultiPitchRouteResponse.statusCode != 200) throw Exception("Error during request of missing spot");
          return MultiPitchRoute.fromJson(missingMultiPitchRouteResponse.data);
        } else {
          return MultiPitchRoute.fromCache(box.get(id));
        }
      }
      return MultiPitchRoute.fromCache(box.get(routeId));
    } catch (e) {
      if (e is DioError) {
        if (e.error.toString().contains("OS Error: Connection refused, errno = 111")){
          MyNotifications.showNegativeNotification('Couldn\'t connect to API');
        }
      }
    }
    return null;
  }

  Future<List<MultiPitchRoute>> getMultiPitchRoutesOfIds(bool online, List<String> multiPitchRouteIds) async {
    try {
      if(online){
        final Response multiPitchRouteIdsUpdatedResponse = await netWorkLocator.dio.post('$climbingApiHost/multi_pitch_routeUpdated/ids', data: multiPitchRouteIds);
        if (multiPitchRouteIdsUpdatedResponse.statusCode != 200) {
          throw Exception("Error during request of multiPitchRoute ids updated");
        }
        List<MultiPitchRoute> multiPitchRoutes = [];
        List<String> missingMultiPitchRouteIds = [];
        Box box = Hive.box('multi_pitch_routes');
        multiPitchRouteIdsUpdatedResponse.data.forEach((idWithDatetime) {
          String id = idWithDatetime['_id'];
          String serverUpdated = idWithDatetime['updated'];
          if (!box.containsKey(id) || cacheService.isStale(box.get(id), serverUpdated)) {
            missingMultiPitchRouteIds.add(id);
          } else {
            multiPitchRoutes.add(MultiPitchRoute.fromCache(box.get(id)));
          }
        });
        if (missingMultiPitchRouteIds.isEmpty){
          return multiPitchRoutes;
        }
        final Response missingMultiPitchRoutesResponse = await netWorkLocator.dio.post('$climbingApiHost/multi_pitch_route/ids', data: missingMultiPitchRouteIds);
        if (missingMultiPitchRoutesResponse.statusCode != 200) {
          throw Exception("Error during request of missing multiPitchRoutes");
        }
        missingMultiPitchRoutesResponse.data.forEach((s) {
          MultiPitchRoute multiPitchRoute = MultiPitchRoute.fromJson(s);
          if (!box.containsKey(multiPitchRoute.id)) {
            box.put(multiPitchRoute.id, multiPitchRoute.toJson());
          }
          multiPitchRoutes.add(multiPitchRoute);
        });
        return multiPitchRoutes;
      } else {
        // offline
        List<MultiPitchRoute> multiPitchRoutes = cacheService.getTsFromCache<MultiPitchRoute>('multi_pitch_routes', MultiPitchRoute.fromCache);
        return multiPitchRoutes.where((element) => multiPitchRouteIds.contains(element.id)).toList();
      }
    } catch (e) {
      if (e is DioError) {
        if (e.error.toString().contains("OS Error: Connection refused, errno = 111")){
          MyNotifications.showNegativeNotification('Couldn\'t connect to API');
        }
      }
    }
    return [];
  }

  Future<List<MultiPitchRoute>> getMultiPitchRoutes(bool online) async {
    try {
      if(online){
        final Response multiPitchRouteIdsResponse = await netWorkLocator.dio.get('$climbingApiHost/multi_pitch_routeUpdated');
        if (multiPitchRouteIdsResponse.statusCode != 200) {
          throw Exception("Error during request of multiPitchRoute ids");
        }
        List<MultiPitchRoute> multiPitchRoutes = [];
        List<String> missingMultiPitchRouteIds = [];
        Box box = Hive.box('multi_pitch_routes');
        multiPitchRouteIdsResponse.data.forEach((idWithDatetime) {
          String id = idWithDatetime['_id'];
          String serverUpdated = idWithDatetime['updated'];
          if (!box.containsKey(id) || cacheService.isStale(box.get(id), serverUpdated)) {
            missingMultiPitchRouteIds.add(id);
          } else {
            multiPitchRoutes.add(MultiPitchRoute.fromCache(box.get(id)));
          }
        });
        if (missingMultiPitchRouteIds.isEmpty){
          return multiPitchRoutes;
        }
        final Response missingMultiPitchRoutesResponse = await netWorkLocator.dio.post('$climbingApiHost/multi_pitch_route/ids', data: missingMultiPitchRouteIds);
        if (missingMultiPitchRoutesResponse.statusCode != 200) {
          throw Exception("Error during request of missing multiPitchRoutes");
        }
        missingMultiPitchRoutesResponse.data.forEach((s) {
          MultiPitchRoute multiPitchRoute = MultiPitchRoute.fromJson(s);
          if (!box.containsKey(multiPitchRoute.id)) {
            box.put(multiPitchRoute.id, multiPitchRoute.toJson());
          }
          multiPitchRoutes.add(multiPitchRoute);
        });
        return multiPitchRoutes;
      } else {
        // offline
        return cacheService.getTsFromCache<MultiPitchRoute>('multi_pitch_routes', MultiPitchRoute.fromCache);
      }
    } catch (e) {
      if (e is DioError) {
        if (e.error.toString().contains("OS Error: Connection refused, errno = 111")){
          MyNotifications.showNegativeNotification('Couldn\'t connect to API');
        }
      }
    }
    return [];
  }

  Future<List<MultiPitchRoute>> getMultiPitchRoutesByName(String name, bool online) async {
    List<MultiPitchRoute> multiPitchRoutes = await getMultiPitchRoutes(online);
    if (name.isEmpty){
      return multiPitchRoutes;
    }
    return multiPitchRoutes.where((multiPitchRoute) => multiPitchRoute.name.contains(name)).toList();
  }

  Future<MultiPitchRoute?> getMultiPitchRouteIfWithinDateRange(String routeId, DateTime startDate, DateTime endDate, bool online) async {
    MultiPitchRoute? multiPitchRoute = await getMultiPitchRoute(routeId, online);
    if (multiPitchRoute == null) return null;
    List<Pitch> pitches = await pitchService.getPitchesOfIds(online, multiPitchRoute.pitchIds);
    for (Pitch pitch in pitches){
      List<Ascent> ascents = await ascentService.getAscentsOfIds(online, pitch.ascentIds);
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

  Future<Ascent?> getBestAscent(MultiPitchRoute route) async {
    List<Ascent> bestPitchAscents = [];
    List<Pitch> pitches = await pitchService.getPitchesOfIds(true, route.pitchIds); // TODO check if online
    for (Pitch pitch in pitches){
      int pitchStyle = 6;
      int pitchType = 4;
      Ascent? bestPitchAscent;
      List<Ascent> ascents = await ascentService.getAscentsOfIds(true, pitch.ascentIds); // TODO check if online
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

  Future<SinglePitchRoute?> createSinglePitchRoute(CreateSinglePitchRoute createRoute, String spotId, bool hasConnection) async {
    CreateSinglePitchRoute route = CreateSinglePitchRoute(
        comment: (createRoute.comment != null) ? createRoute.comment! : "",
        location: createRoute.location,
        name: createRoute.name,
        rating: createRoute.rating,
        grade: createRoute.grade,
        length: createRoute.length
    );
    if (hasConnection) {
      var data = route.toJson();
      return uploadSinglePitchRoute(spotId, data);
    } else {
      // save to cache
      Box box = Hive.box('upload_later_routes');
      Map routeJson = route.toJson();
      box.put(routeJson.hashCode, routeJson);
    }
    return null;
  }

  Future<SinglePitchRoute?> getSinglePitchRoute(String routeId, bool online) async {
    try {
      Box box = Hive.box('spots');
      if (online) {
        final Response singlePitchRouteIdUpdatedResponse = await netWorkLocator.dio.get('$climbingApiHost/single_pitch_routeUpdated/$routeId');
        if (singlePitchRouteIdUpdatedResponse.statusCode != 200) throw Exception("Error during request of spot id updated");
        String id = singlePitchRouteIdUpdatedResponse.data['_id'];
        String serverUpdated = singlePitchRouteIdUpdatedResponse.data['updated'];
        if (!box.containsKey(id) || cacheService.isStale(box.get(id), serverUpdated)) {
          final Response missingSinglePitchRouteResponse = await netWorkLocator.dio.get('$climbingApiHost/single_pitch_route/$routeId');
          if (missingSinglePitchRouteResponse.statusCode != 200) throw Exception("Error during request of missing spot");
          return SinglePitchRoute.fromJson(missingSinglePitchRouteResponse.data);
        } else {
          return SinglePitchRoute.fromCache(box.get(id));
        }
      }
      return SinglePitchRoute.fromCache(box.get(routeId));
    } catch (e) {
      if (e is DioError) {
        if (e.error.toString().contains("OS Error: Connection refused, errno = 111")){
          MyNotifications.showNegativeNotification('Couldn\'t connect to API');
        }
      }
      print(e);
    }
    return null;
  }

  Future<List<SinglePitchRoute>> getSinglePitchRoutesOfIds(bool online, List<String> singlePitchRouteIds) async {
    try {
      if(online){
        final Response singlePitchRouteIdsUpdatedResponse = await netWorkLocator.dio.post('$climbingApiHost/single_pitch_routeUpdated/ids', data: singlePitchRouteIds);
        if (singlePitchRouteIdsUpdatedResponse.statusCode != 200) {
          throw Exception("Error during request of singlePitchRoute ids updated");
        }
        List<SinglePitchRoute> singlePitchRoutes = [];
        List<String> missingSinglePitchRouteIds = [];
        Box box = Hive.box('single_pitch_routes');
        singlePitchRouteIdsUpdatedResponse.data.forEach((idWithDatetime) {
          String id = idWithDatetime['_id'];
          String serverUpdated = idWithDatetime['updated'];
          if (!box.containsKey(id) || cacheService.isStale(box.get(id), serverUpdated)) {
            missingSinglePitchRouteIds.add(id);
          } else {
            singlePitchRoutes.add(SinglePitchRoute.fromCache(box.get(id)));
          }
        });
        if (missingSinglePitchRouteIds.isEmpty){
          return singlePitchRoutes;
        }
        final Response missingSinglePitchRoutesResponse = await netWorkLocator.dio.post('$climbingApiHost/single_pitch_route/ids', data: missingSinglePitchRouteIds);
        if (missingSinglePitchRoutesResponse.statusCode != 200) {
          throw Exception("Error during request of missing singlePitchRoutes");
        }
        missingSinglePitchRoutesResponse.data.forEach((s) {
          SinglePitchRoute singlePitchRoute = SinglePitchRoute.fromJson(s);
          if (!box.containsKey(singlePitchRoute.id)) {
            box.put(singlePitchRoute.id, singlePitchRoute.toJson());
          }
          singlePitchRoutes.add(singlePitchRoute);
        });
        return singlePitchRoutes;
      } else {
        // offline
        List<SinglePitchRoute> singlePitchRoutes = cacheService.getTsFromCache<SinglePitchRoute>('single_pitch_routes', SinglePitchRoute.fromCache);
        return singlePitchRoutes.where((element) => singlePitchRouteIds.contains(element.id)).toList();
      }
    } catch (e) {
      if (e is DioError) {
        if (e.error.toString().contains("OS Error: Connection refused, errno = 111")){
          MyNotifications.showNegativeNotification('Couldn\'t connect to API');
        }
      }
      print(e);
    }
    return [];
  }

  Future<List<SinglePitchRoute>> getSinglePitchRoutes(bool online) async {
    try {
      if(online){
        final Response singlePitchRouteIdsResponse = await netWorkLocator.dio.get('$climbingApiHost/single_pitch_routeUpdated');
        if (singlePitchRouteIdsResponse.statusCode != 200) {
          throw Exception("Error during request of singlePitchRoute ids");
        }
        List<SinglePitchRoute> singlePitchRoutes = [];
        List<String> missingSinglePitchRouteIds = [];
        Box box = Hive.box('single_pitch_routes');
        singlePitchRouteIdsResponse.data.forEach((idWithDatetime) {
          String id = idWithDatetime['_id'];
          String serverUpdated = idWithDatetime['updated'];
          if (!box.containsKey(id) || cacheService.isStale(box.get(id), serverUpdated)) {
            missingSinglePitchRouteIds.add(id);
          } else {
            singlePitchRoutes.add(SinglePitchRoute.fromCache(box.get(id)));
          }
        });
        if (missingSinglePitchRouteIds.isEmpty){
          return singlePitchRoutes;
        }
        final Response missingSinglePitchRoutesResponse = await netWorkLocator.dio.post('$climbingApiHost/single_pitch_route/ids', data: missingSinglePitchRouteIds);
        if (missingSinglePitchRoutesResponse.statusCode != 200) {
          throw Exception("Error during request of missing singlePitchRoutes");
        }
        missingSinglePitchRoutesResponse.data.forEach((s) {
          SinglePitchRoute singlePitchRoute = SinglePitchRoute.fromJson(s);
          if (!box.containsKey(singlePitchRoute.id)) {
            box.put(singlePitchRoute.id, singlePitchRoute.toJson());
          }
          singlePitchRoutes.add(singlePitchRoute);
        });
        return singlePitchRoutes;
      } else {
        // offline
        return cacheService.getTsFromCache<SinglePitchRoute>('single_pitch_routes', SinglePitchRoute.fromCache);
      }
    } catch (e) {
      if (e is DioError) {
        if (e.error.toString().contains("OS Error: Connection refused, errno = 111")){
          MyNotifications.showNegativeNotification('Couldn\'t connect to API');
        }
      }
    }
    return [];
  }

  Future<List<SinglePitchRoute>> getSinglePitchRoutesByName(String name, bool online) async {
    List<SinglePitchRoute> singlePitchRoutes = await getSinglePitchRoutes(online);
    if (name.isEmpty) return singlePitchRoutes;
    return singlePitchRoutes.where((singlePitchRoute) => singlePitchRoute.name.contains(name)).toList();
  }

  Future<SinglePitchRoute?> getSinglePitchRouteIfWithinDateRange(String routeId, DateTime startDate, DateTime endDate, bool online) async {
    SinglePitchRoute? singlePitchRoute = await getSinglePitchRoute(routeId, online);
    if (singlePitchRoute == null) return null;
    List<Ascent> ascents = await ascentService.getAscentsOfIds(online, singlePitchRoute.ascentIds);
    for (Ascent ascent in ascents) {
      DateTime dateOfAscent = DateTime.parse(ascent.date);
      if ((dateOfAscent.isAfter(startDate) && dateOfAscent.isBefore(endDate)) || dateOfAscent.isAtSameMomentAs(startDate) || dateOfAscent.isAtSameMomentAs(endDate)){
        return singlePitchRoute;
      }
    }
    return null;
  }

  Future<SinglePitchRoute?> editSinglePitchRoute(UpdateSinglePitchRoute route) async {
    try {
      final Response response = await netWorkLocator.dio.put('$climbingApiHost/single_pitch_route/${route.id}', data: route.toJson());
      if (response.statusCode == 200) {
        // TODO deleteRouteFromEditQueue(route.hashCode);
        return SinglePitchRoute.fromJson(response.data);
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

  Future<void> deleteSinglePitchRoute(SinglePitchRoute route, String spotId) async {
    try {
      for (var id in route.mediaIds) {
        final Response mediaResponse =
        await netWorkLocator.dio.delete('$mediaApiHost/media/$id');
        if (mediaResponse.statusCode != 204) {
          throw Exception('Failed to delete medium');
        }
      }

      final Response routeResponse =
      await netWorkLocator.dio.delete('$climbingApiHost/single_pitch_route/${route.id}/spot/$spotId');
      if (routeResponse.statusCode != 204) {
        throw Exception('Failed to delete route');
      }
      MyNotifications.showPositiveNotification('Single pitch route was deleted: ${routeResponse.data['name']}');
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

  Future<SinglePitchRoute?> uploadSinglePitchRoute(String spotId, Map data) async {
    try {
      final Response response = await netWorkLocator.dio
          .post('$climbingApiHost/single_pitch_route/spot/$spotId', data: data);
      if (response.statusCode == 201) {
        MyNotifications.showPositiveNotification('Created new single pitch route: ${response.data['name']}');
        return SinglePitchRoute.fromJson(response.data);
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
}
