import 'package:hive/hive.dart';

import 'package:climbing_diary/components/common/my_notifications.dart';
import '../config/environment.dart';
import '../interfaces/trip/create_trip.dart';
import 'package:dio/dio.dart';

import '../data/network/dio_client.dart';
import '../data/sharedprefs/shared_preference_helper.dart';
import '../interfaces/trip/trip.dart';
import '../interfaces/trip/update_trip.dart';
import 'cache_service.dart';
import 'locator.dart';

class TripService {
  final netWorkLocator = getIt.get<DioClient>();
  final sharedPrefLocator = getIt.get<SharedPreferenceHelper>();
  final String climbingApiHost = Environment().config.climbingApiHost;
  final String mediaApiHost = Environment().config.mediaApiHost;

  Future<Trip?> getTrip(String tripId, bool online) async {
    try {
      Box box = Hive.box(Trip.boxName);
      if (!online) return Trip.fromCache(box.get(tripId));
      final Response tripIdUpdatedResponse = await netWorkLocator.dio.get('$climbingApiHost/tripUpdated/$tripId');
      if (tripIdUpdatedResponse.statusCode != 200) throw Exception("Error during request of trip id updated");
      String id = tripIdUpdatedResponse.data['_id'];
      String serverUpdated = tripIdUpdatedResponse.data['updated'];
      if (!box.containsKey(id) || CacheService.isStale(box.get(id), serverUpdated)) {
        final Response missingTripResponse = await netWorkLocator.dio.post('$climbingApiHost/trip/$tripId');
        if (missingTripResponse.statusCode != 200) throw Exception("Error during request of missing trip");
      } else {
        return Trip.fromCache(box.get(id));
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

  Future<List<Trip>> getTrips(bool online) async {
    try {
      if(online){
        final Response tripIdsResponse = await netWorkLocator.dio.get('$climbingApiHost/tripUpdated');
        if (tripIdsResponse.statusCode != 200) {
          throw Exception("Error during request of trip ids");
        }
        List<Trip> trips = [];
        List<String> missingTripIds = [];
        Box box = Hive.box(Trip.boxName);
        tripIdsResponse.data.forEach((idWithDatetime) {
          String id = idWithDatetime['_id'];
          String serverUpdated = idWithDatetime['updated'];
          if (!box.containsKey(id) || CacheService.isStale(box.get(id), serverUpdated)) {
            missingTripIds.add(id);
          } else {
            trips.add(Trip.fromCache(box.get(id)));
          }
        });
        if (missingTripIds.isEmpty){
          return trips;
        }
        final Response missingTripsResponse = await netWorkLocator.dio.post('$climbingApiHost/trip/ids', data: missingTripIds);
        if (missingTripsResponse.statusCode != 200) {
          throw Exception("Error during request of missing trips");
        }
        missingTripsResponse.data.forEach((s) {
          Trip trip = Trip.fromJson(s);
          if (!box.containsKey(trip.id)) {
            box.put(trip.id, trip.toJson());
          }
          trips.add(trip);
        });
        return trips;
      } else {
        // offline
        return CacheService.getTsFromCache<Trip>('trips', Trip.fromCache);
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

  Future<Trip?> createTrip(CreateTrip createTrip, bool online) async {
    CreateTrip trip = CreateTrip(
      comment: (createTrip.comment != null) ? createTrip.comment! : "",
      endDate: createTrip.endDate,
      name: createTrip.name,
      rating: createTrip.rating,
      startDate: createTrip.startDate,
    );
    if (online) {
      var data = trip.toJson();
      return uploadTrip(data);
    }
    Box box = Hive.box(CreateTrip.boxName);
    Map tripJson = trip.toJson();
    if (!box.containsKey(trip.hashCode)) box.put(trip.hashCode, tripJson);
    return null;
  }

  Future<Trip?> editTrip(UpdateTrip trip, bool online) async {
    try {
      if (online) {
        final Response response = await netWorkLocator.dio.put('$climbingApiHost/trip/${trip.id}', data: trip.toJson());
        if (response.statusCode != 200) throw Exception('Failed to edit trip');
        return Trip.fromJson(response.data);
      }
      Box box = Hive.box(UpdateTrip.boxName);
      Map tripJson = trip.toJson();
      if (!box.containsKey(trip.hashCode)) box.put(trip.hashCode, tripJson);
    } catch (e) {
      if (e is DioError) {
        if (e.error.toString().contains('OS Error: No address associated with hostname, errno = 7')){
          // offline
        }
      }
    }
    return null;
  }

  Future<void> deleteTrip(Trip trip) async {
    try {
      for (var id in trip.mediaIds) {
        final Response mediaResponse =
        await netWorkLocator.dio.delete('$mediaApiHost/media/$id');
        if (mediaResponse.statusCode != 204) {
          throw Exception('Failed to delete medium');
        }
      }

      final Response tripResponse =
      await netWorkLocator.dio.delete('$climbingApiHost/trip/${trip.id}');
      if (tripResponse.statusCode != 200) {
        throw Exception('Failed to delete trip');
      }
      MyNotifications.showPositiveNotification('Trip was deleted: ${tripResponse.data['name']}');
      // TODO deleteTripFromDeleteQueue(trip.toJson().hashCode);
      return tripResponse.data;
    } catch (e) {
      if (e is DioError) {
        if (e.error.toString().contains('OS Error: No address associated with hostname, errno = 7')){
          // offline
        }
      }
    } finally {
      // TODO deleteTripFromCache(trip.id);
    }
  }

  Future<Trip?> uploadTrip(Map data) async {
    try {
      final Response response = await netWorkLocator.dio.post('$climbingApiHost/trip', data: data);
      if (response.statusCode != 201) throw Exception('Failed to create trip');
      MyNotifications.showPositiveNotification('Created new trip: ${response.data['name']}');
      return Trip.fromJson(response.data);
    } catch (e) {
      if (e is DioError) {
        final response = e.response;
        if (response != null) {
          switch (response.statusCode) {
            case 409:
              MyNotifications.showNegativeNotification('This trip already exists!');
              break;
            default:
              throw Exception('Failed to create trip');
          }
        }
      }
    }
    return null;
  }
}
