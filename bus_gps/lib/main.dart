import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
} 

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Location _location = Location();
  @override
  void initState() {
    super.initState();
    _updateLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ubicación en tiempo real'),
      ),
      
        body: StreamBuilder<DocumentSnapshot>(
          stream: _db.collection('locations').doc('device1').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.data!.exists) {
              return Center(child: Text('El documento no existe'));
            }

            GeoPoint location = snapshot.data?['location'];
            return Center(
              child: Text('Ubicación del dispositivo 1: ${location.latitude}, ${location.longitude}'),
            );
          },
        ),

      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.location_on),
        onPressed: _updateLocation,
      ),
    );
  }

void _updateLocation() {
  Timer.periodic(Duration(seconds: 5), (timer) async {
    LocationData locationData = await _location.getLocation();
    _db.collection('locations').doc('bus_p').set({
      'location': GeoPoint(locationData.latitude!, locationData.longitude!),
    });
  });
}
}
