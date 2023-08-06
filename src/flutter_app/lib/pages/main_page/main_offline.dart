import 'package:flutter/material.dart';


class MainOffline extends StatefulWidget {
  const MainOffline({super.key, required this.title, required this.pages, required this.pageIndex, required this.onIndexChanged, required this.continueOffline});

  final String title;
  final List<Widget> pages;
  final int pageIndex;
  final ValueSetter<int> onIndexChanged;
  final ValueSetter<bool> continueOffline;

  @override
  State<StatefulWidget> createState() => _MainOfflineState();
}

class _MainOfflineState extends State<MainOffline>{

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
            onPressed: () => widget.continueOffline.call(false),
            icon: const Icon(
              Icons.home,
              color: Colors.black,
              size: 30.0,
              semanticLabel: 'home',
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