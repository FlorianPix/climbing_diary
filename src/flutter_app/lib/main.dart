import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:climbing_diary/components/my_colors.dart';
import 'package:climbing_diary/pages/list_page/list_page.dart';
import 'package:climbing_diary/pages/main_page/main_logged_in.dart';
import 'package:climbing_diary/pages/main_page/main_logged_out.dart';
import 'package:climbing_diary/pages/main_page/main_offline.dart';
import 'package:climbing_diary/pages/map_page/map_page.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'components/my_notifications.dart';
import 'config/environment.dart';
import 'pages/diary_page/diary_page.dart';
import 'pages/statistic_page/statistic_page.dart';
import 'services/locator.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'services/cache_service.dart';

import 'data/sharedprefs/shared_preference_helper.dart';

Future<void> main() async {
  const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: Environment.PROD,
  );
  Environment().initConfig(environment);
  WidgetsFlutterBinding.ensureInitialized();
  final CacheService cacheService = CacheService();
  final applicationDocumentDir = await getApplicationDocumentsDirectory();
  await cacheService.initCache(applicationDocumentDir.path);
  await setup();
  runApp(const OverlaySupport.global(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Climbing diary',
      theme: ThemeData(
        primarySwatch: const MaterialColor(0xffff7f50, MyColors.main),
      ),
      initialRoute: '/',
      routes: {'/': (context) => const MyHomePage(title: 'Climbing diary')},
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Credentials? _credentials;
  UserProfile? _user;

  final _prefsLocator = getIt.get<SharedPreferenceHelper>();

  late Auth0 auth0;
  late SharedPreferences prefs;
  bool online = false;
  bool continueOffline = false;
  int currentIndex = 0;

  Future<void> login() async {
    try{
      Credentials credentials = await auth0.webAuthentication(scheme: 'demo').login(
          audience: 'climbing-diary-API',
          scopes: {'profile', 'email', 'read:diary', 'write:diary', 'read:media', 'write:media'}
      );
      setState(() {
        _user = credentials.user;
        _credentials = credentials;
        _prefsLocator.setUserToken(userToken: 'Bearer ${credentials.accessToken}');
      });
    } catch (e) {
      if (e is WebAuthenticationException){
        MyNotifications.showNegativeNotification('Login was cancelled');
      }
    }
  }

  Future<void> logout() async {
    await auth0.webAuthentication(scheme: 'demo').logout();
    setState(() {_user = null;});
  }

  void onIndexChanged(int index){
    setState(() => currentIndex = index);
  }

  void onNetworkChange(bool online){
    setState(() => this.online = online);
  }

  void checkConnection() async {
    await InternetConnectionChecker().hasConnection.then((value) => setState(() => online = value));
  }

  @override
  void initState() {
    super.initState();
    auth0 = Auth0('climbing-diary.eu.auth0.com', 'FnK5PkMpjuoH5uJ64X70dlNBuBzPVynE');
    checkConnection();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      MapPage(onNetworkChange: onNetworkChange),
      DiaryPage(onNetworkChange: onNetworkChange),
      ListPage(onNetworkChange: onNetworkChange),
      StatisticPage(onNetworkChange: onNetworkChange)
    ];
    if (!online || continueOffline) {
      // offline
      return MainOffline(
        title: widget.title,
        pages: pages,
        pageIndex: currentIndex,
        onIndexChanged: onIndexChanged,
        continueOffline: (value) => setState(() => continueOffline = value),
      );
    }
    // online
    if (_user == null) {
      // not logged in
      return MainLoggedOut(
          title: widget.title,
          login: login,
          continueOffline: (value) => setState(() => continueOffline = value),
      );
    }
    // logged in
    return MainLoggedIn(
      title: widget.title,
      pages: pages,
      pageIndex: currentIndex,
      logout: logout,
      onIndexChanged: onIndexChanged,
    );
  }
}
