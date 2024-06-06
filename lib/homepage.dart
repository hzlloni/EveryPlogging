import 'package:everyplogging/add.dart';
import 'package:everyplogging/widget/bottombar.dart';
import 'package:everyplogging/widget/mainappbar.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<dynamic> imgList = [
    'assets/banner.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(),
      bottomNavigationBar: BottomNavi(
        selectedIndex: 1,
        onItemTapped: (index) {
          print('Selected Index: $index');
        },
      ),
      backgroundColor: Color(0xFFCFEFFF),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: 100.0,
              autoPlay: true,
              enlargeCenterPage: true,
            ),
            items: imgList.map((item) {
              if (item is String && item.startsWith('http')) {
                return Container(
                  child: Center(
                    child: Image.network(item, fit: BoxFit.cover, width: 1000),
                  ),
                );
              } else {
                return Container(
                  child: Center(
                    child: Image.asset(item, fit: BoxFit.cover, width: 1000),
                  ),
                );
              }
            }).toList(),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(
              '목록 보기',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPage()),
          );
        },
        backgroundColor: Color(0xFF7EC1DE),
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
