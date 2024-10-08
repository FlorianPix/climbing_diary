import 'package:climbing_diary/components/common/my_text_styles.dart';
import 'package:flutter/material.dart';
import 'save_location_no_connection.dart';
import '../../interfaces/spot/spot.dart';

class MapPageOffline extends StatefulWidget {
  const MapPageOffline({super.key, required this.onNetworkChange});

  final ValueSetter<bool> onNetworkChange;

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
      body: const Center(child: Card(child: Padding(padding: EdgeInsets.all(10),
        child: Text('Offline Mode', style: MyTextStyles.title),
      ))),
      floatingActionButton: FloatingActionButton(
        onPressed: () async => Navigator.push(context,
          MaterialPageRoute(
            builder: (context) => SaveLocationNoConnectionPage(
              onAdd: (Spot value) {}, // TODO
              onNetworkChange: widget.onNetworkChange,
            )
          ),
        ),
        backgroundColor: Colors.green,
        elevation: 5,
        child: const Icon(Icons.add),
      ),
    );
  }
}
