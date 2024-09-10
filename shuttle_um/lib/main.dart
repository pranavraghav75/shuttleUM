import 'package:flutter/material.dart';
import 'pages/loading_screen.dart';
import 'pages/home.dart';
import 'pages/bus_timings.dart';

void main() {
  runApp(MaterialApp(initialRoute: "/loading", routes: {
    "/loading": (context) => Loading(),
    "/home": (context) => Home(),
    '/timings': (context) => BusTiming(),
  }));
}
