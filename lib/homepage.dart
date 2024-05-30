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
      appBar: const MainAppBar(),
      body: const Center(
        child: Placeholder(), // 원래의 Placeholder를 유지
      ),
    );
  }
}
