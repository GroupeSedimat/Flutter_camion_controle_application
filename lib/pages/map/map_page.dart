import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bottom_sheet/bottom_sheet.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Position? _currentPosition;
  final LatLng _defaultLocation = LatLng(45.17118, 5.68718);
  String? _errorMessage;
  double _zoomLevel = 14.0;
  bool _isDarkMode = false;
  MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await Firebase.initializeApp();
    await _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationServiceDisabledDialog();
      setState(() {
        _errorMessage = 'Les services de localisation sont désactivés. Position par défaut utilisée.';
      });
      _setDefaultLocation();
      return;
    }

    permission = await Geolocator.requestPermission();
    print("Permission demandée: $permission");

    if (permission == LocationPermission.denied) {
      setState(() {
        _errorMessage = 'Permission de localisation refusée. Position par défaut utilisée.';
      });
      _setDefaultLocation();
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _errorMessage = 'Permission de localisation refusée définitivement. Veuillez activer manuellement dans les paramètres.';
      });
      openAppSettings();
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      setState(() {
        _currentPosition = position;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la récupération de la position. Position par défaut utilisée.';
        _setDefaultLocation();
      });
    }
  }

  void _showLocationServiceDisabledDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Services de localisation désactivés'),
          content: Text('Veuillez activer les services de localisation dans les paramètres de l\'appareil.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _setDefaultLocation() {
    _currentPosition = Position(
      latitude: _defaultLocation.latitude,
      longitude: _defaultLocation.longitude,
      timestamp: DateTime.now(),
      accuracy: 1.0,
      altitude: 0.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
      headingAccuracy: 0.0,
      altitudeAccuracy: 0.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Carte Map'),
      ),
      body: _currentPosition == null
          ? Center(child: CircularProgressIndicator())
          : _buildMap(),
    );
  }

  Widget _buildMap() {
    return Stack(
      children: [
        StreamBuilder(
          stream: FirebaseFirestore.instance.collection('camion').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

            final camions = snapshot.data!.docs;
            List<Marker> markers = [];

            for (var camion in camions) {
              final data = camion.data();
              if (data.containsKey('latitude') && data.containsKey('longitude')) {
                markers.add(
                  Marker(
                    point: LatLng(data['latitude'], data['longitude']),
                    builder: (ctx) => GestureDetector(
                      onTap: () {
                        showFlexibleBottomSheet(
                          minHeight: 0,
                          initHeight: 0.2,
                          maxHeight: 0.8,
                          context: context,
                          builder: (context, controller, offset) {
                            return Container(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Camion ${data["name"]}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                  SizedBox(height: 10),
                                  Text('Statut: ${data["status"]}', style: TextStyle(fontSize: 16)),
                                  SizedBox(height: 10),
                                  ElevatedButton(
                                    onPressed: () async {
                                      String googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=${data['latitude']},${data['longitude']}";
                                      if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
                                        await launchUrl(Uri.parse(googleMapsUrl));
                                      } else {
                                        throw 'Could not open the map.';
                                      }
                                    },
                                    child: Text('Voir sur Google Maps'),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: Duration(seconds: 2),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Icon(Icons.local_shipping, color: Colors.blue, size: 40.0),
                          );
                        },
                      ),
                    ),
                  ),
                );
              }
            }

            return FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: LatLng(_currentPosition?.latitude ?? _defaultLocation.latitude, _currentPosition?.longitude ?? _defaultLocation.longitude),
                zoom: _zoomLevel,
              ),
              children: [
                TileLayer(
                  urlTemplate: _isDarkMode
                      ? "https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png"
                      : "https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(markers: markers),
              ],
            );
          },
        ),
        Positioned(
          top: 20,
          left: 10,
          right: 10,
          child: SearchBar(),
        ),
        Positioned(
          bottom: 80,
          left: 10,
          child: Container(
            padding: EdgeInsets.all(8),
            color: Colors.red,
            child: Text(
              _errorMessage ?? '',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        Positioned(
          bottom: 160,
          right: 10,
          child: Column(
            children: [
              ZoomButton(
                onTap: () {
                  setState(() {
                    if (_zoomLevel < 18.0) {
                      _zoomLevel++;
                      _mapController.move(_mapController.center, _zoomLevel);
                    }
                  });
                },
                icon: Icons.zoom_in,
                tooltip: 'Zoom In',
              ),
              SizedBox(height: 10),
              ZoomButton(
                onTap: () {
                  setState(() {
                    if (_zoomLevel > 1) {
                      _zoomLevel--;
                      _mapController.move(_mapController.center, _zoomLevel);
                    }
                  });
                },
                icon: Icons.zoom_out,
                tooltip: 'Zoom Out',
              ),
              SizedBox(height: 10),
              FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _isDarkMode = !_isDarkMode;
                  });
                },
                tooltip: 'Activer/désactiver le mode sombre',
                child: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Rechercher un lieu',
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class ZoomButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String tooltip;

  ZoomButton({required this.onTap, required this.icon, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onTap,
      tooltip: tooltip,
      child: Icon(icon),
    );
  }
}
