import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:climbing_diary/services/ascent_service.dart';
import 'package:climbing_diary/services/cache_service.dart';
import 'package:climbing_diary/services/media_service.dart';
import 'package:climbing_diary/services/multi_pitch_route_service.dart';
import 'package:climbing_diary/services/pitch_service.dart';
import 'package:climbing_diary/services/single_pitch_route_service.dart';
import 'package:climbing_diary/services/spot_service.dart';
import 'package:climbing_diary/services/trip_service.dart';
import 'package:flutter/material.dart';

import 'package:climbing_diary/components/common/settings.dart';

import '../../components/common/my_notifications.dart';


class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.title, required this.logout, required this.pages, required this.online, required this.user, required this.login});

  final String title;
  final List<Widget> pages;
  final bool online;
  final UserProfile? user;
  final VoidCallback login;
  final VoidCallback logout;

  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>{
  int pageIndex = 0;

  CacheService cacheService = CacheService();
  TripService tripService = TripService();
  SpotService spotService = SpotService();
  MultiPitchRouteService multiPitchRouteService = MultiPitchRouteService();
  SinglePitchRouteService singlePitchRouteService = SinglePitchRouteService();
  PitchService pitchService = PitchService();
  AscentService ascentService = AscentService();
  MediaService mediaService = MediaService();

  Future<void> sync() async {
    await tripService.getTrips(widget.online);
    await spotService.getSpots(widget.online);
    await multiPitchRouteService.getMultiPitchRoutes(widget.online);
    await singlePitchRouteService.getSinglePitchRoutes(widget.online);
    await pitchService.getPitches(widget.online);
    await ascentService.getAscents(widget.online);
    await mediaService.getMedia(widget.online);
    cacheService.applyQueued();
    setState(() {});
  }

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          (widget.online && widget.user != null) ? IconButton(
            onPressed: () async {
              await sync();
              MyNotifications.showPositiveNotification("synced");
            },
            icon: const Icon(Icons.refresh, color: Colors.black, size: 30.0, semanticLabel: 'sync'),
          ) : Container(),
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Settings())),
            icon: const Icon(Icons.settings_rounded, color: Colors.black, size: 30.0, semanticLabel: 'settings'),
          ),
          widget.user != null ? IconButton(
            onPressed: () => widget.logout.call(),
            icon: const Icon(Icons.logout_rounded, color: Colors.black, size: 30.0, semanticLabel: 'logout'),
          ) : IconButton(
            onPressed: () => widget.login.call(),
            icon: const Icon(Icons.login_rounded, color: Colors.black, size: 30.0, semanticLabel: 'login'),
          ),
        ],
      ),
      body: widget.pages[pageIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: pageIndex,
        onTap: (index) {
          setState(() => pageIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Diary'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'List'),
          BottomNavigationBarItem(icon: Icon(Icons.graphic_eq), label: 'Statistic')
        ],
      ),
    );
  }
}