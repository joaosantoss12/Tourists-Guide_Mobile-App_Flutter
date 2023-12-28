import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

class LocalInteresse {
  var nome;
  var descricao;
  var latitude;
  var longitude;
  var imagemURL;
  var estado;
  var categoria;
}

class SecondScreen extends StatefulWidget {
  const SecondScreen({super.key});

  final String title = 'Locais de Interesse';

  static const String routeName = '/SecondScreen';

  @override
  State<SecondScreen> createState() => _SecondScreenState();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

class _SecondScreenState extends State<SecondScreen> {
  late String _nomeLocalizacao = ModalRoute.of(context)?.settings.arguments as String;
  List<LocalInteresse>? _listaLocaisInteresse = [];
  bool _fetchingData = false;


  // FIREBASE

  Future<void> _fetchLocaisInteresse() async {
    try {
      _listaLocaisInteresse!.clear();
      var db = FirebaseFirestore.instance;
      var collection = await db.collection('Localidades').doc(_nomeLocalizacao)
      .collection('Locais de Interesse').get();
      for (var doc in collection.docs) {
        var l = new LocalInteresse();
        l.nome = doc['nome'];
        l.descricao = doc['descrição'];
        l.categoria = doc['categoria'];
        l.latitude = (doc['coordenadas'] as GeoPoint).latitude;
        l.longitude = (doc['coordenadas'] as GeoPoint).longitude;
        l.imagemURL = doc['imagemURL'];
        l.estado = doc['estado'];

        _listaLocaisInteresse!.add(l);
      }
    }
    catch (ex) {
      debugPrint('Something went wrong: $ex');
    }
    finally {
      setState(() => _fetchingData = false);
    }
  }

  // END FIREBASE


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(

          backgroundColor: Theme
              .of(context)
              .colorScheme
              .inversePrimary,

          title: Text(widget.title),
        ),
        body: Center(

          child: Column(

            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

              if (_fetchingData) const CircularProgressIndicator(),

              if (!_fetchingData && _listaLocaisInteresse != null &&
                  _listaLocaisInteresse!.isNotEmpty)
                SizedBox(
                    height: MediaQuery
                        .of(context)
                        .size
                        .height * 0.75,
                    width: MediaQuery
                        .of(context)
                        .size
                        .width * 0.8,
                    child: ListView.separated(
                      itemCount: _listaLocaisInteresse!.length,
                      separatorBuilder: (_, __) =>
                      const Divider(thickness: 2.0),
                      itemBuilder: (BuildContext context, int index) =>
                          Column(
                            children: [
                              Text(
                                _listaLocaisInteresse![index].nome,
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .headlineMedium,
                              ),
                        Text(
                          _listaLocaisInteresse![index].descricao,
                        ),
                        Text(
                            _listaLocaisInteresse![index].categoria,
                        ),
                        /*Text(
                        _listaLocalizacoes![index].latitude.toString(),
                      ),
                      Text(
                        _listaLocalizacoes![index].longitude.toString(),
                      ),*/
                        /*Text(
                        _listaLocalizacoes![index].imagemURL,
                      ),*/
                        Image.network(
                          _listaLocaisInteresse![index].imagemURL,
                          width: MediaQuery.of(context).size.height * 0.7,
                          height: MediaQuery.of(context).size.height * 0.5,
                        ),
                        /*Text(
                        _listaLocalizacoes![index].estado,
                      ),*/
                      Container(
                        width: MediaQuery.of(context).size.width * 0.35,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            ElevatedButton(
                              onPressed: () {
                                // Handle the onPressed for the first button
                              },
                              child: Text('Gosto'),
                            ),

                            Spacer(),

                            ElevatedButton(
                              onPressed: () {

                              },
                              child: Text('Não Gosto'),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
                ),
            ],
          ),
        ),

        floatingActionButton : FloatingActionButton(
          onPressed: () {
            setState(() => _fetchingData = true);
            _fetchLocaisInteresse();
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