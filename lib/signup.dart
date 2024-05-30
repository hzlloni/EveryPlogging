import 'package:everyplogging/homepage.dart';
import 'package:everyplogging/login.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _schoolController = TextEditingController();
  final TextEditingController _birthController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isCheckingDuplicate = false;
  bool _isDuplicate = false;
  String _duplicateCheckMessage = '';
  String _passwordErrorMessage = '';

  void _checkDuplicateEmail() async {
    setState(() {
      _isCheckingDuplicate = true;
    });

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: _emailController.text)
          .get();

      setState(() {
        _isDuplicate = snapshot.docs.isNotEmpty;
        _isCheckingDuplicate = false;
        _duplicateCheckMessage =
            _isDuplicate ? '중복된 아이디입니다.' : '사용 가능한 아이디입니다.';
      });
    } catch (e) {
      print('Error checking duplicate: $e');
      setState(() {
        _isCheckingDuplicate = false;
      });
    }
  }

  void _saveUserData() async {
    if (_isDuplicate) {
      setState(() {
        _duplicateCheckMessage = '중복된 아이디입니다. 다른 아이디를 사용하세요.';
      });
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _passwordErrorMessage = '비밀번호가 일치하지 않습니다.';
      });
      return;
    }

    try {
      await _firestore.collection('users').add({
        'name': _nameController.text,
        'birthdate': _birthController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'school': _schoolController.text,
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } catch (e) {
      print('Error saving user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              'assets/signup.png',
              fit: BoxFit.fill,
              width: double.infinity,
              height: 290, // 적절한 높이로 조정
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '이름',
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _birthController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '생년월일',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _birthController.text =
                              DateFormat('yyyy-MM-dd').format(pickedDate);
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: '아이디',
                          ),
                          keyboardType: TextInputType.emailAddress, // 키보드 타입 설정
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed:
                            _isCheckingDuplicate ? null : _checkDuplicateEmail,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200], // 버튼 색상 변경
                          foregroundColor: Colors.black, // 텍스트 색상 변경
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0), // 네모난 모서리
                          ),
                        ),
                        child: _isCheckingDuplicate
                            ? const CircularProgressIndicator()
                            : const Text('중복 체크하기'),
                      ),
                    ],
                  ),
                  if (_duplicateCheckMessage.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      _duplicateCheckMessage,
                      style: TextStyle(
                        color: _isDuplicate ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '비밀번호',
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '비밀번호 확인',
                    ),
                  ),
                  if (_passwordErrorMessage.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      _passwordErrorMessage,
                      style: const TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _schoolController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: '학교 인증하기',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          // 학교 인증 버튼 누를 때의 동작 추가
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200], // 버튼 색상 변경
                          foregroundColor: Colors.black, // 텍스트 색상 변경
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0), // 네모난 모서리
                          ),
                        ),
                        child: const Icon(Icons.camera_alt),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Login()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7CC0FF), // 버튼 배경색 변경
                        foregroundColor: Colors.white, // 텍스트 색상 변경
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0), // 네모난 모서리
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 15), // 버튼 높이 조정
                      ),
                      child: const Text('로그인 하러 가기'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
