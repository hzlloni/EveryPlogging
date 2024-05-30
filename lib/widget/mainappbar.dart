import 'package:flutter/material.dart';

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
            // IconButton(
            //   padding: const EdgeInsets.only(top: 10, left: 10),
            //   icon: const Icon(arrowBackIcon),
            //   onPressed: () {
            //     Navigator.pop(context);
            //   },
            // ),
            Center(
              child: Image.asset(
                'assets/appbarlogo.png',
                //height: screenHeight * 0.1, // Adjusted height
              ),
            ),
            IconButton(
              padding: const EdgeInsets.only(top: 10, right: 10),
              icon: const Icon(profileIcon, color: Colors.white), // 하얀색 프로필 아이콘
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}
