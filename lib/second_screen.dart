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
  var numGostos;
  var numNaoGostos;

  Color _LikeButtonColor;
  Color _DislikeButtonColor;

  LocalInteresse() : _LikeButtonColor = Colors.blue, _DislikeButtonColor = Colors.blue;
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

  String? _currentLocalInteresse = null;

  String? _error = null;


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

        // Check if 'numGostos' exists, otherwise set it to 0
        l.numGostos = doc.data().containsKey('numGostos') ? doc['numGostos'] : 0;

        // Check if 'numNaoGostos' exists, otherwise set it to 0
        l.numNaoGostos = doc.data().containsKey('numNaoGostos') ? doc['numNaoGostos'] : 0;

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


  void addLike() async{
    var db = FirebaseFirestore.instance;
    var document = db.collection('Localidades').doc(_nomeLocalizacao).collection('Locais de Interesse').doc(_currentLocalInteresse);
    var data = await document.get(const GetOptions(source: Source.server));
    if (data.exists) {
      var numGostos = data.data()!.containsKey('numGostos') ? data['numGostos'] + 1 : 1;
      document.update({'numGostos': numGostos}).then(
              (res) => setState(() { _error = null; }),
          onError: (e) => setState(() { _error = e.toString();})
      );
    }
    else {
      setState(() { _error = "Document doesn't exist";});
    }
  }

  void removeLike(){

  }

  void addDislike(){

  }
  void removeDislike(){

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

              if (_error != null) Text("Error: $_error"),

              if (!_fetchingData && _listaLocaisInteresse != null && _listaLocaisInteresse!.isNotEmpty)
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

                            Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                            if(_listaLocaisInteresse![index]._LikeButtonColor == Colors.green){
                                                _listaLocaisInteresse![index]._LikeButtonColor = Colors.blue;
                                            }
                                            else{
                                                _currentLocalInteresse= _listaLocaisInteresse![index].nome;
                                                addLike();
                                                _listaLocaisInteresse![index]._LikeButtonColor = Colors.green;
                                                _listaLocaisInteresse![index]._DislikeButtonColor = Colors.blue;
                                            }
                                        });
                                      },
                                      child: Text('Gosto'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _listaLocaisInteresse![index]._LikeButtonColor,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),

                                    Text(
                                      _listaLocaisInteresse![index].numGostos.toString(),
                                    ),
                                ],
                              ),
                            ),

                            Spacer(),

                            Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: <Widget>[
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                        if(_listaLocaisInteresse![index]._DislikeButtonColor == Colors.red){
                                           _listaLocaisInteresse![index]._DislikeButtonColor = Colors.blue;
                                        }
                                        else{
                                            _listaLocaisInteresse![index]._DislikeButtonColor = Colors.red;
                                            _listaLocaisInteresse![index]._LikeButtonColor = Colors.blue;
                                        }
                                    });
                                  },
                                  child: Text('Não Gosto'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _listaLocaisInteresse![index]._DislikeButtonColor,
                                    foregroundColor: Colors.white,
                                  ),
                                ),

                                Text(
                                   _listaLocaisInteresse![index].numNaoGostos.toString(),
                                ),
                            ],
                            ),
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