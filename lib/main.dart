import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:location/location.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

import 'second_screen.dart';

void initFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

void main() {
  // Ensure that Flutter is initialized before Firebase
  WidgetsFlutterBinding.ensureInitialized();
  initFirebase();
  runApp(const MyApp());
}


class Localizacao{
    var nome;
    var descricao;
    var latitude;
    var longitude;
    var imagemURL;
    var estado;
}

class LocalInteresse{

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


  @override
  void initState() {
    super.initState();
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

    void listDocuments() async {
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

            _listaLocalizacoes?.add(l);
        }
    }

  // END FIREBASE

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

            if (_fetchingData) const CircularProgressIndicator(),

            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              _listaLocalizacoes!.length.toString(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),

            if (!_fetchingData && _listaLocalizacoes != null && _listaLocalizacoes!.isNotEmpty)
              SizedBox(height: 200,
                child: ListView.separated(
                  itemCount: _listaLocalizacoes!.length,
                  separatorBuilder: (_, __) => const Divider(thickness: 2.0),
                  itemBuilder: (BuildContext context, int index) => Column(
                    children: [
                      Text(
                        _listaLocalizacoes![index].nome,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Text(
                        _listaLocalizacoes![index].descricao,
                      ),
                        Text(
                            _listaLocalizacoes![index].latitude.toString(),
                        ),
                        Text(
                            _listaLocalizacoes![index].longitude.toString(),
                        ),
                        Text(
                            _listaLocalizacoes![index].imagemURL,
                        ),
                        Text(
                            _listaLocalizacoes![index].estado,
                        ),

                    ],
                  ),
                ),
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
