import 'package:climbing_diary/pages/statistic_page.dart';
import 'package:flutter/material.dart';
import '../components/diary_page/trip_timeline.dart';
import '../components/list_page/spot_list.dart';
import 'diary_page.dart';
import 'map_page.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<StatefulWidget> createState() => ListPageState();
}

class ListPageState extends State<ListPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController controllerSearch = TextEditingController();

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextFormField(
                controller: controllerSearch,
                decoration: const InputDecoration(
                  icon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  hintText: "spot, route or pitch name",
                  labelText: "spot, route or pitch name"
                ),
              ),
            ),
          ]
        )
      )
    );
  }
}