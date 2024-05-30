import 'package:everyplogging/widget/bottombar.dart';
import 'package:flutter/material.dart';

class Map extends StatefulWidget {
  const Map({super.key});

  @override
  State<Map> createState() => _MapState();
}

class _MapState extends State<Map> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map Page'),
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
