import 'package:climbing_diary/interfaces/spot/update_spot.dart';
import 'package:climbing_diary/services/spot_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../interfaces/spot/spot.dart';
import '../../interfaces/trip/trip.dart';

final SpotService spotService = SpotService();

Future<void> initCache(String path) async {
  await Hive.initFlutter(path);
  await Hive.openBox('trips');
  await Hive.openBox('delete_later_trips');
  await Hive.openBox('edit_later_trips');
  await Hive.openBox('upload_later_trips');
  await Hive.openBox('spots');
  await Hive.openBox('delete_later_spots');
  await Hive.openBox('edit_later_spots');
  await Hive.openBox('upload_later_spots');
  await Hive.openBox('routes');
  await Hive.openBox('delete_later_routes');
  await Hive.openBox('edit_later_routes');
  await Hive.openBox('upload_later_routes');
  await Hive.openBox('pitches');
  await Hive.openBox('delete_later_pitches');
  await Hive.openBox('edit_later_pitches');
  await Hive.openBox('upload_later_pitches');
  await Hive.openBox('ascents');
  await Hive.openBox('delete_later_ascents');
  await Hive.openBox('edit_later_ascents');
  await Hive.openBox('upload_later_ascents');
}

void clearCache() {
  Box box1 = Hive.box('spots');
  Box box2 = Hive.box('upload_later_spots');
  Box box3 = Hive.box('edit_later_spots');
  Box box4 = Hive.box('delete_later_spots');
  box1.clear();
  box2.clear();
  box3.clear();
  box4.clear();
}

List<Spot> getSpotsFromCache() {
  Box box = Hive.box('spots');
  List<Spot> spots = [];
  for(var i = 0; i < box.length; i++){
    var data = box.getAt(i);
    spots.add(Spot.fromCache(data));
  }
  return spots;
}

List<Spot> getQueuedSpotsFromCache() {
  Box box = Hive.box('upload_later_spots');
  List<Spot> spots = [];
  for(var i = 0; i < box.length; i++){
    var data = box.getAt(i);
    spots.add(Spot.fromCache(data));
  }
  return spots;
}

void uploadQueuedSpots() {
  Box box = Hive.box('upload_later_spots');
  var data = [];
  for(var i = 0; i < box.length; i++){
    data.add(box.getAt(i));
  }
  if (data != []) {
    for(var i = data.length-1; i >= 0; i--){
      spotService.uploadSpot(data[i]);
    }
  }
}

void deleteQueuedSpots() {
  Box box = Hive.box('delete_later_spots');
  var data = [];
  for(var i = 0; i < box.length; i++){
    data.add(box.getAt(i));
  }
  if (data != []) {
    for(var i = data.length-1; i >= 0; i--){
      spotService.deleteSpot(Spot.fromCache(data[i]));
    }
  }
}

void editQueuedSpots() {
  Box box = Hive.box('edit_later_spots');
  var data = [];
  for(var i = 0; i < box.length; i++){
    data.add(box.getAt(i));
  }
  if (data != []) {
    for(var i = data.length-1; i >= 0; i--){
      spotService.editSpot(UpdateSpot.fromCache(data[i]));
    }
  }
}

void editSpotFromCache(UpdateSpot spot) {
  Box box = Hive.box('spots');
  box.put(spot.id, spot.toJson());
}

void deleteSpotFromCache(String spotId){
  Box box = Hive.box('spots');
  box.delete(spotId);
}

void deleteSpotFromEditQueue(int spotHash){
  Box box = Hive.box('edit_later_spots');
  box.delete(spotHash);
}

void deleteSpotFromDeleteQueue(int spotHash){
  Box box = Hive.box('delete_later_spots');
  box.delete(spotHash);
}

void deleteSpotFromUploadQueue(int spotHash){
  Box box = Hive.box('upload_later_spots');
  box.delete(spotHash);
}

List<Trip> getTripsFromCache() {
  Box box = Hive.box('trips');
  List<Trip> trips = [];
  for(var i = 0; i < box.length; i++){
    var data = box.getAt(i);
    trips.add(Trip.fromCache(data));
  }
  return trips;
}