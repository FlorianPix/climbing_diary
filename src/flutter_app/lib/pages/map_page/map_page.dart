import 'package:climbing_diary/pages/map_page/map_page_offline.dart';
import 'package:climbing_diary/pages/map_page/map_page_online.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';


class MapPage extends StatefulWidget {
  const MapPage({super.key, required this.onNetworkChange});
  final ValueSetter<bool> onNetworkChange;

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  bool online = false;

  void checkConnection() async {
    await InternetConnectionChecker().hasConnection.then((value) {
      widget.onNetworkChange.call(value);
      setState(() => online = value);
    });
  }

  @override
  void initState() {
    super.initState();
    checkConnection();
  }

  @override
  Widget build(BuildContext context) {
    if (online) return MapPageOnline(onNetworkChange: (bool value) => setState(() => online = value));
    return MapPageOffline(onNetworkChange: (bool value) => setState(() => online = value));
  }
}
