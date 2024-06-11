import 'package:everyplogging/explainPage.dart';
import 'package:everyplogging/login.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
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
  bool _isRegistering = false;
  String _duplicateCheckMessage = '';
  String _passwordErrorMessage = '';
  String _fieldErrorMessage = '';

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

  if (_nameController.text.isEmpty ||
      _emailController.text.isEmpty ||
      _passwordController.text.isEmpty ||
      _confirmPasswordController.text.isEmpty ||
      _schoolController.text.isEmpty ||
      _birthController.text.isEmpty) {
    setState(() {
      _fieldErrorMessage = '모든 정보를 입력해 주세요.';
    });
    return;
  }

  setState(() {
    _isRegistering = true;
  });

  try {
    await _firestore.collection('users').doc(_emailController.text).set({
      'name': _nameController.text,
      'birthdate': _birthController.text,
      'email': _emailController.text,
      'password': _passwordController.text,
      'school': _schoolController.text,
      'attend': [], // 비어 있는 attend 필드를 추가합니다.
      'end': [], // 비어 있는 end 필드를 추가합니다.
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ExplainPage()),
    );
  } catch (e) {
    print('Error saving user data: $e');
  } finally {
    setState(() {
      _isRegistering = false;
    });
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
              height: 290,
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
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed:
                            _isCheckingDuplicate ? null : _checkDuplicateEmail,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
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
                        onPressed: () async {
                          // 이미지 피커 인스턴스 생성
                          final picker = ImagePicker();

                          // 이미지를 갤러리에서 선택
                          final pickedFile = await picker.pickImage(
                              source: ImageSource.gallery);

                          if (pickedFile != null) {
                            // 이미지 파일로부터 입력 이미지 생성
                            final inputImage =
                                InputImage.fromFilePath(pickedFile.path);

                            // 텍스트 인식기 인스턴스 생성
                            final textRecognizer = TextRecognizer();

                            // 텍스트 인식 수행
                            final RecognizedText recognizedText =
                                await textRecognizer.processImage(inputImage);

                            // 인식된 텍스트를 터미널에 출력
                            print(recognizedText.text);

                            // '한동대'라는 글자가 포함되어 있는지 확인하고 텍스트 필드에 설정
                            if (recognizedText.text.contains('한동대') ||
                                recognizedText.text.contains('HANDONG')) {
                              setState(() {
                                _schoolController.text = '한동대학교';
                              });
                            }

                            // 텍스트 인식기 해제
                            textRecognizer.close();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                        ),
                        child: const Icon(Icons.camera_alt),
                      ),
                    ],
                  ),
                  if (_fieldErrorMessage.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      _fieldErrorMessage,
                      style: const TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isRegistering ? null : _saveUserData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7CC0FF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: _isRegistering
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('회원가입 하기'),
                    ),
                  ),
                  const SizedBox(height: 10),
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
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text('로그인 하러 하기'),
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
