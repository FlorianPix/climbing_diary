import 'package:climbing_diary/interfaces/multi_pitch_route/create_multi_pitch_route.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:overlay_support/overlay_support.dart';

import '../config/environment.dart';
import '../interfaces/ascent/ascent.dart';
import '../interfaces/multi_pitch_route/multi_pitch_route.dart';
import '../interfaces/multi_pitch_route/update_multi_pitch_route.dart';
import '../interfaces/route/create_route.dart';
import 'package:dio/dio.dart';

import '../data/network/dio_client.dart';
import '../data/sharedprefs/shared_preference_helper.dart';
import '../interfaces/route/route.dart';
import '../interfaces/route/update_route.dart';
import '../interfaces/single_pitch_route/create_single_pitch_route.dart';
import '../interfaces/single_pitch_route/single_pitch_route.dart';
import '../interfaces/single_pitch_route/update_single_pitch_route.dart';
import 'cache.dart';
import 'locator.dart';

class RouteService {
  final netWorkLocator = getIt.get<DioClient>();
  final sharedPrefLocator = getIt.get<SharedPreferenceHelper>();
  final String climbingApiHost = Environment().config.climbingApiHost;
  final String mediaApiHost = Environment().config.mediaApiHost;

  Future<List<ClimbingRoute>> getRoutes() async {
    try {
      final Response response = await netWorkLocator.dio.get('$climbingApiHost/route');

      if (response.statusCode == 200) {
        // If the server did return a 200 OK response, then parse the JSON.
        List<ClimbingRoute> routes = [];
        // save to cache
        Box box = Hive.box('routes');
        response.data.forEach((s) {
          ClimbingRoute route = ClimbingRoute.fromJson(s);
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

  Future<ClimbingRoute> getRoute(String routeId) async {
    try{
      return getMultiPitchRoute(routeId);
    } catch(e) {
      return getSinglePitchRoute(routeId);
    }
  }

  Future<ClimbingRoute?> createRoute(CreateClimbingRoute createRoute, String spotId, bool hasConnection) async {
    CreateClimbingRoute route = CreateClimbingRoute(
      comment: (createRoute.comment != null) ? createRoute.comment! : "",
      location: createRoute.location,
      name: createRoute.name,
      rating: createRoute.rating,
    );
    if (hasConnection) {
      var data = route.toJson();
      return uploadRoute(spotId, data);
    } else {
      // save to cache
      Box box = Hive.box('upload_later_routes');
      Map routeJson = route.toJson();
      box.put(routeJson.hashCode, routeJson);
    }
    return null;
  }

  Future<ClimbingRoute?> editRoute(UpdateClimbingRoute route) async {
    try {
      final Response response = await netWorkLocator.dio
          .put('$climbingApiHost/route/${route.id}', data: route.toJson());
      if (response.statusCode == 200) {
        // TODO deleteRouteFromEditQueue(route.hashCode);
        return ClimbingRoute.fromJson(response.data);
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

  Future<void> deleteRoute(ClimbingRoute route, String spotId) async {
    try {
      for (var id in route.mediaIds) {
        final Response mediaResponse =
        await netWorkLocator.dio.delete('$mediaApiHost/media/$id');
        if (mediaResponse.statusCode != 204) {
          throw Exception('Failed to delete medium');
        }
      }

      final Response routeResponse =
      await netWorkLocator.dio.delete('$climbingApiHost/route/${route.id}/spot/$spotId');
      if (routeResponse.statusCode != 204) {
        throw Exception('Failed to delete route');
      }
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

  Future<ClimbingRoute?> uploadRoute(String spotId, Map data) async {
    try {
      final Response response = await netWorkLocator.dio
          .post('$climbingApiHost/route/spot/$spotId', data: data);
      if (response.statusCode == 201) {
        return ClimbingRoute.fromJson(response.data);
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

  Future<List<MultiPitchRoute>> getMultiPitchRoutes() async {
    try {
      final Response response = await netWorkLocator.dio.get('$climbingApiHost/multi_pitch_route');

      if (response.statusCode == 200) {
        // If the server did return a 200 OK response, then parse the JSON.
        List<MultiPitchRoute> routes = [];
        // save to cache
        Box box = Hive.box('routes');
        response.data.forEach((s) {
          MultiPitchRoute route = MultiPitchRoute.fromJson(s);
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

  Future<MultiPitchRoute> getMultiPitchRoute(String routeId) async {
    final Response response =
    await netWorkLocator.dio.get('$climbingApiHost/multi_pitch_route/$routeId');
    if (response.statusCode == 200) {
      return MultiPitchRoute.fromJson(response.data);
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

  Future<SinglePitchRoute?> getSinglePitchRouteIfWithinDateRange(String routeId, DateTime startDate, DateTime endDate) async {
    final Response response = await netWorkLocator.dio.get('$climbingApiHost/single_pitch_route/$routeId');
    if (response.statusCode == 200) {
      SinglePitchRoute singlePitchRoute = SinglePitchRoute.fromJson(response.data);
      bool isWithinDateRange = false;
      for (String ascentId in singlePitchRoute.ascentIds){
        final Response ascentResponse = await netWorkLocator.dio.get('$climbingApiHost/ascent/$ascentId');
        if (response.statusCode == 200){
          Ascent ascent = Ascent.fromJson(ascentResponse.data);
          DateTime dateOfAscent = DateTime.parse(ascent.date);
          if ((dateOfAscent.isAfter(startDate) && dateOfAscent.isBefore(endDate)) || dateOfAscent.isAtSameMomentAs(startDate) || dateOfAscent.isAtSameMomentAs(endDate)){
            isWithinDateRange = true;
          }
        }
      }
      return isWithinDateRange ? singlePitchRoute : null;
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
      final Response response = await netWorkLocator.dio
          .put('$climbingApiHost/single_pitch_route/${route.id}', data: route.toJson());
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
