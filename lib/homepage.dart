import 'package:everyplogging/add.dart';
import 'package:everyplogging/edit.dart';
import 'package:everyplogging/widget/bottombar.dart';
import 'package:everyplogging/widget/mainappbar.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'login.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<dynamic> imgList = [
    'assets/banner.png',
  ];

  List<Map<String, dynamic>> groups = [];

  @override
  void initState() {
    super.initState();
    _fetchGroups();
  }

  Future<void> _fetchGroups() async {
    if (currentUserId != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .get();

        if (userDoc.exists) {
          String? schoolName = userDoc['school'];

          if (schoolName != null) {
            QuerySnapshot groupSnapshot = await FirebaseFirestore.instance
                .collection('school')
                .doc(schoolName)
                .collection('group')
                .get();

            setState(() {
              groups = groupSnapshot.docs
                  .map((doc) => doc.data() as Map<String, dynamic>)
                  .toList();
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('사용자의 학교 정보를 찾을 수 없습니다.')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('사용자 문서를 찾을 수 없습니다.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('데이터를 가져오는 중 오류가 발생했습니다: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인된 사용자가 없습니다.')),
      );
    }
  }

  Future<String> _getImageUrl(String imageName) async {
    return await FirebaseStorage.instance
        .ref('goods/$imageName')
        .getDownloadURL();
  }

  Future<void> _deleteGroup(Map<String, dynamic> group) async {
    if (currentUserId != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .get();

        if (userDoc.exists) {
          String? schoolName = userDoc['school'];

          if (schoolName != null) {
            await FirebaseFirestore.instance
                .collection('school')
                .doc(schoolName)
                .collection('group')
                .doc(group['title'])
                .delete();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('모임이 삭제되었습니다.')),
            );

            _fetchGroups();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('사용자의 학교 정보를 찾을 수 없습니다.')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('사용자 문서를 찾을 수 없습니다.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('모임 삭제 중 오류가 발생했습니다: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인된 사용자가 없습니다.')),
      );
    }
  }

  Future<void> _joinGroup(String groupName) async {
    if (currentUserId != null) {
      try {
        DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(currentUserId);
        await userRef.update({
          'attend': FieldValue.arrayUnion([groupName])
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('모임에 참가했습니다.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('모임 참가 중 오류가 발생했습니다: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인된 사용자가 없습니다.')),
      );
    }
  }

  Future<void> _leaveGroup(String groupName) async {
    if (currentUserId != null) {
      try {
        DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(currentUserId);
        await userRef.update({
          'attend': FieldValue.arrayRemove([groupName])
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('모임 참가가 취소되었습니다.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('모임 참가 취소 중 오류가 발생했습니다: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인된 사용자가 없습니다.')),
      );
    }
  }

  void _showDeleteConfirmationDialog(Map<String, dynamic> group) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('모임 삭제'),
          content: Text('정말로 이 모임을 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteGroup(group);
              },
              child: Text('삭제'),
            ),
          ],
        );
      },
    );
  }

  void _showGroupDetails(Map<String, dynamic> group) {
    showDialog(
      context: context,
      builder: (context) {
        bool isCreator = group['created_by'] == currentUserId;
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FutureBuilder<String>(
                    future: _getImageUrl(group['image_names']?.first ?? 'logo.png'),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Image.asset('assets/placeholder.png', fit: BoxFit.cover);
                      } else {
                        return ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          child: Image.network(
                            snapshot.data ?? '',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset('assets/placeholder.png', fit: BoxFit.cover);
                            },
                          ),
                        );
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              group['title'] ?? 'No Title',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            if (isCreator)
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      _showEditGroupDetails(group);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      _showDeleteConfirmationDialog(group);
                                    },
                                  ),
                                ],
                              ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text('참여인원: ${group['current']}/${group['total']}'),
                        SizedBox(height: 5),
                        Text('주의사항:'),
                        Text(group['notice'] ?? 'No Notice'),
                        SizedBox(height: 10),
                        Container(
                          height: 200,
                          width: double.infinity,
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: LatLng(
                                group['location'].latitude,
                                group['location'].longitude,
                              ),
                              zoom: 14,
                            ),
                            markers: {
                              Marker(
                                markerId: MarkerId('selectedLocation'),
                                position: LatLng(
                                  group['location'].latitude,
                                  group['location'].longitude,
                                ),
                              ),
                            },
                          ),
                        ),
                        SizedBox(height: 10),
                        FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance.collection('users').doc(currentUserId).get(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return CircularProgressIndicator();
                            List<dynamic> attend = snapshot.data!['attend'] ?? [];
                            bool isAttending = attend.contains(group['title']);
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    if (isAttending) {
                                      _leaveGroup(group['title']);
                                    } else {
                                      _joinGroup(group['title']);
                                    }
                                    Navigator.of(context).pop();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isAttending ? Color(0xFF79B6FF) : Color(0xFF79B6FF),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      side: BorderSide(color: Colors.black),
                                    ),
                                  ),
                                  child: Text(
                                    isAttending ? '참가 취소하기' : '참가하기',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                                SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[300],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      side: BorderSide(color: Colors.black),
                                    ),
                                  ),
                                  child: Text(
                                    '닫기',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEditGroupDetails(Map<String, dynamic> group) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditGroupPage(group: group)),
    );
  }

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
            child: ListView.builder(
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                return GroupCard(
                  group: group,
                  onTap: () => _showGroupDetails(group),
                );
              },
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

class GroupCard extends StatelessWidget {
  final Map<String, dynamic> group;
  final VoidCallback onTap;

  const GroupCard({Key? key, required this.group, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(
          color: Colors.black,
          width: 1.5,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
        title: Text(
          group['title'] ?? 'No Title',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 5),
            Text('${group['current']}/${group['total']}'),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF79B6FF), // Button color
            padding: EdgeInsets.symmetric(
                vertical: 2.0,
                horizontal: 10.0), // Adjust padding to make button smaller
            minimumSize: Size(70, 36), // Set minimum size to make button smaller
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: BorderSide(color: Colors.black), // Black border
            ),
          ),
          child: Text(
            '자세히 보기',
            style: TextStyle(color: Colors.black), // Black text color
          ),
        ),
      ),
    );
  }
}
