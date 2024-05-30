import 'package:flutter/material.dart';

// MainAppBar 클래스 정의
class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MainAppBar({Key? key}) : super(key: key);

  static const IconData arrowBackIcon = IconData(
    0xf571,
    fontFamily: 'MaterialIcons',
    matchTextDirection: true,
  );

  static const IconData profileIcon = Icons.account_circle; // 프로필 아이콘

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      color: const Color(0xFFDCF1FF).withOpacity(0.05),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // 양 끝으로 정렬
          children: [
            IconButton(
              padding: const EdgeInsets.only(top: 10, left: 10),
              icon: const Icon(arrowBackIcon),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            Center(
              child: Image.asset(
                'assets/logo.png',
                height: screenHeight * 0.1, // Adjusted height
              ),
            ),
            IconButton(
              padding: const EdgeInsets.only(top: 10, right: 10),
              icon: const Icon(profileIcon, color: Colors.white), // 하얀색 프로필 아이콘
              onPressed: () {
                // 프로필 아이콘 클릭 시의 동작 추가
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}

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
      appBar: const MainAppBar(),
      body: const Center(
        child: Placeholder(), // 원래의 Placeholder를 유지
      ),
    );
  }
}

// 메인 함수 정의
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomePage(),
    );
  }
}
