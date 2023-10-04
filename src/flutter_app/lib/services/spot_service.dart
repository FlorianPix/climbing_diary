import 'package:climbing_diary/services/pitch_service.dart';
import 'package:climbing_diary/services/single_pitch_route_service.dart';
import 'package:hive/hive.dart';

import 'package:climbing_diary/components/common/my_notifications.dart';
import '../config/environment.dart';
import '../interfaces/ascent/ascent.dart';
import '../interfaces/multi_pitch_route/multi_pitch_route.dart';
import '../interfaces/pitch/pitch.dart';
import '../interfaces/single_pitch_route/single_pitch_route.dart';
import '../interfaces/spot/create_spot.dart';
import 'package:dio/dio.dart';

import '../data/network/dio_client.dart';
import '../data/sharedprefs/shared_preference_helper.dart';
import '../interfaces/spot/spot.dart';
import '../interfaces/spot/update_spot.dart';
import 'ascent_service.dart';
import 'cache_service.dart';
import 'locator.dart';
import 'multi_pitch_route_service.dart';

class SpotService {
  final MultiPitchRouteService multiPitchRouteService = MultiPitchRouteService();
  final SinglePitchRouteService singlePitchRouteService = SinglePitchRouteService();
  final PitchService pitchService = PitchService();
  final AscentService ascentService = AscentService();
  final netWorkLocator = getIt.get<DioClient>();
  final sharedPrefLocator = getIt.get<SharedPreferenceHelper>();
  final String climbingApiHost = Environment().config.climbingApiHost;
  final String mediaApiHost = Environment().config.mediaApiHost;

  Future<Spot?> getSpot(String spotId, bool online) async {
    try {
      Box box = Hive.box('spots');
      if (!online) return Spot.fromCache(box.get(spotId));
      final Response spotIdUpdatedResponse = await netWorkLocator.dio.get('$climbingApiHost/spotUpdated/$spotId');
      if (spotIdUpdatedResponse.statusCode != 200) throw Exception("Error during request of spot id updated");
      String id = spotIdUpdatedResponse.data['_id'];
      String serverUpdated = spotIdUpdatedResponse.data['updated'];
      if (!box.containsKey(id) || CacheService.isStale(box.get(id), serverUpdated)) {
        final Response missingSpotResponse = await netWorkLocator.dio.post('$climbingApiHost/spot/$spotId');
        if (missingSpotResponse.statusCode != 200) throw Exception("Error during request of missing spot");
      } else {
        return Spot.fromCache(box.get(id));
      }
    } catch (e) {
      if (e is DioError) {
        if (e.error.toString().contains("OS Error: Connection refused, errno = 111")){
          MyNotifications.showNegativeNotification('Couldn\'t connect to API');
        }
      }
    }
    return null;
  }

  Future<List<Spot>> getSpotsOfIds(List<String> spotIds, bool online) async {
    try {
      if(!online) {
        List<Spot> spots = CacheService.getTsFromCache<Spot>('spots', Spot.fromCache);
        return spots.where((spot) => spotIds.contains(spot.id)).toList();
      }
      final Response spotIdsUpdatedResponse = await netWorkLocator.dio.post('$climbingApiHost/spotUpdated/ids', data: spotIds);
      if (spotIdsUpdatedResponse.statusCode != 200) throw Exception("Error during request of spot ids updated");
      List<Spot> spots = [];
      List<String> missingSpotIds = [];
      Box box = Hive.box('spots');
      spotIdsUpdatedResponse.data.forEach((idWithDatetime) {
        String id = idWithDatetime['_id'];
        String serverUpdated = idWithDatetime['updated'];
        if (!box.containsKey(id) || CacheService.isStale(box.get(id), serverUpdated)) {
          missingSpotIds.add(id);
        } else {
          spots.add(Spot.fromCache(box.get(id)));
        }
      });
      if (missingSpotIds.isEmpty) return spots;
      final Response missingSpotsResponse = await netWorkLocator.dio.post('$climbingApiHost/spot/ids', data: missingSpotIds);
      if (missingSpotsResponse.statusCode != 200) throw Exception("Error during request of missing spots");
      missingSpotsResponse.data.forEach((s) {
        Spot spot = Spot.fromJson(s);
        if (!box.containsKey(spot.id)) box.put(spot.id, spot.toJson());
        spots.add(spot);
      });
      return spots;
    } catch (e) {
      print(e);
      if (e is DioError) {
        if (e.error.toString().contains("OS Error: Connection refused, errno = 111")){
          MyNotifications.showNegativeNotification('Couldn\'t connect to API');
        }
      }
    }
    return [];
  }

  Future<List<Spot>> getSpots(bool online) async {
    try {
      if(!online) return CacheService.getTsFromCache<Spot>('spots', Spot.fromCache);
      final Response spotIdsResponse = await netWorkLocator.dio.get('$climbingApiHost/spotUpdated');
      if (spotIdsResponse.statusCode != 200) throw Exception("Error during request of spot ids");
      List<Spot> spots = [];
      List<String> missingSpotIds = [];
      Box box = Hive.box('spots');
      spotIdsResponse.data.forEach((idWithDatetime) {
        String id = idWithDatetime['_id'];
        String serverUpdated = idWithDatetime['updated'];
        if (!box.containsKey(id) || CacheService.isStale(box.get(id), serverUpdated)) {
          missingSpotIds.add(id);
        } else {
          spots.add(Spot.fromCache(box.get(id)));
        }
      });
      if (missingSpotIds.isEmpty) return spots;
      final Response missingSpotsResponse = await netWorkLocator.dio.post('$climbingApiHost/spot/ids', data: missingSpotIds);
      if (missingSpotsResponse.statusCode != 200) throw Exception("Error during request of missing spots");
      missingSpotsResponse.data.forEach((s) {
        Spot spot = Spot.fromJson(s);
        if (!box.containsKey(spot.id)) box.put(spot.id, spot.toJson());
        spots.add(spot);
      });
      return spots;
    } catch (e) {
      if (e is DioError) {
        if (e.error.toString().contains("OS Error: Connection refused, errno = 111")){
          MyNotifications.showNegativeNotification('Couldn\'t connect to API');
        }
      }
    }
    return [];
  }

