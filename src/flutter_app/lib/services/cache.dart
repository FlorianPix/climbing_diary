import 'package:climbing_diary/services/spot_service.dart';
import 'package:hive/hive.dart';

import '../interfaces/spot.dart';

final SpotService spotService = SpotService();

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

void editSpotFromCache(Spot spot) {
  Box box = Hive.box('spots');
  box.put(spot.id, spot.toJson());
}

void deleteSpotFromCache(String spotId){
  Box box = Hive.box('spots');
  box.delete(spotId);
}

void deleteSpotFromUploadQueue(int spotHash){
  Box box = Hive.box('upload_later_spots');
  box.delete(spotHash);
}