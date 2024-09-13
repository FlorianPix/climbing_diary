import 'dart:io';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:climbing_diary/services/archive_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:climbing_diary/services/ascent_service.dart';
import 'package:climbing_diary/services/cache_service.dart';
import 'package:climbing_diary/services/media_service.dart';
import 'package:climbing_diary/services/multi_pitch_route_service.dart';
import 'package:climbing_diary/services/pitch_service.dart';
import 'package:climbing_diary/services/single_pitch_route_service.dart';
import 'package:climbing_diary/services/spot_service.dart';
import 'package:climbing_diary/services/trip_service.dart';
import 'package:climbing_diary/components/common/settings.dart';
import 'package:climbing_diary/components/common/my_notifications.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../interfaces/ascent/ascent.dart';
import '../../interfaces/grade.dart';
import '../../interfaces/grading_system.dart';
import '../../interfaces/multi_pitch_route/multi_pitch_route.dart';
import '../../interfaces/pitch/pitch.dart';
import '../../interfaces/single_pitch_route/single_pitch_route.dart';
import '../../interfaces/spot/spot.dart';


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

class AscentPrint {
  const AscentPrint(
      this.date,
      this.spotName,
      this.routeName,
      this.grade,
      this.length,
      this.ascentType,
      this.ascentStyle
  );

  final String date;
  final String spotName;
  final String routeName;
  final Grade grade;
  final int length;
  final int ascentType;
  final int ascentStyle;

  String getIndex(int index) {
    switch (index) {
      case 0:
        return date;
      case 1:
        return spotName;
      case 2:
        return routeName;
      case 3:
        return '${grade.grade} ${grade.system.name}';
      case 4:
        return '$length m';
      case 5:
        return ascentType.toString();
      case 6:
        return ascentType.toString();
    }
    return '';
  }
}

class _MainPageState extends State<MainPage>{
  int pageIndex = 0;
  bool syncing = false;
  bool exporting = false;
  bool importing = false;

  ArchiveService archiveService = ArchiveService();
  CacheService cacheService = CacheService();
  TripService tripService = TripService();
  SpotService spotService = SpotService();
  MultiPitchRouteService multiPitchRouteService = MultiPitchRouteService();
  SinglePitchRouteService singlePitchRouteService = SinglePitchRouteService();
  PitchService pitchService = PitchService();
  AscentService ascentService = AscentService();
  MediaService mediaService = MediaService();

  Future<void> sync() async {
    setState(() => syncing = true);
    await cacheService.applyChanges();
    MyNotifications.showPositiveNotification("applied your changes");
    await tripService.getTrips(online: widget.online);
    MyNotifications.showPositiveNotification("synced trips");
    await spotService.getSpots(online: widget.online);
    MyNotifications.showPositiveNotification("synced spots");
    await multiPitchRouteService.getMultiPitchRoutes(online: widget.online);
    MyNotifications.showPositiveNotification("synced multi pitch routes");
    await singlePitchRouteService.getSinglePitchRoutes(online: widget.online);
    MyNotifications.showPositiveNotification("synced single pitch routes");
    await pitchService.getPitches(online: widget.online);
    MyNotifications.showPositiveNotification("synced pitches");
    await ascentService.getAscents(online: widget.online);
    MyNotifications.showPositiveNotification("synced ascents");
    await mediaService.getMedia(online: widget.online);
    MyNotifications.showPositiveNotification("synced");
    setState(() => syncing = false);
  }

  Future<void> export() async {
    setState(() => exporting = true);
    await archiveService.export();
    setState(() => exporting = false);
  }

  Future<void> import() async {
    setState(() => importing = true);
    await archiveService.import();
    setState(() => importing = false);
  }

  Future<void> printPDF() async {
    final pdf = pw.Document();

    String? directoryPath = await FilePicker.platform.getDirectoryPath();

    List<Spot> spots = await spotService.getSpots();
    List<AscentPrint> ascentPrints = [];
    for (Spot spot in spots) {
      List<MultiPitchRoute> multiPitchRoutes = await multiPitchRouteService.getMultiPitchRoutesOfIds(spot.multiPitchRouteIds);
      for (MultiPitchRoute multiPitchRoute in multiPitchRoutes) {
        Ascent? ascent = await multiPitchRouteService.getBestAscent(multiPitchRoute);
        if (ascent == null) {
          continue;
        }
        int length = await multiPitchRouteService.getLength(multiPitchRoute);
        Grade grade = await multiPitchRouteService.getGrade(multiPitchRoute);
        ascentPrints.add(AscentPrint(
            ascent.date,
            spot.name,
            multiPitchRoute.name,
            grade,
            length,
            ascent.type,
            ascent.style
        ));
      }

      List<SinglePitchRoute> singlePitchRoutes = await singlePitchRouteService.getSinglePitchRoutesOfIds(spot.singlePitchRouteIds);
      for (SinglePitchRoute singlePitchRoute in singlePitchRoutes) {
        List<Ascent> ascents = await ascentService.getAscentsOfIds(singlePitchRoute.ascentIds);
        for (Ascent ascent in ascents) {
          ascentPrints.add(AscentPrint(
              ascent.date,
              spot.name,
              singlePitchRoute.name,
              singlePitchRoute.grade,
              singlePitchRoute.length,
              ascent.type,
              ascent.style
          ));
        }
      }
    }

    List<pw.Widget> childWidgets = [];
    for (AscentPrint ascentPrint in ascentPrints) {
      childWidgets.add(pw.Row(children: [pw.Text(ascentPrint.date)]));
      childWidgets.add(pw.Row(children: [pw.Text('${ascentPrint.spotName} ${ascentPrint.routeName}')]));
      childWidgets.add(pw.Row(children: [pw.Text('${ascentPrint.grade.grade} ${ascentPrint.grade.system.name} ${ascentPrint.length} m ${ascentPrint.ascentType} ${ascentPrint.ascentStyle}')]));
      childWidgets.add(pw.Row(children: [pw.Text('---')]));
    }

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) => [
          pw.Column(
            children: childWidgets
          ),
        ]
      ),
    );

    final file = File('$directoryPath/example.pdf');
    await file.writeAsBytes(await pdf.save());
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
          IconButton(
            onPressed: () async {
              await printPDF();
            },
            icon: const Icon(Icons.print_rounded, color: Colors.black, size: 30.0, semanticLabel: 'export'),
          ),
          IconButton(
            onPressed: () async {
              await import();
            },
            icon: const Icon(Icons.input_rounded, color: Colors.black, size: 30.0, semanticLabel: 'export'),
          ),
          IconButton(
            onPressed: () async {
              await export();
            },
            icon: const Icon(Icons.publish_rounded, color: Colors.black, size: 30.0, semanticLabel: 'export'),
          ),
          (widget.online && widget.user != null) ? IconButton(
            onPressed: () async {
              await sync();
            },
            icon: const Icon(Icons.refresh, color: Colors.black, size: 30.0, semanticLabel: 'sync'),
          ) : Container(),
          IconButton(
            onPressed: () => showDialog(
                context: context,
                builder: (BuildContext context) => const Settings()
            ),
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
      body: !syncing && !importing && !exporting ? widget.pages[pageIndex] : const Center(child: CircularProgressIndicator()),
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