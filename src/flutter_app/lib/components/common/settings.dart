import 'package:climbing_diary/components/common/my_notifications.dart';
import 'package:climbing_diary/components/common/my_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../interfaces/grading_system.dart';

import '../../services/admin_service.dart';
import '../../services/archive_service.dart';
import '../../services/cache_service.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsState();
}

class _SettingsState extends State<Settings>{
  final AdminService adminService = AdminService();
  final ArchiveService archiveService = ArchiveService();
  GradingSystem gradingSystem = GradingSystem.french;
  late SharedPreferences prefs;

  fetchGradingSystemPreference() async {
    prefs = await SharedPreferences.getInstance();
    int? fetchedGradingSystem = prefs.getInt('gradingSystem');
    if (fetchedGradingSystem != null) gradingSystem = GradingSystem.values[fetchedGradingSystem];
    setState(() {});
  }

  setGradingSystemPreference(int value) async {
    await prefs.setInt('gradingSystem', value);
    gradingSystem = GradingSystem.values[value];
    setState(() {});
  }

  @override
  void initState(){
    super.initState();
    fetchGradingSystemPreference();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Settings'),
      content: SizedBox(width: 500, height: 500, child: ListView(
        children: [
          Card(child: Column(children: [
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text("Select grading system", style: MyTextStyles.title)
            ),
            Padding(
              padding: const EdgeInsets.all(5),
              child: DropdownButton<GradingSystem>(
                value: gradingSystem,
                items: GradingSystem.values.map<DropdownMenuItem<GradingSystem>>((GradingSystem value) {
                  return DropdownMenuItem<GradingSystem>(
                    value: value,
                    child: Text(value.toShortString())
                  );
                }).toList(),
                onChanged: (GradingSystem? value) => setState(() => setGradingSystemPreference(value!.index)),
              )
            )
          ])),
          Card(child: Column(children: [
            const Padding(
              padding: EdgeInsets.only(top: 5),
              child: Text("Import", style: MyTextStyles.title)
            ),
            ElevatedButton.icon(
              onPressed: () {archiveService.readPicked();},
              icon: const Icon(
                Icons.upload,
                color: Colors.black,
                size: 30.0,
                semanticLabel: 'load',
              ),
              label: const Text("pick a .json file to import"),
            )
          ])),
          Card(child: Column(children: [
            const Padding(
              padding: EdgeInsets.only(top: 5),
              child: Text("Backup", style: MyTextStyles.title)
            ),
            ElevatedButton.icon(
              onPressed: () {archiveService.readBackup();},
              icon: const Icon(
                Icons.upload,
                color: Colors.black,
                size: 30.0,
                semanticLabel: 'load',
              ),
              label: const Text("load climbing data\nfrom this device"),
            ),
            ElevatedButton.icon(
              onPressed: () {archiveService.writeBackup();},
              icon: const Icon(
                Icons.download,
                color: Colors.black,
                size: 30.0,
                semanticLabel: 'save',
              ),
              label: const Text("save your climbing data\nto this device"),
            )
          ])),
          Card(child: Column(children: [
            const Padding(
              padding: EdgeInsets.only(top: 5),
              child: Text("Cache", style: MyTextStyles.title)
            ),
            ElevatedButton.icon(
              onPressed: () {
                CacheService.clearCache();
                MyNotifications.showPositiveNotification("cleared cache");
              },
              icon: const Icon(
                Icons.delete,
                color: Colors.black,
                size: 30.0,
                semanticLabel: 'clear cache',
              ),
              label: const Text("clear cache"),
            )
          ])),
          Card(child: Column(children: [
            const Padding(
              padding: EdgeInsets.only(top: 5),
              child: Text("Delete", style: MyTextStyles.title)
            ),
            ElevatedButton.icon(
              onPressed: () {adminService.deleteAll();},
              icon: const Icon(
                Icons.delete,
                color: Colors.black,
                size: 30.0,
                semanticLabel: 'delete all data incl. images',
              ),
              label: const Text("delete all data incl. images"),
            )
          ])),
        ],
      )),
    );
  }
}