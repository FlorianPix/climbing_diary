import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../interfaces/spot/spot.dart';
import '../services/spot_service.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<StatefulWidget> createState() => ListPageState();
}

class ListPageState extends State<ListPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController controllerSearch = TextEditingController();

  final SpotService spotService = SpotService();

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Spot>>(
        future: spotService.getSpotsByName(controllerSearch.text),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Spot> spots = snapshot.data!;
            List<Widget> elements = [];
            elements.add(Form(
              key: _formKey,
              child:
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
                  onChanged: (String s) {
                    setState(() {});
                  }
                ),
              ),
            ));
            for (Spot spot in spots){
              elements.add(
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            spot.name,
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${round(spot.coordinates[0], decimals: 8)}, ${round(spot.coordinates[1], decimals: 8)}',
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400
                            ),
                          ),
                        ]
                      ),
                    )
                  )
                )
              );
            }
            return ListView(
              children: elements,
            );
          } else {
            return const CircularProgressIndicator();
          }
        }
      )
    );
  }
}