import 'package:flutter/material.dart';

import '../../components/settings.dart';


class MainLoggedIn extends StatefulWidget {
  const MainLoggedIn({super.key, required this.title, required this.logout, required this.pages, required this.pageIndex, required this.onIndexChanged});

  final String title;
  final List<Widget> pages;
  final int pageIndex;
  final VoidCallback logout;
  final ValueSetter<int> onIndexChanged;

  @override
  State<StatefulWidget> createState() => _MainLoggedInState();
}

class _MainLoggedInState extends State<MainLoggedIn>{

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int pageIndex = widget.pageIndex;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Settings())
              );
            },
            icon: const Icon(
              Icons.settings,
              color: Colors.black,
              size: 30.0,
              semanticLabel: 'settings',
            ),
          ),
          IconButton(
            onPressed: () => widget.logout.call(),
            icon: const Icon(
              Icons.logout,
              color: Colors.black,
              size: 30.0,
              semanticLabel: 'logout',
            ),
          )
        ],
      ),
      body: widget.pages[pageIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: pageIndex,
        onTap: (index) {
          widget.onIndexChanged.call(index);
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