  Future<List<Spot>> getSpotsByName(String name, bool online) async {
    List<Spot> spots = await getSpots(online);
    if (name.isEmpty) return spots;
    return spots.where((spot) => spot.name.contains(name)).toList();
  }

  Future<Spot?> getSpotIfWithinDateRange(String spotId, DateTime startDate, DateTime endDate, bool online) async {
    Spot? spot = await getSpot(spotId, online);
    if (spot == null) return null;
    List<MultiPitchRoute> multiPitchRoutes = await multiPitchRouteService.getMultiPitchRoutesOfIds(online, spot.multiPitchRouteIds);
    for (MultiPitchRoute multiPitchRoute in multiPitchRoutes) {
      List<Pitch> pitches = await pitchService.getPitchesOfIds(multiPitchRoute.pitchIds, online);
      for (Pitch pitch in pitches){
        List<Ascent> ascents = await ascentService.getAscentsOfIds(pitch.ascentIds, online);
        for (Ascent ascent in ascents){
          DateTime dateOfAscent = DateTime.parse(ascent.date);
          if ((dateOfAscent.isAfter(startDate) && dateOfAscent.isBefore(endDate)) || dateOfAscent.isAtSameMomentAs(startDate) || dateOfAscent.isAtSameMomentAs(endDate)){
            return spot;
          }
        }
      }
    }
    List<SinglePitchRoute> singlePitchRoutes = await singlePitchRouteService.getSinglePitchRoutesOfIds(online, spot.singlePitchRouteIds);
    for (SinglePitchRoute singlePitchRoute in singlePitchRoutes) {
      List<Ascent> ascents = await ascentService.getAscentsOfIds(singlePitchRoute.ascentIds, online);
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
    throw Exception('Failed to load spot');
  }

  Future<Spot?> createSpot(CreateSpot createSpot, bool hasConnection) async {
    CreateSpot spot = CreateSpot(
      name: createSpot.name,
      coordinates: createSpot.coordinates,
      location: createSpot.location,
      rating: createSpot.rating,
      comment: (createSpot.comment != null) ? createSpot.comment! : "",
      distanceParking: (createSpot.distanceParking != null)
        ? createSpot.distanceParking!
        : 0,
      distancePublicTransport: (createSpot.distancePublicTransport != null)
        ? createSpot.distancePublicTransport!
        : 0,
    );
    if (hasConnection) {
      var data = spot.toJson();
      return uploadSpot(data);
    } else {
      // save to cache
      Box box = Hive.box('upload_later_spots');
      Map spotJson = spot.toJson();
      box.put(spotJson.hashCode, spotJson);
    }
    return null;
  }

  Future<Spot?> editSpot(UpdateSpot spot) async {
    try {
      final Response response = await netWorkLocator.dio.put('$climbingApiHost/spot/${spot.id}', data: spot.toJson());
      if (response.statusCode == 200) {
        // TODO deleteSpotFromEditQueue(spot.hashCode);
        return Spot.fromJson(response.data);
      } else {
        throw Exception('Failed to edit spot');
      }
    } catch (e) {
      if (e is DioError) {
        if (e.error.toString().contains('OS Error: No address associated with hostname, errno = 7')){
          // this means we are offline so queue this spot and edit later
          Box box = Hive.box('edit_later_spots');
          Map spotJson = spot.toJson();
          box.put(spotJson.hashCode, spotJson);
        }
      }
    } finally {
      // TODO editSpotFromCache(spot);
    }
    return null;
  }

  Future<void> deleteSpot(Spot spot) async {
    try {
      for (var id in spot.mediaIds) {
        final Response mediaResponse =
        await netWorkLocator.dio.delete('$mediaApiHost/media/$id');
        if (mediaResponse.statusCode != 204) throw Exception('Failed to delete medium');
      }
      final Response spotResponse = await netWorkLocator.dio.delete('$climbingApiHost/spot/${spot.id}');
      if (spotResponse.statusCode != 200) throw Exception('Failed to delete spot');
      MyNotifications.showPositiveNotification('Spot was deleted: ${spotResponse.data['name']}');
      // TODO deleteSpotFromDeleteQueue(spot.toJson().hashCode);
      return spotResponse.data;
    } catch (e) {
      if (e is DioError) {
        if (e.error.toString().contains('OS Error: No address associated with hostname, errno = 7')){
          // this means we are offline so queue this spot and delete later
          Box box = Hive.box('delete_later_spots');
          Map spotJson = spot.toJson();
          box.put(spotJson.hashCode, spotJson);
        }
      }
    } finally {
      // TODO deleteSpotFromCache(spot.id);
    }
  }

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
              break;
            default:
              throw Exception('Failed to create spot');
          }
        }
      }
    } finally {
      // TODO deleteSpotFromUploadQueue(data.hashCode);
    }
    return null;
  }
}
