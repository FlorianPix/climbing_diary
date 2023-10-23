import 'package:climbing_diary/services/error_service.dart';
import 'package:climbing_diary/services/media_service.dart';
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

import '../interfaces/media/media.dart';

class TripService {
  final netWorkLocator = getIt.get<DioClient>();
  final sharedPrefLocator = getIt.get<SharedPreferenceHelper>();
  final String climbingApiHost = Environment().config.climbingApiHost;
  final String mediaApiHost = Environment().config.mediaApiHost;
  final MediaService mediaService = MediaService();

  /// Get a trip by its id from cache and optionally from the server.
  /// If the parameter [online] is null or false the trip is searched in cache,
  /// otherwise it is requested from the server.
  Future<Trip?> getTrip(String tripId, {bool? online}) async {
    Box box = Hive.box(Trip.boxName);
    if (online == null || !online) return Trip.fromCache(box.get(tripId));
    // request trip from server
    try {
      final Response missingTripResponse = await netWorkLocator.dio.post('$climbingApiHost/trip/$tripId');
      if (missingTripResponse.statusCode != 200) throw Exception("Error during request of trip");
      // TODO check if cache is up to date
      return Trip.fromJson(missingTripResponse.data);
    } catch (e) {
      ErrorService.handleConnectionErrors(e);
    }
    return null;
  }

  /// Get all trips from cache and optionally from the server.
  /// If the parameter [online] is null or false the trips are searched in cache,
  /// otherwise they are requested from the server.
  Future<List<Trip>> getTrips({bool? online}) async {
    if(online == null || !online) return CacheService.getTsFromCache<Trip>(Trip.boxName, Trip.fromCache);
    // request trips from the server
    try {
      final Response tripsResponse = await netWorkLocator.dio.get('$climbingApiHost/trip');
      if (tripsResponse.statusCode != 200) throw Exception("Error during request of trips");
      List<Trip> trips = [];
      Box box = Hive.box(Trip.boxName);
      // TODO check if cache is up to date
      Future.forEach(tripsResponse.data, (dynamic s) async {
        Trip trip = Trip.fromJson(s);
        await box.put(trip.id, trip.toJson());
        trips.add(trip);
      });
      return trips;
    } catch (e) {
      ErrorService.handleConnectionErrors(e);
    }
    return [];
  }

  /// Create a trip in cache and optionally on the server.
  /// If the parameter [online] is null or false the trip is added to the cache and uploaded later at the next sync.
  /// Otherwise it is added to the cache and to the server.
  Future<Trip> createTrip(Trip trip, {bool? online}) async {
    // add to cache
    Box tripBox = Hive.box(Trip.boxName);
    Box createTripBox = Hive.box(CreateTrip.boxName);
    await tripBox.put(trip.id, trip.toJson());
    await createTripBox.put(trip.id, trip.toJson());
    if (online == null || !online) return trip;
    // try to upload and update cache if successful
    Map data = trip.toJson();
    Trip? uploadedTrip = await uploadTrip(data);
    if (uploadedTrip == null) return trip;
    await tripBox.put(trip.id, trip.toJson());
    await createTripBox.delete(trip.id);
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
      await tripBox.put(updateTrip.id, trip.toJson());
      await updateTripBox.delete(updateTrip.id);
      return trip;
    } catch (e) {
      ErrorService.handleConnectionErrors(e);
    }
    return tmpTrip;
  }

  /// Delete a trip and its media in cache and optionally on the server.
  /// If the parameter [online] is null or false the trips are deleted only from the cache and later from the server at the next sync.
  /// Otherwise they are deleted from cache and from the server immediately.
  Future<void> deleteTrip(Trip trip, {bool? online}) async {
    Box tripBox = Hive.box(Trip.boxName);
    Box deleteTripBox = Hive.box(Trip.deleteBoxName);
    await tripBox.delete(trip.id);
    await deleteTripBox.put(trip.id, trip.toJson());
    // remove from create queue (if no sync since)
    Box createTripBox = Hive.box(Trip.createBoxName);
    await createTripBox.delete(trip.id);
    // delete media of trip locally (deleted automatically on the server when trip is deleted)
    List<Media> media = await mediaService.getMedia();
    for (Media medium in media){
      await mediaService.deleteMediumLocal(medium);
    }
    if (online == null || !online) return;
    try {
      // delete trip
      final Response tripResponse = await netWorkLocator.dio.delete('$climbingApiHost/trip/${trip.id}');
      if (tripResponse.statusCode != 200) throw Exception('Failed to delete trip');
      await deleteTripBox.delete(trip.id);
      MyNotifications.showPositiveNotification('Trip was deleted: ${trip.name}');
    } catch (e) {
      ErrorService.handleConnectionErrors(e);
    }
  }

  /// Upload trip to the server.
  Future<Trip?> uploadTrip(Map data) async {
    try {
      print(data);
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
