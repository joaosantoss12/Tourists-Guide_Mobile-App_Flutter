import 'package:flutter/material.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  final String title = 'Mapa';

  static const String routeName = '/MapScreen';


  @override
  State<MapScreen> createState() => _MapScreenState();

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}

class _MapScreenState extends State<MapScreen> {
  late double latitude;
  late double longitude;
  late String tipo;

  late String apiKey;
  late String mapImageUrl;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    Map<String, dynamic> arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    latitude = arguments['latitude']!.toDouble();
    longitude = arguments['longitude']!.toDouble();
    tipo = arguments['tipo'];

    apiKey = "AIzaSyCQd4PR7D_4NNKCIwufCQG7cbVXEZs4PMU";
    mapImageUrl = getMapImageUrl();
  }

  String getMapImageUrl() {
    var parameters;
    if(tipo == "Localização"){
      parameters = "zoom=10&size=500x500";
    }
    else{
      parameters = "zoom=15&size=500x500";
    }

    const String baseUrl = "https://maps.googleapis.com/maps/api/staticmap";
    final String markers = "markers=$latitude,$longitude";

    return "$baseUrl?center=$latitude,$longitude&$parameters&$markers&key=$apiKey";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Image.network(mapImageUrl),
      ),
    );
  }
}