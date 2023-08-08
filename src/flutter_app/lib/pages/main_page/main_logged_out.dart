import 'package:flutter/material.dart';


class MainLoggedOut extends StatefulWidget {
  const MainLoggedOut({super.key, required this.title, required this.login, required this.continueOffline});

  final String title;
  final VoidCallback login;
  final ValueSetter<bool> continueOffline;

  @override
  State<StatefulWidget> createState() => _MainLoggedOutState();
}

class _MainLoggedOutState extends State<MainLoggedOut>{
  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.jpeg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(
            child: Column(children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 75),
                  child: Center(
                    child: Column(children: [
                      ElevatedButton(
                        onPressed: () => widget.login.call(),
                        style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.green)),
                        child: const Text('login'),
                      ),
                      ElevatedButton(
                        onPressed: () => widget.continueOffline.call(true),
                        style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.grey)),
                        child: const Text('continue offline'),
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