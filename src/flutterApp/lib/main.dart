import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
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
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.orange,
      ),
      home: const MyHomePage(title: 'ClimbingDiary'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

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
  final screens = [
    const MapPage(),
    const DiaryPage(),
    const StatisticPage()
  ];

  @override
  void initState() {
    super.initState();
    auth0 = Auth0('climbing-diary.eu.auth0.com', 'FnK5PkMpjuoH5uJ64X70dlNBuBzPVynE');
    checkConnection();
  }

  Future<void> login() async {
    var credentials = await auth0
        .webAuthentication(scheme: 'demo')
        .login(
          audience: 'climbing-diary-API',
          scopes: {'profile', 'email', 'read:diary', 'write:diary', 'read:media', 'write:media'}
        );

    setState(() {
      _user = credentials.user;
      _credentials = credentials;
      _prefsLocator.setUserToken(userToken: 'Bearer ${credentials.accessToken}');
    });
  }

  Future<void> logout() async {
    await auth0
        .webAuthentication(scheme: 'demo')
        .logout();

    setState(() {
      _user = null;
    });
  }

  checkConnection() async {
    online = await InternetConnectionChecker().hasConnection;
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    if (_user != null) {
      return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
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
            )],
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
    } else if (!online) {
      return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
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
    } else {
      return Scaffold(
          appBar: AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: Text(widget.title),
          ),
          body:
          Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(children: [
                    Expanded(child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(child: Column(
                          children: [
                            const Icon(
                              Icons.face,
                              color: Colors.orange,
                              size: 240.0,
                              semanticLabel: 'Text to announce in accessibility modes',
                            ),
                            ElevatedButton(
                              onPressed: login,
                              style: ButtonStyle(
                                backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.green),
                              ),
                              child: const Text('Login'),
                            ),
                          ]
                      )),
                    ))
                  ]),
                )
              ]
          )
      );
    }
  }
}
