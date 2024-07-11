// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends StatelessWidget {
  final List<User> users = [
    User(latitude: 51.5, longitude: -0.09),
    User(latitude: 51.51, longitude: -0.1),
    User(latitude: 51.52, longitude: -0.08),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Carte Simple'),
      ),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(51.5, -0.09),
          zoom: 6.0,
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
      ),
    );
  }
}

class User {
  final double latitude;
  final double longitude;

  User({required this.latitude, required this.longitude});
}
