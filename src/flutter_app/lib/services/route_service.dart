import 'package:climbing_diary/interfaces/multi_pitch_route/create_multi_pitch_route.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:overlay_support/overlay_support.dart';

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
import 'cache_service.dart';
import 'locator.dart';

class RouteService {
  final CacheService cacheService = CacheService();
  final netWorkLocator = getIt.get<DioClient>();
  final sharedPrefLocator = getIt.get<SharedPreferenceHelper>();
  final String climbingApiHost = Environment().config.climbingApiHost;
  final String mediaApiHost = Environment().config.mediaApiHost;

  Future<List<MultiPitchRoute>> getMultiPitchRoutes(bool online) async {
    try {
      if(online){
        final Response multiPitchRouteIdsResponse = await netWorkLocator.dio.get('$climbingApiHost/multi_pitch_route/ids');
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
          showSimpleNotification(
            const Text('Couldn\'t connect to API'),
            background: Colors.red,
          );
        }
      }
    }
    return [];
  }

  Future<MultiPitchRoute> getMultiPitchRoute(String routeId) async {
    final Response response =
    await netWorkLocator.dio.get('$climbingApiHost/multi_pitch_route/$routeId');
    if (response.statusCode == 200) {
      return MultiPitchRoute.fromJson(response.data);
    } else {
      throw Exception('Failed to load route');
    }
  }

  Future<List<MultiPitchRoute>> getMultiPitchRoutesByName(String name, bool online) async {
    List<MultiPitchRoute> multiPitchRoutes = await getMultiPitchRoutes(online);
    if (name.isEmpty){
      return multiPitchRoutes;
    }
    return multiPitchRoutes.where((multiPitchRoute) => multiPitchRoute.name.contains(name)).toList();
  }

  Future<MultiPitchRoute?> getMultiPitchRouteIfWithinDateRange(String routeId, DateTime startDate, DateTime endDate) async {
    final Response response = await netWorkLocator.dio.get('$climbingApiHost/multi_pitch_route/$routeId');
    if (response.statusCode == 200) {
      MultiPitchRoute multiPitchRoute = MultiPitchRoute.fromJson(response.data);
      for (String pitchId in multiPitchRoute.pitchIds){
        final Response pitchResponse = await netWorkLocator.dio.get('$climbingApiHost/pitch/$pitchId');
        Pitch pitch = Pitch.fromJson(pitchResponse.data);
        for (String ascentId in pitch.ascentIds){
          final Response ascentResponse = await netWorkLocator.dio.get('$climbingApiHost/ascent/$ascentId');
          Ascent ascent = Ascent.fromJson(ascentResponse.data);
          DateTime dateOfAscent = DateTime.parse(ascent.date);
          if ((dateOfAscent.isAfter(startDate) && dateOfAscent.isBefore(endDate)) || dateOfAscent.isAtSameMomentAs(startDate) || dateOfAscent.isAtSameMomentAs(endDate)){
            return multiPitchRoute;
          }
        }
      }
      return null;
    } else {
      throw Exception('Failed to load route');
    }
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
      showSimpleNotification(
        Text('Multi pitch route was deleted: ${routeResponse.data['name']}'),
        background: Colors.green,
      );
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
        showSimpleNotification(
          Text('Created new multi pitch route: ${response.data['name']}'),
          background: Colors.green,
        );
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
              showSimpleNotification(
                const Text('This route already exists!'),
                background: Colors.red,
              );
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
    for (String pitchId in route.pitchIds){
      final Response pitchResponse = await netWorkLocator.dio.get('$climbingApiHost/pitch/$pitchId');
      if (pitchResponse.statusCode == 200) {
        Pitch pitch = Pitch.fromJson(pitchResponse.data);
        int pitchStyle = 6;
        int pitchType = 4;
        Ascent? bestPitchAscent;
        for (String ascentId in pitch.ascentIds) {
          final Response ascentResponse = await netWorkLocator.dio.get('$climbingApiHost/ascent/$ascentId');
          if (ascentResponse.statusCode == 200) {
            Ascent ascent = Ascent.fromJson(ascentResponse.data);
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
        }
        if (bestPitchAscent == null){
          return null;
        } else {
          bestPitchAscents.add(bestPitchAscent);
        }
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

  Future<List<SinglePitchRoute>> getSinglePitchRoutes() async {
    try {
      final Response response = await netWorkLocator.dio.get('$climbingApiHost/single_pitch_route');

      if (response.statusCode == 200) {
        // If the server did return a 200 OK response, then parse the JSON.
        List<SinglePitchRoute> routes = [];
        // save to cache
        Box box = Hive.box('routes');
        response.data.forEach((s) {
          SinglePitchRoute route = SinglePitchRoute.fromJson(s);
          if (!box.containsKey(route.id)) {
            box.put(route.id, route.toJson());
          }
          routes.add(route);
        });
        return routes;
      }
    } catch (e) {
      if (e is DioError) {
        if (e.error.toString().contains("OS Error: Connection refused, errno = 111")){
          showSimpleNotification(
            const Text('Couldn\'t connect to API'),
            background: Colors.red,
          );
        }
      } else {
        print(e);
      }
    }
    return [];
  }

  Future<SinglePitchRoute> getSinglePitchRoute(String routeId) async {
    final Response response =
    await netWorkLocator.dio.get('$climbingApiHost/single_pitch_route/$routeId');
    if (response.statusCode == 200) {
      return SinglePitchRoute.fromJson(response.data);
    } else {
      throw Exception('Failed to load route');
    }
  }

  Future<List<SinglePitchRoute>> getSinglePitchRoutesByName(String name) async {
    final Response response = await netWorkLocator.dio.get('$climbingApiHost/single_pitch_route');
    if (response.statusCode == 200) {
      List<SinglePitchRoute> routes = [];
      response.data.forEach((r) {
        SinglePitchRoute route = SinglePitchRoute.fromJson(r);
        if (route.name.contains(name)) {
          routes.add(route);
        }
      });
      return routes;
    } else {
      throw Exception('Failed to load route');
    }
  }

  Future<SinglePitchRoute?> getSinglePitchRouteIfWithinDateRange(String routeId, DateTime startDate, DateTime endDate) async {
    final Response response = await netWorkLocator.dio.get('$climbingApiHost/single_pitch_route/$routeId');
    if (response.statusCode == 200) {
      SinglePitchRoute singlePitchRoute = SinglePitchRoute.fromJson(response.data);
      for (String ascentId in singlePitchRoute.ascentIds){
        final Response ascentResponse = await netWorkLocator.dio.get('$climbingApiHost/ascent/$ascentId');
        if (response.statusCode == 200){
          Ascent ascent = Ascent.fromJson(ascentResponse.data);
          DateTime dateOfAscent = DateTime.parse(ascent.date);
          if ((dateOfAscent.isAfter(startDate) && dateOfAscent.isBefore(endDate)) || dateOfAscent.isAtSameMomentAs(startDate) || dateOfAscent.isAtSameMomentAs(endDate)){
            return singlePitchRoute;
          }
        }
      }
      return null;
    } else {
      throw Exception('Failed to load route');
    }
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
      showSimpleNotification(
        Text('Single pitch route was deleted: ${routeResponse.data['name']}'),
        background: Colors.green,
      );
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
        showSimpleNotification(
          Text('Created new single pitch route: ${response.data['name']}'),
          background: Colors.green,
        );
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
              showSimpleNotification(
                const Text('This route already exists!'),
                background: Colors.red,
              );
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
