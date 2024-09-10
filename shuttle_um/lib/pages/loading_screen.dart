import 'package:flutter/material.dart';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  void initState() {
    super.initState();
    // Use Future.delayed to navigate to the home screen after 2 seconds
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, "/home");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[900],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_bus_rounded,
              size: 100.0,
              color: Colors.amber[400],
            ),
            Text(
              "SHUTTLE-UM",
              style: TextStyle(
                color: Colors.amber[400],
                fontSize: 40.0,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
