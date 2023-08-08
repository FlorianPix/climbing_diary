import 'package:climbing_diary/services/spot_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../interfaces/my_base_interface/update_my_base_interface.dart';

final SpotService spotService = SpotService();

class CacheService{
  final List<String> boxNames = [
    'trips', 'delete_trips', 'edit_trips', 'create_trips',
    'spots', 'delete_spots', 'edit_spots', 'create_spots',
    'single_pitch_routes', 'delete_single_pitch_routes', 'edit_single_pitch_routes', 'create_single_pitch_routes',
    'multi_pitch_routes', 'delete_multi_pitch_routes', 'edit_multi_pitch_routes', 'create_multi_pitch_routes',
    'pitches', 'delete_pitches', 'edit_pitches', 'create_pitches',
    'ascents', 'delete_ascents', 'edit_ascents', 'create_ascents',
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

  void createQueuedTs<T>(String boxName, Future<T?> Function(Map) uploadT) {
    Box box = Hive.box(boxName);
    var data = [];
    for(var i = 0; i < box.length; i++){
      data.add(box.getAt(i));
    }
    if (data.isEmpty) return;
    for(var i = data.length-1; i >= 0; i--){
      uploadT(data[i]);
    }
  }

  void deleteQueuedTs<T>(String boxName, Future<void> Function(Map) deleteT) {
    Box box = Hive.box(boxName);
    var data = [];
    for(var i = 0; i < box.length; i++){
      data.add(box.getAt(i));
    }
    if (data.isEmpty) return;
    for(var i = data.length-1; i >= 0; i--){
      deleteT(data[i]);
    }
  }

  void editQueuedTs<T>(String boxName, Future<void> Function(Map) editT) {
    Box box = Hive.box(boxName);
    var data = [];
    for(var i = 0; i < box.length; i++){
      data.add(box.getAt(i));
    }
    if (data.isEmpty) return;
    for(var i = data.length-1; i >= 0; i--){
      editT(data[i]);
    }
  }

  void editTFromCache<T extends UpdateMyBaseInterface>(String boxName, T t) {
    Hive.box(boxName).put(t.id, t.toJson());
  }

  void deleteTFromCacheById(String boxName, String tId){
    Hive.box(boxName).delete(tId);
  }

  void deleteTFromCacheByHash(String boxName, int tHash){
    Hive.box(boxName).delete(tHash);
  }

  bool isStale(Map cache, String serverUpdatedString){
    if (cache['updated'] == null) return true;
    DateTime cachedUpdated = DateTime.parse(cache['updated']);
    DateTime serverUpdated = DateTime.parse(serverUpdatedString);
    if (serverUpdated.compareTo(cachedUpdated) == 1) return true;
    return false;
  }
}