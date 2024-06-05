import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login.dart';
import 'splash.dart';

String? currentUserId;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Every Plogging',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashPage(), // 처음에 SplashPage를 띄웁니다.
    );
  }
}
