import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'firebase_options.dart';

import 'package:shared_preferences/shared_preferences.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  final String title = 'Mapa';

  static const String routeName = '/MapScreen';


  @override
  State<MapScreen> createState() => _MapScreenState();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

class _MapScreenState extends State<MapScreen> {
  late double latitude;
  late double longitude;

  late String apiKey;
  late String mapImageUrl;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Accessing arguments in didChangeDependencies
    Map<String, dynamic> arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    latitude = arguments['latitude']!.toDouble();
    longitude = arguments['longitude']!.toDouble();

    apiKey = "AIzaSyCQd4PR7D_4NNKCIwufCQG7cbVXEZs4PMU";
    mapImageUrl = getMapImageUrl();
  }

  String getMapImageUrl() {
    const String baseUrl = "https://maps.googleapis.com/maps/api/staticmap";
    final String markers = "markers=$latitude,$longitude";

    return "$baseUrl?center=$latitude,$longitude&zoom=10&size=500x500&$markers&key=$apiKey";
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
