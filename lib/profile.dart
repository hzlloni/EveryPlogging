import 'dart:ui';

import 'package:everyplogging/login.dart';
import 'package:everyplogging/notify.dart';
import 'package:everyplogging/widget/bottombar.dart';
import 'package:everyplogging/widget/subappbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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
  List<String> end = [];

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
        end = List<String>.from(userDoc['end'] ?? []);
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

  Future<void> _cancelRequest(String item) async {
    if (currentUserId != null) {
      setState(() {
        attend.remove(item);
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .update({
        'attend': attend,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"$item" 모임이 취소되었습니다.'),
        ),
      );
    }
  }

  Future<void> _checkGroupOwnership(String groupId) async {
    if (currentUserId != null) {
      DocumentSnapshot groupDoc = await FirebaseFirestore.instance
          .collection('school')
          .doc(school)
          .collection('group') // 하위 컬렉션 접근
          .doc(groupId)
          .get();

      if (groupDoc.exists) {
        print("Group found: ${groupDoc.data()}");
        if (groupDoc['created_by'] == currentUserId) {
          _showGroupCode(groupDoc['code'], groupId);
        } else {
          _showJoinGroupDialog(groupId);
        }
      } else {
        print("Group not found");
      }
    } else {
      print("No current user");
    }
  }

  void _showGroupCode(String code, String groupId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('그룹 코드'),
          content: Text('그룹 코드: $code'),
          actions: [
            TextButton(
              onPressed: () async {
                await _completeGroupActivity(groupId);
                Navigator.of(context).pop();
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  void _showJoinGroupDialog(String groupId) {
    TextEditingController codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('그룹 코드 입력'),
          content: TextField(
            controller: codeController,
            decoration: InputDecoration(hintText: '그룹 코드를 입력하세요'),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                String enteredCode = codeController.text;
                DocumentSnapshot groupDoc = await FirebaseFirestore.instance
                    .collection('school')
                    .doc(school)
                    .collection('group') // 하위 컬렉션 접근
                    .doc(groupId)
                    .get();

                if (groupDoc.exists && groupDoc['code'] == enteredCode) {
                  // 코드를 제대로 입력했을 때 처리
                  await _completeGroupActivity(groupId);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('그룹에 성공적으로 참여했습니다.'),
                    ),
                  );
                } else {
                  // 코드가 틀렸을 때 처리
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('잘못된 코드입니다. 다시 시도하세요.'),
                    ),
                  );
                }
              },
              child: Text('참여'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('취소'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _completeGroupActivity(String groupId) async {
    DocumentSnapshot groupDoc = await FirebaseFirestore.instance
        .collection('school')
        .doc(school)
        .collection('group')
        .doc(groupId)
        .get();

    if (groupDoc.exists) {
      String startTime = groupDoc['start_time'];
      String endTime = groupDoc['end_time'];
      DateTime start1 = DateFormat("HH:mm").parse(startTime);
      DateTime end1 = DateFormat("HH:mm").parse(endTime);
      int duration = end1.difference(start1).inHours;

      setState(() {
        mytime += duration;
        attend.remove(groupId);
        end.add(groupDoc.id);
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .update({
        'mytime': mytime,
        'attend': attend,
        'end': end,
      });
      DocumentSnapshot schoolDoc = await FirebaseFirestore.instance
          .collection('school')
          .doc(school)
          .get();
      int alltime = schoolDoc['alltime'];
      alltime += duration;

      await FirebaseFirestore.instance
          .collection('school')
          .doc(school)
          .update({'alltime': alltime});
    }
  }

  Future<bool> _isGroupOwner(String groupId) async {
    if (currentUserId != null) {
      DocumentSnapshot groupDoc = await FirebaseFirestore.instance
          .collection('school')
          .doc(school)
          .collection('group')
          .doc(groupId)
          .get();

      if (groupDoc.exists) {
        return groupDoc['created_by'] == currentUserId;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFCFEBFE),
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
                SizedBox(width: 27),
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
                SizedBox(width: 130),
                Text(
                  "$mytime 시간",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Divider(
              height: 20,
              thickness: 1,
              indent: 0,
              endIndent: 0,
              color: Color(0xFFA99E9E),
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
                      .map((item) => FutureBuilder<bool>(
                            future: _isGroupOwner(item),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('오류 발생');
                              } else {
                                bool isOwner = snapshot.data ?? false;
                                return _buildRequestCard(item, "시작하기", isOwner);
                              }
                            },
                          ))
                      .toList(),
                ),
              ),
            ),
            SizedBox(height: 30),
            _buildSectionHeader("지난기록"),
            SizedBox(height: 10),
            SizedBox(
              height: 110, // Adjust the height as needed
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: end.map((item) => _buildHistoryCard(item)).toList(),
                ),
              ),
            ),
            Divider(
              height: 18,
              thickness: 1,
              indent: 0,
              endIndent: 0,
              color: Color(0xFFA99E9E),
            ),
            //Spacer(),
            _buildNavigationButton1("공지사항", Icons.campaign),
            Divider(
              height: 3,
              thickness: 1,
              indent: 0,
              endIndent: 0,
              color: Color(0xFFA99E9E),
            ),
            _buildNavigationButton2("로그아웃", Icons.logout, isLogout: true),
            Divider(
              height: 9,
              thickness: 1,
              indent: 0,
              endIndent: 0,
              color: Color(0xFFA99E9E),
            ),
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

  Widget _buildRequestCard(String title, String buttonLabel, bool isOwner) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(color: Colors.black, width: 1),
      ),
      margin: EdgeInsets.symmetric(horizontal: 12.0),
      child: Container(
        width: 270,
        height: 125,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      isOwner ? Icons.star : Icons.star,
                      color: isOwner ? Colors.yellow : Color(0xFFA99E9E),
                      size: 56, // 아이콘 크기
                    ),
                    Text(
                      isOwner ? "방장" : "팀원",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12, // 텍스트 크기
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    bool isOwner = await _isGroupOwner(title);
                    if (isOwner) {
                      DocumentSnapshot groupDoc = await FirebaseFirestore
                          .instance
                          .collection('school')
                          .doc(school)
                          .collection('group')
                          .doc(title)
                          .get();
                      if (groupDoc.exists) {
                        _showGroupCode(groupDoc['code'], title);
                      }
                    } else {
                      _showJoinGroupDialog(title);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF79B6FF),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  child: Text(buttonLabel),
                ),
                if (!isOwner || isOwner) SizedBox(width: 25),
                if (!isOwner || isOwner)
                  ElevatedButton(
                    onPressed: () => _cancelRequest(title),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFCCCBCB),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
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

  Widget _buildHistoryCard(String title) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(color: Colors.black, width: 1),
      ),
      margin: EdgeInsets.symmetric(horizontal: 10.0),
      child: Container(
        width: 220,
        height: 90,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            // Text(
            //   title,
            //   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            // ),
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
