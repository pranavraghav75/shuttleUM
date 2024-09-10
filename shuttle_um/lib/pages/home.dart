import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Position? _currentPosition;
  LatLng? _center;
  static const LatLng _pGooglePlex = LatLng(38.989697, -76.937759);

  late GoogleMapController mapController;
  final TextEditingController _typeAheadController = TextEditingController();
  final String _googleApiKey = 'AIzaSyCFa8TxjkpBxKyhg45ix0eg2MsabZEiLWA';

  Marker? _selectedLocationMarker;
  Circle? _userLocationCircle;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _pGooglePlex, // Default location, can be updated later
              zoom: 14.0,
            ),
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
              if (_center != null) {
                _moveCameraToUserLocation();
              }
            },
            markers: {
              if (_selectedLocationMarker != null) _selectedLocationMarker!,
            },
            circles: {
              if (_userLocationCircle != null) _userLocationCircle!,
            },
            zoomControlsEnabled: false,
          ),
          Positioned(
              bottom: 20,
              right: 15,
              child: ElevatedButton(
                  onPressed: _moveCameraToUserLocation,
                  child: Icon(
                    Icons.assistant_navigation,
                    color: Colors.amber[400],
                    size: 45.0,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(5),
                  ))),
          Positioned(
              bottom: 20,
              left: 15,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/timings");
                  },
                  child: Icon(
                    Icons.bus_alert_rounded,
                    color: Colors.amber[400],
                    size: 45.0,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(8),
                  ))),
          Positioned(
            top: 60,
            left: 15,
            right: 15,
            child: TypeAheadField(
              textFieldConfiguration: TextFieldConfiguration(
                controller: _typeAheadController,
                decoration: InputDecoration(
                  hintText: 'Enter your destination',
                  hintStyle: const TextStyle(
                    color: Colors.white,
                  ),
                  fillColor: Colors.red,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(15),
                ),
              ),
              suggestionsCallback: (pattern) async {
                return await _getSuggestions(pattern);
              },
              itemBuilder: (context, suggestion) {
                return ListTile(
                  title: Text(suggestion['description']),
                );
              },
              onSuggestionSelected: (suggestion) {
                // Handle what happens when the user selects a suggestion
                _typeAheadController.text = suggestion['description'];
                _moveCameraToPlace(suggestion['place_id']);
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<List> _getSuggestions(String input) async {
    if (input.isEmpty) {
      return [];
    }
    final String url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$_googleApiKey&location=${_pGooglePlex.latitude},${_pGooglePlex.longitude}&radius=5000';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      return result['predictions'];
    } else {
      throw Exception('Failed to load suggestions');
    }
  }

  Future<void> _moveCameraToPlace(String placeId) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$_googleApiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      final location = result['result']['geometry']['location'];
      final LatLng newLatLng = LatLng(location['lat'], location['lng']);

      mapController.animateCamera(CameraUpdate.newLatLngZoom(newLatLng, 18.0));

      setState(() {
        _selectedLocationMarker = Marker(
          markerId: const MarkerId('selected-location'),
          position: newLatLng,
          infoWindow: InfoWindow(title: _typeAheadController.text),
        );
      });
    } else {
      throw Exception('Failed to load place details');
    }
  }

  _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    // Request permission to get the user's location
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return;
    }
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
    }

    // Get the current location of the user
    _currentPosition = await Geolocator.getCurrentPosition();
    setState(() {
      _center = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
      _userLocationCircle = Circle(
        circleId: const CircleId('user-location'),
        center: _center!,
        radius: 40, // Radius in meters
        fillColor: Colors.blue.shade700.withOpacity(0.8),
        strokeColor: Colors.blueGrey.shade200,
        strokeWidth: 6,
      );
    });

    _moveCameraToUserLocation();
  }

  void _moveCameraToUserLocation() {
    if (_center != null) {
      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(_center!, 15.4),
      );
    }
  }
}
