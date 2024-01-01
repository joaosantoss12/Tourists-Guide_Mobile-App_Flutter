import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

import 'package:journey_buddy_flutter/second_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';


class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key});

  final String title = 'Historico';

  static const String routeName = '/HistoryScreen';

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}


class _HistoryScreenState extends State<HistoryScreen> {
  List<LocalInteresse>? _listaLocaisInteresse = [];
  bool _fetchingData = false;

  @override
  void initState() {
    super.initState();
    getHistory();
  }


  Future<void> getHistory() async {
    try {
      var prefs = await SharedPreferences.getInstance();
      List<String> jsonList = prefs.getStringList('listaLocaisInteresseHistorico_json') ?? [];

      _listaLocaisInteresse = jsonList
          .map((jsonString) => LocalInteresse.fromJson(jsonDecode(jsonString)))
          .toList();

    } catch (e) {
      print('Error loading history data: $e');
    }

    setState(() {
      _fetchingData = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Container(
          margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_fetchingData) const CircularProgressIndicator(),

            if (!_fetchingData && _listaLocaisInteresse != null && _listaLocaisInteresse!.isNotEmpty)
              Expanded(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: ListView.separated(
                    itemCount: _listaLocaisInteresse!.length,

                    separatorBuilder: (_, __) => const Divider(thickness: 2.0),

                    itemBuilder: (BuildContext context, int index) => Column(
                      children: [
                        Text(
                          _listaLocaisInteresse![index].nome ?? 'Nome null',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(
                          _listaLocaisInteresse![index].descricao ?? 'Descrição null',
                        ),
                        Text(
                          'Categoria: ${_listaLocaisInteresse![index].categoria ?? 'Categoria null'}',
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 15.0, bottom: 15.0), // Adjust the margin as needed
                          child: Image.network(
                            _listaLocaisInteresse![index].imagemURL ?? 'ImagemURL null',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
          ],
        ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() => _fetchingData = true);
          getHistory();
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }


}
