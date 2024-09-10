import 'package:flutter/material.dart';
import 'dart:math';
import 'package:http/http.dart' as http;

class BusTiming extends StatelessWidget {
  const BusTiming({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Positioned(
            bottom: 20,
            left: 15,
            child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/home");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(8),
                ),
                child: Transform.rotate(
                  angle: pi,
                  child: Icon(
                    Icons.exit_to_app_rounded,
                    color: Colors.amber[400],
                    size: 45.0,
                  ),
                ))),
      ],
    ));
  }
}
