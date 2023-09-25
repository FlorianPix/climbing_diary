import 'package:hive/hive.dart';

import '../components/my_notifications.dart';
import '../config/environment.dart';
import '../interfaces/ascent/ascent.dart';
import 'package:dio/dio.dart';

import '../data/network/dio_client.dart';
import '../data/sharedprefs/shared_preference_helper.dart';
import '../interfaces/single_pitch_route/create_single_pitch_route.dart';
import '../interfaces/single_pitch_route/single_pitch_route.dart';
import '../interfaces/single_pitch_route/update_single_pitch_route.dart';
import 'ascent_service.dart';
import 'cache_service.dart';
import 'locator.dart';

class SinglePitchRouteService {
  final AscentService ascentService = AscentService();
  final netWorkLocator = getIt.get<DioClient>();
  final sharedPrefLocator = getIt.get<SharedPreferenceHelper>();
  final String climbingApiHost = Environment().config.climbingApiHost;
  final String mediaApiHost = Environment().config.mediaApiHost;

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
      Box box = Hive.box('single_pitch_routes');
      if (online) {
        final Response singlePitchRouteIdUpdatedResponse = await netWorkLocator.dio.get('$climbingApiHost/single_pitch_routeUpdated/$routeId');
        if (singlePitchRouteIdUpdatedResponse.statusCode != 200) throw Exception("Error during request of spot id updated");
        String id = singlePitchRouteIdUpdatedResponse.data['_id'];
        String serverUpdated = singlePitchRouteIdUpdatedResponse.data['updated'];
        if (!box.containsKey(id) || CacheService.isStale(box.get(id), serverUpdated)) {
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
          if (!box.containsKey(id) || CacheService.isStale(box.get(id), serverUpdated)) {
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
        List<SinglePitchRoute> singlePitchRoutes = CacheService.getTsFromCache<SinglePitchRoute>('single_pitch_routes', SinglePitchRoute.fromCache);
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
          if (!box.containsKey(id) || CacheService.isStale(box.get(id), serverUpdated)) {
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
        return CacheService.getTsFromCache<SinglePitchRoute>('single_pitch_routes', SinglePitchRoute.fromCache);
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
