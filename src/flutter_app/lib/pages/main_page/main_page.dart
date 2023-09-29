import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/material.dart';

import '../../components/settings.dart';


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

  void sync(){
    // TODO
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
            onPressed: () => sync(),
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