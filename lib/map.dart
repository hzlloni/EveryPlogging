import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:everyplogging/widget/bottombar.dart';

class Map extends StatefulWidget {
  const Map({super.key});

  @override
  State<Map> createState() => _MapState();
}

class _MapState extends State<Map> {
  late GoogleMapController mapController;
  LatLng _currentPosition = const LatLng(45.521563, -122.677433);

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _determinePosition() async {
    var status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      var position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
    } else {
      print('Location permission not granted');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('지도로 한눈에 보기'),
        backgroundColor: const Color.fromARGB(255, 145, 211, 148),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _currentPosition,
          zoom: 11.0,
        ),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
      bottomNavigationBar: BottomNavi(
        selectedIndex: 0,
        onItemTapped: (index) {
          print('Selected Index: $index');
        },
      ),
    );
  }
}
