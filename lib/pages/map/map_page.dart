import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/welcome_page.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:geolocator/geolocator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

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
        _errorMessage =
            'Les services de localisation sont désactivés. Position par défaut utilisée.';
      });
      _setDefaultLocation();
      return;
    }

    permission = await Geolocator.requestPermission();
    print("Permission demandée: $permission");

    if (permission == LocationPermission.denied) {
      setState(() {
        _errorMessage =
            'Permission de localisation refusée. Position par défaut utilisée.';
      });
      _setDefaultLocation();
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _errorMessage =
            'Permission de localisation refusée définitivement. Veuillez activer manuellement dans les paramètres.';
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
        _errorMessage =
            'Erreur lors de la récupération de la position. Position par défaut utilisée.';
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
          content: Text(
              'Veuillez activer les services de localisation dans les paramètres de l\'appareil.'),
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
        title: Text(
          AppLocalizations.of(context)!.mapTitle,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => WelcomePage()),
            );
          },
        ),
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
            if (!snapshot.hasData)
              return Center(child: CircularProgressIndicator());

            final camions = snapshot.data!.docs;
            List<Marker> markers = [];

            for (var camion in camions) {
              final data = camion.data();
              if (data.containsKey('latitude') &&
                  data.containsKey('longitude')) {
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
                                  Text('Camion ${data["name"]}',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(height: 10),
                                  Text('Statut: ${data["status"]}',
                                      style: TextStyle(fontSize: 16)),
                                  SizedBox(height: 10),
                                  ElevatedButton(
                                    onPressed: () async {
                                      String googleMapsUrl =
                                          "https://www.google.com/maps/search/?api=1&query=${data['latitude']},${data['longitude']}";
                                      if (await canLaunchUrl(
                                          Uri.parse(googleMapsUrl))) {
                                        await launchUrl(
                                            Uri.parse(googleMapsUrl));
                                      } else {
                                        print('Could not open the map.');
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Impossible d\'ouvrir la carte.'),
                                              backgroundColor: Colors.red),
                                        );
                                      }
                                    },
                                    child: Text(AppLocalizations.of(context)!
                                        .viewOnGoogleMaps),
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
                            child: Icon(Icons.local_shipping,
                                color: Colors.blue, size: 40.0),
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
                center: LatLng(
                    _currentPosition?.latitude ?? _defaultLocation.latitude,
                    _currentPosition?.longitude ?? _defaultLocation.longitude),
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
          child: SearchBar(mapController: _mapController),
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
                heroTag: 'zoom_in_button',
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
                heroTag: 'zoom_out_button',
              ),
              SizedBox(height: 10),
              FloatingActionButton(
                heroTag: 'dark_mode_button',
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

class SearchBar extends StatefulWidget {
  final MapController mapController;

  SearchBar({required this.mapController});

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isLoading = false;

  Future<void> _search(String query) async {
    setState(() {
      _isLoading = true;
      _searchResults = [];
    });

    if (query.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          _searchResults = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        print('Erreur de requête: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Erreur: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

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
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.searchLocationPlaceholder,
              prefixIcon: Icon(Icons.search),
              suffixIcon: _isLoading
                  ? CircularProgressIndicator()
                  : IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchResults = [];
                        });
                      },
                    ),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
            ),
            onChanged: (value) {
              _search(value);
            },
          ),
          if (_searchResults.isNotEmpty)
            Container(
              height: 200,
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final result = _searchResults[index];
                  return ListTile(
                    title: Text(result['display_name']),
                    onTap: () {
                      final latitude = double.parse(result['lat']);
                      final longitude = double.parse(result['lon']);
                      widget.mapController
                          .move(LatLng(latitude, longitude), 14.0);

                      print('Lieu sélectionné: ${result['display_name']}');
                      print(
                          'Latitude: ${result['lat']}, Longitude: ${result['lon']}');

                      setState(() {
                        _searchResults = [];
                        _searchController.clear();
                      });
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class ZoomButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String tooltip;
  final String heroTag;

  ZoomButton({
    required this.onTap,
    required this.icon,
    required this.tooltip,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: heroTag,
      onPressed: onTap,
      tooltip: tooltip,
      child: Icon(icon),
    );
  }
}
