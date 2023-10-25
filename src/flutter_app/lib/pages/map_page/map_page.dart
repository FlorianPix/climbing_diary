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
  Future<bool> checkConnection() async {
    return await InternetConnectionChecker().hasConnection.then((value) {
      widget.onNetworkChange.call(value);
      return value;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkConnection(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text(snapshot.error.toString());
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        bool online = snapshot.data!;
        return online ? MapPageOnline(
            onNetworkChange: (bool value) => setState(() => online = value)
        ) : MapPageOffline(
            onNetworkChange: (bool value) => setState(() => online = value)
        );
      }
    );
  }
}
