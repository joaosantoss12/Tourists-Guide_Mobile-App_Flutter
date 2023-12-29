import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'firebase_options.dart';

import 'package:shared_preferences/shared_preferences.dart';

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

  var distancia;

  late Color _LikeButtonColor;
  late Color _DislikeButtonColor;

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'descricao': descricao,
      'latitude': latitude,
      'longitude': longitude,
      'imagemURL': imagemURL,
      'estado': estado,
      'categoria': categoria,
    };
  }

  LocalInteresse.create();

  LocalInteresse.fromJson(Map  json)
      : nome = json['nome'],
        descricao = json['descricao'],
        latitude = json['latitude'],
        longitude = json['longitude'],
        imagemURL = json['imagemURL'],
        estado = json['estado'],
        categoria = json['categoria'];

}

class Categoria{
  var nome;
  var imagemURL;
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
  List<String> _historicoLocaisInteresse_json = [];
  List<Categoria>? _listaCategorias = [];
  bool _fetchingData = false;

  String? currentCategoria;

  String dropdownValue = 'none';
  List<String> list = ['A-Z', 'Z-A', 'Distância ▲', 'Distância ▼'];

  String? _currentLocalInteresse;

  String? _error;

  @override
  void initState() {
    super.initState();
    location.getLocation();
    _fetchCategorias();
    _fetchLocaisInteresse();
  }

