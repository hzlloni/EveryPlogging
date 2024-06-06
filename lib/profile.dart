import 'package:everyplogging/login.dart';
import 'package:everyplogging/notify.dart';
import 'package:everyplogging/widget/bottombar.dart';
import 'package:everyplogging/widget/subappbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String name = '';
  String school = '';
  int hours = 0;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  void _getUserData() async {
    if (currentUserId != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();
      setState(() {
        name = userDoc['name'];
        school = userDoc['school'];
        //hours = userDoc['hours'];
      });
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SubAppBar(),
      bottomNavigationBar: BottomNavi(
        selectedIndex: 2,
        onItemTapped: (index) {
          print('Selected Index: $index');
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/profile.png'),
                ),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      school,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
                Spacer(),
                // Text(
                //     "$hours시간",
                //     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                //     ),
              ],
            ),
            SizedBox(height: 30),
            _buildSectionHeader("신청건 1건"),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildRequestCard("플로깅 폼 미쳤다", "한동대학교", "시작하기"),
                _buildRequestCard("영일대를 깨끗하게", "영일대", "취소하기"),
              ],
            ),
            SizedBox(height: 30),
            _buildSectionHeader("지난기록"),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildHistoryCard("같이 플로깅 해요", "양덕"),
                _buildHistoryCard("플로깅 초보자들 모임", "양덕"),
              ],
            ),
            Spacer(),
            _buildNavigationButton1("공지사항", Icons.campaign),
            _buildNavigationButton2("로그아웃", Icons.logout, isLogout: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildRequestCard(String title, String location, String buttonLabel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text("위치: $location"),
            ElevatedButton(onPressed: () {}, child: Text(buttonLabel)),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(String title, String location) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text("위치: $location"),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButton1(String title, IconData icon,
      {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.red : null),
      title: Text(title, style: TextStyle(color: isLogout ? Colors.red : null)),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Notify()),
        );
      },
    );
  }

  Widget _buildNavigationButton2(String title, IconData icon,
      {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.red : null),
      title: Text(title, style: TextStyle(color: isLogout ? Colors.red : null)),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: () {
        if (isLogout) {
          _logout();
        } else {
          // Add navigation functionality here
        }
      },
    );
  }
}
