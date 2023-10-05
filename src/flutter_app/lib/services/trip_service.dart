import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:climbing_diary/components/common/my_notifications.dart';
import 'package:climbing_diary/config/environment.dart';
import 'package:climbing_diary/interfaces/trip/create_trip.dart';
import 'package:climbing_diary/data/network/dio_client.dart';
import 'package:climbing_diary/data/sharedprefs/shared_preference_helper.dart';
import 'package:climbing_diary/interfaces/trip/trip.dart';
import 'package:climbing_diary/interfaces/trip/update_trip.dart';
import 'package:climbing_diary/services/cache_service.dart';
import 'package:climbing_diary/services/locator.dart';

class TripService {
  final netWorkLocator = getIt.get<DioClient>();
  final sharedPrefLocator = getIt.get<SharedPreferenceHelper>();
  final String climbingApiHost = Environment().config.climbingApiHost;
  final String mediaApiHost = Environment().config.mediaApiHost;

  /// Get a single trip by its id from cache and optionally from the server.
  /// If the parameter [online] is null or false the trip is searched in cache,
  /// otherwise it is requested from the server.
  Future<Trip?> getTrip(String tripId, {bool? online}) async {
    Box box = Hive.box(Trip.boxName);
    if (online == null || !online) return Trip.fromCache(box.get(tripId));
    // request trip from server
    try {
      // request when the trip was updated the last time
      final Response tripIdUpdatedResponse = await netWorkLocator.dio.get('$climbingApiHost/tripUpdated/$tripId');
      if (tripIdUpdatedResponse.statusCode != 200) throw Exception("Error during request of trip id updated");
      String serverUpdated = tripIdUpdatedResponse.data['updated'];
      // request the trip from the server if it was updated more recently than the one in the cache
      if (!box.containsKey(tripId) || CacheService.isStale(box.get(tripId), serverUpdated)) {
        final Response missingTripResponse = await netWorkLocator.dio.post('$climbingApiHost/trip/$tripId');
        if (missingTripResponse.statusCode != 200) throw Exception("Error during request of missing trip");
      } else {
        return Trip.fromCache(box.get(tripId));
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

  /// Get all trips from cache and optionally from the server.
  /// If the parameter [online] is null or false the trips are searched in cache,
  /// otherwise they are requested from the server.
  Future<List<Trip>> getTrips({bool? online}) async {
    Box box = Hive.box(Trip.boxName);
    if(online == null || !online) return CacheService.getTsFromCache<Trip>('trips', Trip.fromCache);
    // request trips from server
    try {
      // request when the trips were updated the last time
      final Response tripIdsResponse = await netWorkLocator.dio.get('$climbingApiHost/tripUpdated');
      if (tripIdsResponse.statusCode != 200) throw Exception("Error during request of trip ids");
      // find missing or stale (updated more recently on the server than in the cache) trips
      List<Trip> trips = [];
      List<String> missingTripIds = [];
      tripIdsResponse.data.forEach((idWithDatetime) {
        String id = idWithDatetime['_id'];
        String serverUpdated = idWithDatetime['updated'];
        if (!box.containsKey(id) || CacheService.isStale(box.get(id), serverUpdated)) {
          missingTripIds.add(id);
        } else {
          trips.add(Trip.fromCache(box.get(id)));
        }
      });
      if (missingTripIds.isEmpty) return trips;
      // request missing or stale trips from the server
      final Response missingTripsResponse = await netWorkLocator.dio.post('$climbingApiHost/trip/ids', data: missingTripIds);
      if (missingTripsResponse.statusCode != 200) throw Exception("Error during request of missing trips");
      Future.forEach(missingTripsResponse.data, (dynamic s) async {
        Trip trip = Trip.fromJson(s);
        await box.put(trip.id, trip.toJson());
        trips.add(trip);
      });
      return trips;
    } catch (e) {
      if (e is DioError) {
        if (e.error.toString().contains("OS Error: Connection refused, errno = 111")){
          MyNotifications.showNegativeNotification('Couldn\'t connect to API');
        }
      }
    }
    return [];
  }

  /// Create a trip in cache and optionally on the server.
  ///  If the parameter [online] is null or false the trips are added to the cache and uploaded later at the next sync.
  /// Otherwise they are added to the cache and to the server.
  Future<Trip> createTrip(CreateTrip createTrip, {bool? online}) async {
    // sanitise createTrip
    CreateTrip trip = CreateTrip(
      comment: (createTrip.comment != null) ? createTrip.comment! : "",
      endDate: createTrip.endDate,
      name: createTrip.name,
      rating: createTrip.rating,
      startDate: createTrip.startDate,
    );
    // add to cache
    Box tripBox = Hive.box(Trip.boxName);
    Box createTripBox = Hive.box(CreateTrip.boxName);
    Trip tmpTrip = trip.toTrip();
    await tripBox.put(trip.hashCode, tmpTrip.toJson());
    await createTripBox.put(trip.hashCode, trip.toJson());
    if (online == null || !online) return tmpTrip;
    // try to upload and update cache if successful
    Map data = trip.toJson();
    Trip? uploadedTrip = await uploadTrip(data);
    if (uploadedTrip == null) return tmpTrip;
    await tripBox.delete(trip.hashCode);
    await createTripBox.delete(trip.hashCode);
    await tripBox.put(uploadedTrip.id, uploadedTrip.toJson());
    return uploadedTrip;
  }

  /// Edit a trip in cache and optionally on the server.
  /// If the parameter [online] is null or false the trips are edited only in the cache and later on the server at the next sync.
  /// Otherwise they are edited in cache and on the server immediately.
  Future<Trip> editTrip(UpdateTrip updateTrip, {bool? online}) async {
    // add to cache
    Box tripBox = Hive.box(Trip.boxName);
    Box updateTripBox = Hive.box(UpdateTrip.boxName);
    Trip oldTrip = Trip.fromCache(tripBox.get(updateTrip.id));
    Trip tmpTrip = updateTrip.toTrip(oldTrip);
    await tripBox.put(updateTrip.id, tmpTrip.toJson());
    await updateTripBox.put(updateTrip.id, updateTrip.toJson());
    if (online == null || !online) return tmpTrip;
    // try to upload and update cache if successful
    try {
      final Response response = await netWorkLocator.dio.put('$climbingApiHost/trip/${updateTrip.id}', data: updateTrip.toJson());
      if (response.statusCode != 200) throw Exception('Failed to edit trip');
      Trip trip = Trip.fromJson(response.data);
      await tripBox.put(updateTrip.id, updateTrip.toJson());
      await updateTripBox.delete(updateTrip.id);
      return trip;
    } catch (e) {
      if (e is DioError) {
        if (e.error.toString().contains('OS Error: No address associated with hostname, errno = 7')){
          MyNotifications.showNegativeNotification('Couldn\'t connect to API');
        }
      }
    }
    return tmpTrip;
  }

  /// Delete a trip in cache and optionally on the server.
  /// If the parameter [online] is null or false the trips are deleted only from the cache and later from the server at the next sync.
  /// Otherwise they are deleted from cache and from the server immediately.
  Future<void> deleteTrip(Trip trip, {bool? online}) async {
    Box tripBox = Hive.box(Trip.boxName);
    Box deleteTripBox = Hive.box(Trip.deleteBoxName);
    // TODO delete media from cache
    await tripBox.delete(trip.id);
    await deleteTripBox.put(trip.id, trip.toJson());
    if (online == null || !online) return;
    try {
      // delete media
      for (var id in trip.mediaIds) {
        final Response mediaResponse = await netWorkLocator.dio.delete('$mediaApiHost/media/$id');
        if (mediaResponse.statusCode != 204) throw Exception('Failed to delete medium');
      }
      // delete trip
      final Response tripResponse = await netWorkLocator.dio.delete('$climbingApiHost/trip/${trip.id}');
      if (tripResponse.statusCode != 200) throw Exception('Failed to delete trip');
      await deleteTripBox.delete(trip.id);
      MyNotifications.showPositiveNotification('Trip was deleted: ${trip.name}');
    } catch (e) {
      if (e is DioError) {
        if (e.error.toString().contains('OS Error: No address associated with hostname, errno = 7')){
          MyNotifications.showNegativeNotification('Couldn\'t connect to API');
        }
      }
    }
  }

  /// Upload trip to server.
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
