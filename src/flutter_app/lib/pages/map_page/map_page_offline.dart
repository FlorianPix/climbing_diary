import 'package:flutter/material.dart';
import '../save_location_no_connection.dart';
import '../../interfaces/spot/spot.dart';

class MapPageOffline extends StatefulWidget {
  const MapPageOffline({super.key});

  @override
  State<MapPageOffline> createState() => _MapPageOfflineState();
}

class _MapPageOfflineState extends State<MapPageOffline> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text('You have no connection at the moment. But you can still create spots. They will be uploaded automatically as soon as you regain connection.'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SaveLocationNoConnectionPage(onAdd: (Spot value) {})),
          );
        },
        backgroundColor: Colors.green,
        elevation: 5,
        child: const Icon(Icons.add),
      ),
    );
  }
}
