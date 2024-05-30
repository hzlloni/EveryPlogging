import 'package:everyplogging/widget/bottombar.dart';
import 'package:everyplogging/widget/mainappbar.dart';
import 'package:flutter/material.dart';

// HomePage 클래스 정의
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      bottomNavigationBar: BottomNavi(
        selectedIndex: 1,
        onItemTapped: (index) {
          print('Selected Index: $index');
        },
      ),
    );
  }
}