  // CUSTOM WIDGET PARA IMPRIMIR UM LOCAL DE INTERESSE
  Widget buildLocalInterestItem(List<LocalInteresse>? _listaLocaisInteresse, int index) {
    return Column(
      children: <Widget>[
        Text(
          _listaLocaisInteresse![index].nome,
          style: Theme
              .of(context)
              .textTheme
              .headlineSmall,
        ),

        ElevatedButton(
          onPressed: () async {
            showDialog(
              context: context,
              builder: (BuildContext context) =>
                  _buildPopupDialog(context, index),
            );

            if (_historicoLocaisInteresse_json.length ==
                10) {
              _historicoLocaisInteresse_json.removeAt(0);
            }

            var serializedObject = jsonEncode(
                _listaLocaisInteresse![index].toJson());

            _historicoLocaisInteresse_json.add(
                serializedObject);

            var prefs = await SharedPreferences
                .getInstance();
            await prefs.setStringList(
                "listaLocaisInteresseHistorico_json",
                _historicoLocaisInteresse_json);
          },
          child: const Text('Ver Mais'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),

        ),

        Container(
          margin: EdgeInsets.only(
              top: 10.0, bottom: 10.0),
          // Adjust the margin as needed
          child: Image.network(
            _listaLocaisInteresse![index].imagemURL,
          ),
        ),

        Container(
          width: MediaQuery
              .of(context)
              .size
              .width * 0.7,
          child: Row(
            mainAxisAlignment: MainAxisAlignment
                .spaceBetween,
            children: <Widget>[

              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment
                      .spaceBetween,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _currentLocalInteresse =
                              _listaLocaisInteresse![index]
                                  .nome;

                          if (_listaLocaisInteresse![index]
                              ._LikeButtonColor ==
                              Colors.green) {
                            removeLike(index, true);
                          }
                          else {
                            if (_listaLocaisInteresse![index]
                                ._DislikeButtonColor ==
                                Colors.red) {
                              removeDislike(index, false);
                            }

                            addLike(index, true);
                          }
                        });
                      },
                      child: Text('Gosto'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _listaLocaisInteresse![index]
                            ._LikeButtonColor,
                        foregroundColor: Colors.white,
                      ),
                    ),

                    Text(
                      _listaLocaisInteresse![index]
                          .numGostos.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Spacer(),

              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment
                      .spaceBetween,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _currentLocalInteresse =
                              _listaLocaisInteresse![index]
                                  .nome;
                          if (_listaLocaisInteresse![index]
                              ._DislikeButtonColor ==
                              Colors.red) {
                            removeDislike(index, true);
                          }
                          else {
                            if (_listaLocaisInteresse![index]
                                ._LikeButtonColor ==
                                Colors.green) {
                              removeLike(index, false);
                            }

                            addDislike(index, true);
                          }
                        });
                      },
                      child: Text('Não Gosto'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _listaLocaisInteresse![index]
                            ._DislikeButtonColor,
                        foregroundColor: Colors.white,
                      ),
                    ),

                    Text(
                      _listaLocaisInteresse![index]
                          .numNaoGostos.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }



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


  // FIREBASE

  Future<void> _fetchCategorias() async{
    try {
      _listaCategorias!.clear();
      var db = FirebaseFirestore.instance;
      var collection = await db.collection('Categorias').get();
      for (var doc in collection.docs) {
        var categoria = Categoria();
        categoria.nome = doc['nome'];
        categoria.imagemURL = doc['imagemURL'];
        _listaCategorias!.add(categoria);
      }
    }
    catch (ex) {
      debugPrint('Something went wrong: $ex');
    }
  }

  Future<void> _fetchLocaisInteresse() async {
    var prefs = await SharedPreferences.getInstance();
    _historicoLocaisInteresse_json = prefs.getStringList('listaLocaisInteresseHistorico_json') ?? [];
    try {
      _listaLocaisInteresse!.clear();
      var db = FirebaseFirestore.instance;
      var collection = await db.collection('Localidades').doc(_nomeLocalizacao)
      .collection('Locais de Interesse').get();
      for (var doc in collection.docs) {
        var l = LocalInteresse.create();

        l.nome = doc['nome'];
        l.descricao = doc['descrição'];
        l.categoria = doc['categoria'];
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

        l.distancia = distanceX+distanceY;

        // Check if 'numGostos' exists, otherwise set it to 0
        l.numGostos = doc.data().containsKey('numGostos') ? doc['numGostos'] : 0;

        // Check if 'numNaoGostos' exists, otherwise set it to 0
        l.numNaoGostos = doc.data().containsKey('numNaoGostos') ? doc['numNaoGostos'] : 0;

        var prefs = await SharedPreferences.getInstance();
        setState (() {
          l._LikeButtonColor = prefs.getInt (l.nome+"like") == 1 ? Colors.green : Colors.blueGrey;
          l._DislikeButtonColor = prefs.getInt (l.nome+"dislike") == 1 ? Colors.red : Colors.blueGrey;
        });


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


  Future<void> addLike(int index, bool refresh) async{
    var prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_listaLocaisInteresse![index].nome+"like", 1);
    await prefs.setInt(_listaLocaisInteresse![index].nome+"dislike", 0);

    var db = FirebaseFirestore.instance;
    var document = db.collection('Localidades').doc(_nomeLocalizacao).collection('Locais de Interesse').doc(_currentLocalInteresse);
    var data = await document.get(const GetOptions(source: Source.server));
    if (data.exists) {
      var numGostos = data.data()!.containsKey('numGostos') ? data['numGostos'] + 1 : 1;
      document.update({'numGostos': numGostos}).then(
              (res) => setState(() {
                _error = null;
                if(refresh) {
                  _fetchLocaisInteresse();
                }
              }),
          onError: (e) => setState(() { _error = e.toString();})
      );
    }
    else {
      setState(() { _error = "Document doesn't exist";});
    }
  }

  Future<void> removeLike(int index, bool refresh) async{
    var prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_listaLocaisInteresse![index].nome+"like", 0); // COR DEFAULT

    var db = FirebaseFirestore.instance;
    var document = db.collection('Localidades').doc(_nomeLocalizacao).collection('Locais de Interesse').doc(_currentLocalInteresse);
    var data = await document.get(const GetOptions(source: Source.server));
    if (data.exists) {
      var numGostos = data.data()!.containsKey('numGostos') ? data['numGostos'] - 1 : 1;
      document.update({'numGostos': numGostos}).then(
              (res) => setState(() {
                _error = null;
                if(refresh) {
                  _fetchLocaisInteresse();
                }
              }),
          onError: (e) => setState(() { _error = e.toString();})
      );
    }
    else {
      setState(() { _error = "Document doesn't exist";});
    }
  }

  Future<void> addDislike(int index, bool refresh) async{

    var prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_listaLocaisInteresse![index].nome+"dislike", 1);
    await prefs.setInt(_listaLocaisInteresse![index].nome+"like", 0);

    var db = FirebaseFirestore.instance;
        var document = db.collection('Localidades').doc(_nomeLocalizacao).collection('Locais de Interesse').doc(_currentLocalInteresse);
        var data = await document.get(const GetOptions(source: Source.server));
        if (data.exists) {
          var numGostos = data.data()!.containsKey('numNaoGostos') ? data['numNaoGostos'] + 1 : 1;
          document.update({'numNaoGostos': numGostos}).then(
                  (res) => setState(() {
                    _error = null;
                    if(refresh) {
                      _fetchLocaisInteresse();
                    }
                  }),
              onError: (e) => setState(() { _error = e.toString();})
          );
        }
        else {
          setState(() { _error = "Document doesn't exist";});
        }

  }
  Future<void> removeDislike(int index, bool refresh) async{
    var prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_listaLocaisInteresse![index].nome+"dislike", 0);

    var db = FirebaseFirestore.instance;
    var document = db.collection('Localidades').doc(_nomeLocalizacao).collection('Locais de Interesse').doc(_currentLocalInteresse);
    var data = await document.get(const GetOptions(source: Source.server));
    if (data.exists) {
      var numNaoGostos = data.data()!.containsKey('numNaoGostos') ? data['numNaoGostos'] - 1 : 1;
      document.update({'numNaoGostos': numNaoGostos}).then(
              (res) => setState(() {
                _error = null;
                if(refresh) {
                  _fetchLocaisInteresse();
                }
              }),
          onError: (e) => setState(() { _error = e.toString();})
      );
    }
    else {
      setState(() { _error = "Document doesn't exist";});
    }
  }

  // END FIREBASE


  // POPUP
  Widget _buildPopupDialog(BuildContext context, int index) {
    return Container(
        child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
        AlertDialog(
          title: Text(_listaLocaisInteresse![index].nome),
          content: Column(
          children: <Widget>[
            Image.network(
              _listaLocaisInteresse![index].imagemURL,
            ),

            Text("Descrição: ${_listaLocaisInteresse![index].descricao}"),
            Text("Categoria: ${_listaLocaisInteresse![index].categoria}"),
            Text("Latitude: ${_listaLocaisInteresse![index].latitude.toString()}"),
            Text("Longitude: ${_listaLocaisInteresse![index].longitude.toString()}"),

        ],
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Fechar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    ),
    ],
        ),
    );
  }


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

              if(!_fetchingData && _listaLocaisInteresse!.isNotEmpty && _listaCategorias!.isNotEmpty)
                Container(
                  margin: EdgeInsets.only(top: 10.0), // Adjust the margin as needed
                child : DropdownMenu<String>(
                  initialSelection: dropdownValue,
                  onSelected: (String? value) {
                    setState(() {
                      dropdownValue = value!;
                      switch(dropdownValue){
                        case 'A-Z':
                          _listaLocaisInteresse!.sort((a, b) => a.nome.compareTo(b.nome));
                          break;
                        case 'Z-A':
                          _listaLocaisInteresse!.sort((a, b) => b.nome.compareTo(a.nome));
                          break;
                        case 'Distância ▲':
                          _listaLocaisInteresse!.sort((a, b) => a.distancia.compareTo(b.distancia));
                          break;
                        case 'Distância ▼':
                          _listaLocaisInteresse!.sort((a, b) => b.distancia.compareTo(a.distancia));
                          break;
                      }
                    });
                  },
                  dropdownMenuEntries: list.map<DropdownMenuEntry<String>>((String value) {
                    return DropdownMenuEntry<String>(value: value, label: value);
                  }).toList(),
                ),
                ),


              if (!_fetchingData && _listaCategorias != null && _listaCategorias!.isNotEmpty)
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.15,
                  child: Container(
                    child: ListView.builder(
                      itemCount: _listaCategorias!.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) => GestureDetector(
                        onTap: () {
                          setState(() {
                            currentCategoria = _listaCategorias![index].nome;
                          });
                          //_fetchCategorias();
                          //_fetchLocaisInteresse();
                        },
                        child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(_listaCategorias?[index].imagemURL), // replace with your image URL
                            fit: BoxFit.cover,
                          ),
                        ),
                        height: 50,
                        width: 100,
                        margin: EdgeInsets.all(15),
                        child: Center(
                          child: Text(
                            _listaCategorias?[index].nome,
                            style: const TextStyle(color: Colors.white, fontSize: 12,fontWeight: FontWeight.bold, shadows: [
                              Shadow(
                                blurRadius: 10.0,
                                color: Colors.black,
                                offset: Offset(5.0, 5.0),
                              ),
                            ]
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                ),
                ),
                //),



              if (_fetchingData) const CircularProgressIndicator(),

              if (_error != null) Text("Error: $_error"),

              if (!_fetchingData && _listaLocaisInteresse != null && _listaLocaisInteresse!.isNotEmpty)
                Expanded(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: ListView.separated(
                      itemCount: _listaLocaisInteresse!.length,

                      separatorBuilder: (_, __) => Container(
                        margin: const EdgeInsets.only(top: 10.0, bottom: 10.0), // Adjust the margin as needed
                        child: const Divider(thickness: 2.0),
                      ),

                      itemBuilder: (BuildContext context, int index) {
                        if(currentCategoria != null && _listaLocaisInteresse![index].categoria == currentCategoria) {
                          return buildLocalInterestItem(_listaLocaisInteresse, index);
                        }
                        else if(currentCategoria == null){
                          return buildLocalInterestItem(_listaLocaisInteresse, index);
                        }
                        else {
                          return Container();
                        }
                      }
                )
                ),
                ),
            ],
          ),
        ),


        floatingActionButton : FloatingActionButton(
          onPressed: () {
            setState(() => _fetchingData = true);
            _fetchCategorias();
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