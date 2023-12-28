import 'dart:async';

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:location/location.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

import 'second_screen.dart';
import 'history_screen.dart';

Future<void> initFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

Future<void> main() async {
  // Ensure that Flutter is initialized before Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await initFirebase();
  runApp(const MyApp());
}


class Localizacao{
    var nome;
    var descricao;
    var latitude;
    var longitude;
    var imagemURL;
    var estado;

    var distancia;
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JourneyBuddy',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade900),
        useMaterial3: true,
      ),
      //home: const MyHomePage(title: 'JourneyBuddy'),
      initialRoute: MyHomePage.routeName,
      routes: {
        MyHomePage.routeName: (context) => const MyHomePage(title: 'Localizações'),
        SecondScreen.routeName : (context) => const SecondScreen(),
        HistoryScreen.routeName : (context) => const HistoryScreen(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  static const String routeName = '/';

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  List<Localizacao>? _listaLocalizacoes = [];
  bool _fetchingData = false;

  final List<String> list = <String>['A-Z', 'Z-A', 'Distância ▲', 'Distância ▼'];
  String dropdownValue = 'none';


  @override
  void initState() {
    super.initState();
    location.getLocation();
    _initializeData();
  }
  Future<void> _initializeData() async {
    await _fetchLocalizacoes();
  }

  @override
  void dispose() {
    super.dispose();
  }



  // FIREBASE

  Future<void> _fetchLocalizacoes() async{
      try{
          _listaLocalizacoes!.clear();
          var db = FirebaseFirestore.instance;
          var collection = await db.collection('Localidades').get();
          for(var doc in collection.docs) {
              var l = new Localizacao();
              l.nome = doc['nome'];
              l.descricao = doc['descrição'];
              l.latitude = (doc['coordenadas'] as GeoPoint).latitude;
              l.longitude = (doc['coordenadas'] as GeoPoint).longitude;
              l.imagemURL = doc['imagemURL'];
              l.estado = doc['estado'];

              var distanceX=_locationData.latitude!-l.latitude;
              var distanceY=_locationData.longitude!-l.longitude;

              if(distanceX<0){
                distanceX=distanceX*-1;
              }
                if(distanceY<0){
                    distanceY=distanceY*-1;
                }

              l.distancia =  distanceX+distanceY;
              _listaLocalizacoes!.add(l);
          }
      }
      catch(ex){
        debugPrint('Something went wrong: $ex');
      }
      finally{
        setState(() => _fetchingData = false);
      }
    }

  // END FIREBASE


  // LOCATION

  Location location = Location();

  bool _serviceEnabled = false;
  PermissionStatus _permissionGranted = PermissionStatus.denied;
  LocationData _locationData = LocationData.fromMap({
    "latitude": 40.192639,
    "longitude": -8.411899,
  });

  void getLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    _locationData = await location.getLocation();
    setState(() { });
  }

  StreamSubscription<LocationData>? _locationSubscription;

  void startLocationUpdates() {
    _locationSubscription=location.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {_locationData = currentLocation;});
    });
  }

  void stopLocationUpdates() {
    _locationSubscription?.cancel();
    _locationSubscription=null;
  }

  // END LOCATION


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      body: Center(

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            Container(
              margin: EdgeInsets.only(top: 10.0, bottom: 10.0), // Adjust the margin as needed

            child: DropdownMenu<String>(
              initialSelection: dropdownValue,
              enableSearch: false,
              onSelected: (String? value) {
                setState(() {
                  dropdownValue = value!;
                  switch(dropdownValue){
                    case 'A-Z':
                      _listaLocalizacoes!.sort((a, b) => a.nome.compareTo(b.nome));
                      break;
                    case 'Z-A':
                      _listaLocalizacoes!.sort((a, b) => b.nome.compareTo(a.nome));
                      break;
                    case 'Distância ▲':
                        _listaLocalizacoes!.sort((a, b) => a.distancia.compareTo(b.distancia));

                      break;
                    case 'Distância ▼':
                        _listaLocalizacoes!.sort((a, b) => b.distancia.compareTo(a.distancia));

                      break;
                  }
                });
              },
              dropdownMenuEntries: list.map<DropdownMenuEntry<String>>((String value) {
                return DropdownMenuEntry<String>(value: value, label: value);
              }).toList(),
            ),
            ),



            if (_fetchingData) const CircularProgressIndicator(),

            if (!_fetchingData && _listaLocalizacoes != null && _listaLocalizacoes!.isNotEmpty)
              Expanded(
              child:SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: ListView.separated(
                  itemCount: _listaLocalizacoes!.length,

                  separatorBuilder: (_, __) => Container(
                    margin: EdgeInsets.only(top: 10.0, bottom: 10.0), // Adjust the margin as needed
                    child: Divider(thickness: 2.0),
                  ),

                  itemBuilder: (BuildContext context, int index) => Column(
                    children: [
                      Text(
                        _listaLocalizacoes![index].nome,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Text(
                        _listaLocalizacoes![index].descricao,
                      ),

                      Container(
                        margin: EdgeInsets.only(top: 10.0, bottom: 10.0), // Adjust the margin as needed
                        child: Image.network(
                          _listaLocalizacoes![index].imagemURL,
                        ),
                      ),

                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            SecondScreen.routeName,
                            arguments: _listaLocalizacoes![index].nome,
                          );
                        },
                        child: Text('Locais de Interesse'),
                      )
                    ],
                  ),
                ),
              ),
              ),
            ElevatedButton(
                onPressed: (){
                  Navigator.pushNamed(context, HistoryScreen.routeName);
                },
                child: Text('Histórico de Locais de Interesse')
            )
          ],
        ),
      ),

      floatingActionButton : FloatingActionButton(
        onPressed: () {
            setState(() => _fetchingData = true);
            _fetchLocalizacoes();
        },
        child: const Icon(Icons.refresh),
      )
      /*floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.pushNamed(context, SecondScreen.routeName, arguments: 69);
        },
        child: const Text('Locais de Interesse'),
      ), */// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
