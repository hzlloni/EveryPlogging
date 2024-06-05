import 'package:everyplogging/widget/bottombar.dart';
import 'package:everyplogging/widget/mainappbar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddState();
}

class _AddState extends State<AddPage> {
  File? _image;
  final TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _printCurrentUserId();
  }

  void _printCurrentUserId() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      print('Current User ID: ${user.uid}');
    } else {
      print('No user is currently signed in.');
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveData() async {
    if (_titleController.text.isEmpty || _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('제목과 이미지를 모두 선택해주세요.')),
      );
      return;
    }

    try {
      // 현재 로그인된 사용자 가져오기
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String userId = user.uid;
        print('User ID used for Firestore query: $userId');

        // 사용자 문서를 참조하여 school 필드를 가져옴
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

        if (userDoc.exists) {
          String? schoolName = userDoc['school'];

          if (schoolName != null) {
            // school 문서 참조
            DocumentReference schoolDocRef = FirebaseFirestore.instance.collection('school').doc(schoolName);

            // 새로운 모임 데이터를 group 컬렉션에 추가
            await schoolDocRef.collection('group').add({
              'title': _titleController.text,
              'image_path': _image!.path,
              'created_at': Timestamp.now(),
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('모임이 저장되었습니다.')),
            );

            // 입력 필드 초기화
            _titleController.clear();
            setState(() {
              _image = null;
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인된 사용자가 없습니다.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('데이터 저장 중 오류가 발생했습니다: $e')),
      );
    }
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '플로깅 모임 만들기',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: _pickImage,
              child: _image == null
                  ? Image.asset(
                      'assets/placeholder.png', // Place your placeholder image asset here
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Image.file(
                      _image!,
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 50, // 원하는 높이로 조정
              width: 250,
              child: TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: '제목',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveData,
              child: Text('저장하기'),
            ),
          ],
        ),
      ),
    );
  }
}
