import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'config/environment.dart';
import 'pages/diary_page.dart';
import 'pages/map_page.dart';
import 'pages/statistic_page.dart';
import 'services/locator.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'data/sharedprefs/shared_preference_helper.dart';

Future<void> main() async {
  const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: Environment.DEV,
  );

  Environment().initConfig(environment);

  WidgetsFlutterBinding.ensureInitialized();
  final applicationDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(applicationDocumentDir.path);
  await Hive.openBox('saveSpot');
  await setup();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Map<int, Color> color = const {
      50:Color.fromRGBO(255,127,90, .1),
      100:Color.fromRGBO(255,127,90, .2),
      200:Color.fromRGBO(255,127,90, .3),
      300:Color.fromRGBO(255,127,90, .4),
      400:Color.fromRGBO(255,127,90, .5),
      500:Color.fromRGBO(255,127,90, .6),
      600:Color.fromRGBO(255,127,90, .7),
      700:Color.fromRGBO(255,127,90, .8),
      800:Color.fromRGBO(255,127,90, .9),
      900:Color.fromRGBO(255,127,90, 1),
    };
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: MaterialColor(0xffff7f50, color),
      ),
      home: const MyHomePage(title: 'ClimbingDiary'),
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
  late bool online = true;

  int currentIndex = 0;
  final screens = [const MapPage(), const DiaryPage(), const StatisticPage()];

  @override
  void initState() {
    super.initState();
    auth0 = Auth0(
        'climbing-diary.eu.auth0.com', 'FnK5PkMpjuoH5uJ64X70dlNBuBzPVynE');
    checkConnection();
  }

  Future<void> login() async {
    var credentials = await auth0.webAuthentication(scheme: 'demo').login(
        audience: 'climbing-diary-API',
        scopes: {
          'profile',
          'email',
          'read:diary',
          'write:diary',
          'read:media',
          'write:media'
        });

    setState(() {
      _user = credentials.user;
      _credentials = credentials;
      _prefsLocator.setUserToken(
          userToken: 'Bearer ${credentials.accessToken}');
    });
  }

  Future<void> logout() async {
    await auth0.webAuthentication(scheme: 'demo').logout();

    setState(() {
      _user = null;
    });
  }

  Future<bool> checkConnection() async {
    return await InternetConnectionChecker().hasConnection;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkConnection(),
      builder: (context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.hasData) {
          var online = snapshot.data!;
          if (online) {
            if (_user != null) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(widget.title),
                  actions: <Widget>[
                    IconButton(
                      onPressed: logout,
                      icon: const Icon(
                        Icons.logout,
                        color: Colors.black,
                        size: 30.0,
                        semanticLabel: 'logout',
                      ),
                    )
                  ],
                ),
                body: screens[currentIndex],
                bottomNavigationBar: BottomNavigationBar(
                  currentIndex: currentIndex,
                  onTap: (index) => setState(() => currentIndex = index),
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.map),
                      label: 'Map',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.menu_book),
                      label: 'Diary',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.graphic_eq),
                      label: 'Statistic',
                    )
                  ],
                ),
              );
            } else {
              return Scaffold(
                appBar: AppBar(
                  title: Text(widget.title),
                ),
                body: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/start_page_background.jpeg"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                    Expanded(
                      child: Column(children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 50),
                            child: Center(
                              child: Column(children: [
                                ElevatedButton(
                                  onPressed: login,
                                  style: ButtonStyle(
                                    backgroundColor:
                                    MaterialStateProperty.all<Color>(Colors.green),
                                  ),
                                  child: const Text('Login'),
                                ),
                              ])),
                          ))
                      ]),
                    )
                  ])
                ),
              );
            }
          }
          else {
            return Scaffold(
              appBar: AppBar(
                title: Text(widget.title),
              ),
              body: screens[currentIndex],
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: currentIndex,
                onTap: (index) => setState(() => currentIndex = index),
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.map),
                    label: 'Map',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.menu_book),
                    label: 'Diary',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.graphic_eq),
                    label: 'Statistic',
                  )
                ],
              ),
            );
          }
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        return const CircularProgressIndicator();
      }
    );
  }
}