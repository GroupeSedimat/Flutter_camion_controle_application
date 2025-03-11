// // ignore_for_file: prefer_const_literals_to_create_immutables, library_private_types_in_public_api, use_key_in_widget_constructors, prefer_final_fields
//
// import 'package:flutter/material.dart';
// import 'package:flutter_application_1/pages/base_page.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// class MapPage extends StatefulWidget {
//   @override
//   _MapPageState createState() => _MapPageState();
// }
//
// class _MapPageState extends State<MapPage> {
//   Position? _currentPosition;
//   final LatLng _defaultLocation = LatLng(45.17118, 5.68718);
//   String? _errorMessage;
//   double _zoomLevel = 14.0;
//   bool _isDarkMode = false;
//   MapController _mapController = MapController();
//
//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//   }
//
//   Future<void> _getCurrentLocation() async {
//     bool serviceEnabled;
//     LocationPermission permission;
//
//     // Vérifier si les services de localisation sont activés
//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       // Afficher un message d'alerte pour informer l'utilisateur que les services de localisation sont désactivés
//       _showLocationServiceDisabledDialog();
//
//       setState(() {
//         _errorMessage = 'Les services de localisation sont désactivés. Position par défaut utilisée.';
//       });
//       _setDefaultLocation();
//       return;
//     }
//
//     // Demander la permission de localisation
//     permission = await Geolocator.requestPermission();
//     print("Permission demandée: $permission");
//
//     if (permission == LocationPermission.denied) {
//       setState(() {
//         _errorMessage = 'Permission de localisation refusée. Position par défaut utilisée.';
//       });
//       _setDefaultLocation();
//       return;
//     }
//
//     if (permission == LocationPermission.deniedForever) {
//       setState(() {
//         _errorMessage = 'Permission de localisation refusée définitivement. Veuillez activer manuellement dans les paramètres.';
//       });
//       openAppSettings();
//       return;
//     }
//
//     // Si la permission est accordée, obtenir la localisation actuelle
//     try {
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.best,
//       );
//       setState(() {
//         _currentPosition = position;
//         _errorMessage = null;
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Erreur lors de la récupération de la position. Position par défaut utilisée.';
//         _setDefaultLocation();
//       });
//     }
//   }
//
//   // Méthode pour afficher un dialogue lorsque les services de localisation sont désactivés
//   void _showLocationServiceDisabledDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Services de localisation désactivés'),
//           content: Text('Veuillez activer les services de localisation dans les paramètres de l\'appareil.'),
//           actions: <Widget>[
//             TextButton(
//               child: Text('OK'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   // Méthode pour définir la position par défaut
//   void _setDefaultLocation() {
//     _currentPosition = Position(
//       latitude: _defaultLocation.latitude,
//       longitude: _defaultLocation.longitude,
//       timestamp: DateTime.now(),
//       accuracy: 1.0,
//       altitude: 0.0,
//       heading: 0.0,
//       speed: 0.0,
//       speedAccuracy: 0.0,
//       headingAccuracy: 0.0,
//       altitudeAccuracy: 0.0,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BasePage(
//       title: 'Carte Map',
//       body: _currentPosition == null
//           ? Center(child: CircularProgressIndicator())
//           : _buildMap(),
//     );
//   }
//
//   // Méthode pour construire la carte
//   Widget _buildMap() {
//     return Stack(
//       children: [
//         FlutterMap(
//           mapController: _mapController,
//           options: MapOptions(
//             center: LatLng(_currentPosition?.latitude ?? _defaultLocation.latitude,
//                           _currentPosition?.longitude ?? _defaultLocation.longitude),
//             zoom: _zoomLevel,
//           ),
//           children: [
//             TileLayer(
//               urlTemplate: _isDarkMode
//                   ? "https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png"
//                   : "https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png",
//               subdomains: ['a', 'b', 'c'],
//
//             ),
//             MarkerLayer(
//               markers: [
//                 Marker(
//                   point: LatLng(_currentPosition?.latitude ?? _defaultLocation.latitude,
//                                 _currentPosition?.longitude ?? _defaultLocation.longitude),
//                   builder: (ctx) => Icon(
//                     Icons.location_on,
//                     color: Colors.red,
//                     size: 40.0,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//
//         // Affichage du message d'erreur s'il existe
//         if (_errorMessage != null)
//           Positioned(
//             top: 20,
//             left: 10,
//             child: Container(
//               padding: EdgeInsets.all(8),
//               color: Colors.red,
//               child: Text(
//                 _errorMessage!,
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//           ),
//
//         // Bouton pour rafraîchir la localisation
//         Positioned(
//           bottom: 80,
//           right: 10,
//           child: FloatingActionButton(
//             heroTag: "refreshButton",
//             onPressed: () async {
//               print("Bouton cliqué");
//               await _getCurrentLocation();
//             },
//             tooltip: 'Rafraîchir la localisation',
//             child: Icon(Icons.my_location),
//           ),
//         ),
//
//         // Boutons pour zoomer/dézoomer
//         Positioned(
//           bottom: 250,
//           right: 10,
//           child: Column(
//             children: [
//               FloatingActionButton(
//                 heroTag: "btnZoomIn",
//                 onPressed: () {
//                   setState(() {
//                     if (_zoomLevel < 18.0) {
//                       _zoomLevel++;
//                       _mapController.move(_mapController.center, _zoomLevel);
//                     }
//                   });
//                 },
//                 child: Icon(Icons.zoom_in),
//               ),
//               SizedBox(height: 10),
//               FloatingActionButton(
//                 heroTag: "btnZoomOut",
//                 onPressed: () {
//                   setState(() {
//                     if (_zoomLevel > 1) {
//                       _zoomLevel--;
//                       _mapController.move(_mapController.center, _zoomLevel);
//                     }
//                   });
//                 },
//                 child: Icon(Icons.zoom_out),
//               ),
//             ],
//           ),
//         ),
//
//         // Bouton pour activer/désactiver le mode sombre
//         Positioned(
//           bottom: 190,
//           right: 10,
//           child: FloatingActionButton(
//             onPressed: () {
//               setState(() {
//                 _isDarkMode = !_isDarkMode;
//               });
//             },
//             tooltip: 'Activer/désactiver le mode sombre',
//             child: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
//           ),
//         ),
//       ],
//     );
//   }
// }
