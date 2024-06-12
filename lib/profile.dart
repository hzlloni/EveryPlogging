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
  int mytime = 0;
  List<String> attend = [];

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
        mytime = userDoc['mytime'];
        attend = List<String>.from(userDoc['attend'] ?? []);
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
        selectedIndex: 1,
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
                //Spacer(),
                SizedBox(width: 130),
                Text(
                  "$mytime 시간",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 30),
            _buildSectionHeader("신청건 ${attend.length}건"),
            SizedBox(height: 15),
            SizedBox(
              height: 140, // Adjust the height as needed
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: attend
                      .map((item) => _buildRequestCard(item, "시작하기"))
                      .toList(),
                ),
              ),
            ),
            SizedBox(height: 30),
            _buildSectionHeader("지난기록"),
            SizedBox(height: 15),
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

  Widget _buildRequestCard(String title, String buttonLabel) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(color: Colors.black, width: 1),
      ),
      margin: EdgeInsets.symmetric(horizontal: 10.0),
      child: Container(
        width: 290,
        height: 130,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            // Row(
            //   children: [
            //     Icon(Icons.place, size: 16, color: Colors.grey),
            //     SizedBox(width: 5),
            //     Text(
            //       '위치 : 한동대학교',
            //       style: TextStyle(fontSize: 14, color: Colors.grey),
            //     ),
            //   ],
            // ),
            SizedBox(height: 10),
            Row(
              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF79B6FF),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0), // 버튼 둥글기
                    ),
                  ),
                  child: Text("시작하기"),
                ),
                SizedBox(width: 25),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFCCCBCB),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0), // 버튼 둥글기
                    ),
                  ),
                  child: Text("취소하기"),
                ),
              ],
            ),
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
