import 'package:hive/hive.dart';

import '../interfaces/spot.dart';

List<Spot> getSpotsFromCache() {
  Box box = Hive.box('spots');
  List<Spot> spots = [];
  for(var i = 0; i < box.length; i++){
    var data = box.getAt(i);
    spots.add(Spot.fromCache(data));
  }
  return spots;
}