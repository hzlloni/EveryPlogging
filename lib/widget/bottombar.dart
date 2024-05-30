import 'package:everyplogging/homepage.dart';
import 'package:everyplogging/Map.dart';
import 'package:everyplogging/rank.dart';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BottomNavi extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavi({
    super.key, 
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  State<BottomNavi> createState() => _BottomNaviState();
}

class _BottomNaviState extends State<BottomNavi> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: const Color(0xFFA3D493), // 배경 색상
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(top: 15.0), 
              child: const Icon(Icons.map_outlined, size: 37),
            ),
            label: ' ',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(top: 15.0), 
              child: const FaIcon(FontAwesomeIcons.home, size: 30),
            ),
            label: ' ',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: const Icon(Icons.emoji_events, size: 37),
            ),
            label: ' ',
          ),
        ],
        currentIndex: widget.selectedIndex,
        unselectedItemColor: const Color.fromARGB(163, 181, 177, 177),
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          widget.onItemTapped(index);
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const Map(),
                  transitionDuration: Duration.zero,
                ),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const HomePage(),
                  transitionDuration: Duration.zero,
                ),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const Rank(),
                  transitionDuration: Duration.zero,
                ),
              );
              break;
          }
        },
        selectedItemColor: const Color.fromARGB(255, 253, 253, 253),
      ),
    );
  }
}
