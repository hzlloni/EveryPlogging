import 'package:everyplogging/profile.dart';
import 'package:flutter/material.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MainAppBar({Key? key}) : super(key: key);

  static const IconData profileIcon = Icons.account_circle; // 프로필 아이콘

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFDCF1FF),
        boxShadow: [
          BoxShadow(
            color: Colors.transparent, // 그림자 제거
            offset: Offset(0, 0),
            blurRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // 양 끝으로 정렬
          children: [
            const SizedBox(width: 50), // 왼쪽 여백 공간
            Expanded(
              child: Center(
                child: Image.asset(
                  'assets/appbarlogo.png',
                  height: 50, // Adjust height as needed
                  fit: BoxFit.contain,
                ),
              ),
            ),
            IconButton(
              padding: const EdgeInsets.only(right: 10),
              icon: const Icon(
                Icons.person,
                color: Colors.white,
                size: 45, // 아이콘 크기 조정
              ), // 하얀색 프로필 아이콘
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Profile()),
                );
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
