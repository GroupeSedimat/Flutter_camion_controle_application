// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/base_page.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends StatelessWidget {
  final List<User> users = [
    User(latitude: 45.17118, longitude: 5.68718),
    // User(latitude: 45.21118, longitude: 5.72718),
    // User(latitude: 45.13118, longitude: 5.64718),
  ];

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Carte Map',
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        center: LatLng(45.17118, 5.68718),
        zoom: 11.0,
        // zoom: 6.0,
        // zoom: 18.0,
      ),
      children: [
        TileLayer(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: ['a', 'b', 'c'],
        ),
        MarkerLayer(
          markers: users.map((user) {
            return Marker(
              point: LatLng(user.latitude, user.longitude),
              builder: (ctx) => Icon(
                Icons.location_on,
                color: Colors.red,
                size: 40.0,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class User {
  final double latitude;
  final double longitude;

  User({required this.latitude, required this.longitude});
}
