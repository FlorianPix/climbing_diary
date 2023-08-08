import 'package:hive/hive.dart';

import '../components/my_notifications.dart';
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
  final CacheService cacheService = CacheService();
  final netWorkLocator = getIt.get<DioClient>();
  final sharedPrefLocator = getIt.get<SharedPreferenceHelper>();
  final String climbingApiHost = Environment().config.climbingApiHost;
  final String mediaApiHost = Environment().config.mediaApiHost;

  Future<Trip> getTrip(String tripId) async {
    final Response response =
    await netWorkLocator.dio.get('$climbingApiHost/trip/$tripId');
    if (response.statusCode == 200) {
      return Trip.fromJson(response.data);
    } else {
      throw Exception('Failed to load trip');
    }
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
        Box box = Hive.box('trips');
        tripIdsResponse.data.forEach((idWithDatetime) {
          String id = idWithDatetime['_id'];
          String serverUpdated = idWithDatetime['updated'];
          if (!box.containsKey(id) || cacheService.isStale(box.get(id), serverUpdated)) {
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
        return cacheService.getTsFromCache<Trip>('trips', Trip.fromCache);
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
    } else {
      cacheService.getCreateQueue<Trip>("create_trips", Trip.fromCache);
      // save to cache
      // Box box = Hive.box('upload_later_trips');
      // Map tripJson = trip.toJson();
      // box.put(tripJson.hashCode, tripJson);
    }
    return null;
  }

  Future<Trip?> editTrip(UpdateTrip trip) async {
    try {
      final Response response = await netWorkLocator.dio
          .put('$climbingApiHost/trip/${trip.id}', data: trip.toJson());
      if (response.statusCode == 200) {
        // TODO deleteTripFromEditQueue(trip.hashCode);
        return Trip.fromJson(response.data);
      } else {
        throw Exception('Failed to edit trip');
      }
    } catch (e) {
      if (e is DioError) {
        if (e.error.toString().contains('OS Error: No address associated with hostname, errno = 7')){
          // this means we are offline so queue this trip and edit later
          Box box = Hive.box('edit_later_trips');
          Map tripJson = trip.toJson();
          box.put(tripJson.hashCode, tripJson);
        }
      }
    } finally {
      // TODO editTripFromCache(trip);
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
          // this means we are offline so queue this trip and delete later
          Box box = Hive.box('delete_later_trips');
          Map tripJson = trip.toJson();
          box.put(tripJson.hashCode, tripJson);
        }
      }
    } finally {
      // TODO deleteTripFromCache(trip.id);
    }
  }

  Future<Trip?> uploadTrip(Map data) async {
    try {
      final Response response = await netWorkLocator.dio
          .post('$climbingApiHost/trip', data: data);
      if (response.statusCode == 201) {
        MyNotifications.showPositiveNotification('Created new trip: ${response.data['name']}');
        return Trip.fromJson(response.data);
      } else {
        throw Exception('Failed to create trip');
      }
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
    } finally {
      // TODO deleteTripFromUploadQueue(data.hashCode);
    }
    return null;
  }
}
