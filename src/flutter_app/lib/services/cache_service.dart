import 'package:climbing_diary/interfaces/spot/update_spot.dart';
import 'package:climbing_diary/services/spot_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../interfaces/spot/spot.dart';

final SpotService spotService = SpotService();

class CacheService{
  final List<String> boxNames = [
    'trips', 'delete_later_trips', 'edit_later_trips', 'upload_later_trips',
    'spots', 'delete_later_spots', 'edit_later_spots', 'upload_later_spots',
    'single_pitch_routes', 'delete_later_single_pitch_routes', 'edit_later_single_pitch_routes', 'upload_later_single_pitch_routes',
    'multi_pitch_routes', 'delete_later_multi_pitch_routes', 'edit_later_multi_pitch_routes', 'upload_later_multi_pitch_routes',
    'pitches', 'delete_later_pitches', 'edit_later_pitches', 'upload_later_pitches',
    'ascents', 'delete_later_ascents', 'edit_later_ascents', 'upload_later_ascents',
  ];

  Future<void> initCache(String path) async {
    await Hive.initFlutter(path);
    for (String boxName in boxNames){
      await Hive.openBox(boxName);
    }
  }

  void clearCache() {
    for (String boxName in boxNames){
      Box box = Hive.box(boxName);
      box.clear();
    }
  }

  List<T> getTsFromCache<T>(String key, T Function(Map) fromCacheFactory) {
    Box box = Hive.box(key);
    List<T> ts = [];
    for(var i = 0; i < box.length; i++){
      var data = box.getAt(i);
      ts.add(fromCacheFactory(data));
    }
    return ts;
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

  bool isStale(Map cache, String serverUpdatedString){
    DateTime cachedUpdated = DateTime.parse(cache['updated']);
    DateTime serverUpdated = DateTime.parse(serverUpdatedString);
    if (serverUpdated.compareTo(cachedUpdated) == 1) return true;
    return false;
  }
}