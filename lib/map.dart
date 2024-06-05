import 'dart:async';
import 'dart:ui' as ui;
import 'package:everyplogging/widget/bottombar.dart';
import 'package:everyplogging/widget/mainappbar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class Map extends StatefulWidget {
  const Map({super.key});

  @override
  State<Map> createState() => _MapState();
}

class _MapState extends State<Map> {
  late GoogleMapController mapController;
  final Completer<GoogleMapController> _controller = Completer();
  LatLng _currentPosition = const LatLng(45.521563, -122.677433);
  Set<Marker> _markers = {};
  BitmapDescriptor? _customIcon;

  @override
  void initState() {
    super.initState();
    _checkLocationServices();
    _fetchMeetingLocations();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _controller.complete(controller);
  }

  Future<void> _checkLocationServices() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Location permissions are permanently denied.');
      return;
    }

    _determinePosition();
  }

  Future<void> _determinePosition() async {
    try {
      var position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: _currentPosition,
              zoom: 15.0,
            ),
          ),
        );
      });
      print('Current position: $_currentPosition');
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> _currentLocation() async {
    final GoogleMapController controller = await _controller.future;
    try {
      var position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 18.0,
        ),
      ));
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
      print('Current position: $_currentPosition');
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> _fetchMeetingLocations() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collectionGroup('group').get();

      for (var doc in querySnapshot.docs) {
        GeoPoint geoPoint = doc['location'];
        String title = doc['title'];

        BitmapDescriptor customIcon = await _createCustomMarkerWithImage(title);

        setState(() {
          _markers.add(
            Marker(
              markerId: MarkerId(doc.id),
              position: LatLng(geoPoint.latitude, geoPoint.longitude),
              icon: customIcon,
            ),
          );
        });
      }
    } catch (e) {
      print('Error fetching meeting locations: $e');
    }
  }

  Future<BitmapDescriptor> _createCustomMarkerWithImage(String text) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    const double markerWidth = 170.0; 
    const double markerHeight = 170.0; 

    final ByteData data = await rootBundle.load('assets/marker.png');
    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: markerWidth.toInt(),
      targetHeight: markerHeight.toInt(),
    );
    final ui.FrameInfo fi = await codec.getNextFrame();

    canvas.drawImage(fi.image, Offset(0.0, 0.0), Paint());

    TextPainter painter = TextPainter(
      textDirection: ui.TextDirection.ltr,
    );
    painter.text = TextSpan(
      text: text,
      style: TextStyle(
        fontSize: 24.0,
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
    );
    painter.layout();
    painter.paint(
      canvas,
      Offset(
        (markerWidth / 2) - (painter.width / 2),
        (markerHeight / 3) - (painter.height / 2),
      ),
    );

    final img = await pictureRecorder.endRecording().toImage(markerWidth.toInt(), markerHeight.toInt());
    final dataBytes = await img.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(dataBytes!.buffer.asUint8List());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 11.0,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            markers: _markers,
          ),
          Positioned(
            bottom: 16,
            left: 16,
            child: FloatingActionButton(
              onPressed: _currentLocation,
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: Colors.black),
            ),
          ),
        ],
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
