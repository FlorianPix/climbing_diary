import 'package:climbing_diary/services/spot_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../interfaces/spot/spot.dart';
import '../interfaces/spot/update_spot.dart';

final SpotService spotService = SpotService();

class CacheService{
  final List<String> boxNames = [
    'trips', 'delete_trips', 'update_trips', 'create_trips',
    'spots', 'delete_spots', 'update_spots', 'create_spots',
    'single_pitch_routes', 'delete_single_pitch_routes', 'update_single_pitch_routes', 'create_single_pitch_routes',
    'multi_pitch_routes', 'delete_multi_pitch_routes', 'update_multi_pitch_routes', 'create_multi_pitch_routes',
    'pitches', 'delete_pitches', 'update_pitches', 'create_pitches',
    'ascents', 'delete_ascents', 'update_ascents', 'create_ascents',
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

  List<T> getCreateQueue<T>(String boxName, T Function(Map) fromCacheFactory) {
    Box box = Hive.box(boxName);
    List<T> ts = [];
    for(var i = 0; i < box.length; i++){
      ts.add(fromCacheFactory(box.getAt(i)));
    }
    return ts;
  }

  void uploadQueuedTs(String boxName) {
    Box box = Hive.box(boxName);
    var data = [];
    for(var i = 0; i < box.length; i++){
      data.add(box.getAt(i));
    }
    if (data.isEmpty) return;
    for(var i = data.length-1; i >= 0; i--){
      spotService.uploadSpot(data[i]);
    }
  }

  void deleteQueuedSpots() {
    Box box = Hive.box('delete_later_spots');
    var data = [];
    for(var i = 0; i < box.length; i++){
      data.add(box.getAt(i));
    }
    if (data.isEmpty) return;
    for(var i = data.length-1; i >= 0; i--){
      spotService.deleteSpot(Spot.fromCache(data[i]));
    }
  }

  void editQueuedSpots() {
    Box box = Hive.box('edit_later_spots');
    var data = [];
    for(var i = 0; i < box.length; i++){
      data.add(box.getAt(i));
    }
    if (data.isEmpty) return;
    for(var i = data.length-1; i >= 0; i--){
      spotService.editSpot(UpdateSpot.fromCache(data[i]));
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
    if (cache['updated'] == null) return true;
    DateTime cachedUpdated = DateTime.parse(cache['updated']);
    DateTime serverUpdated = DateTime.parse(serverUpdatedString);
    if (serverUpdated.compareTo(cachedUpdated) == 1) return true;
    return false;
  }
}