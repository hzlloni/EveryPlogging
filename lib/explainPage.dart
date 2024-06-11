import 'dart:async';
import 'package:everyplogging/login.dart';
import 'package:flutter/material.dart';

class ExplainPage extends StatefulWidget {
  const ExplainPage({super.key});

  @override
  State<ExplainPage> createState() => _ExplainPageState();
}

class _ExplainPageState extends State<ExplainPage> {
  List<Widget> _displayedImages = [];
  late Timer _timer;
  int _nextImageIndex = 0;
  bool _showOverlay = false;
  bool _showCheckboxes = false;
  bool _isChecked1 = false;
  bool _isChecked2 = false;
  bool _isChecked3 = false;

  final List<String> _imageList = [
    'assets/trash1.png',
    'assets/trash2.png',
    'assets/trash3.png',
    'assets/trash4.png',
    'assets/trash5.png',
    'assets/trash6.png',
  ];

  late List<Offset> _positionList;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 700), (timer) {
      if (_nextImageIndex < _imageList.length) {
        setState(() {
          _displayedImages.add(
            Positioned(
              left: _positionList[_nextImageIndex].dx,
              top: _positionList[_nextImageIndex].dy,
              child: Image.asset(_imageList[_nextImageIndex]),
            ),
          );
          _nextImageIndex++;
        });
      } else {
        _timer.cancel(); 
        setState(() {
          _showOverlay = true;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    _positionList = [
      Offset(screenWidth * -0.1, screenHeight * 0),  
      Offset(screenWidth * 0.35, screenHeight * 0.1),  
      Offset(screenWidth * -0.08, screenHeight * 0.3), 
      Offset(screenWidth * -0.2, screenHeight * 0.3),  
      Offset(screenWidth * -0.1, screenHeight * 0.5),  
      Offset(screenWidth * -0.1, screenHeight * 0.75),  
    ];
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  bool get _isLoginButtonEnabled => _isChecked1 && _isChecked2 && _isChecked3;

  void _onConfirmButtonPressed() {
    setState(() {
      _showCheckboxes = true;
    });
  }

  void _onLoginButtonPressed() {
    if (_isLoginButtonEnabled) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    }
  }

  void _onCheckboxChanged(bool? newValue, int checkboxIndex) {
    setState(() {
      switch (checkboxIndex) {
        case 1:
          _isChecked1 = newValue ?? false;
          break;
        case 2:
          _isChecked2 = newValue ?? false;
          break;
        case 3:
          _isChecked3 = newValue ?? false;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 20, 96, 159),
      body: Stack(
        children: [
          Stack(
            children: _displayedImages,
          ),
          if (_showOverlay)
            AnimatedOpacity(
              opacity: _showOverlay ? 1.0 : 0.0,
              duration: const Duration(seconds: 1),
              child: Container(
                color: Colors.black.withOpacity(0.4),
                child: Center(
                  child: !_showCheckboxes
                      ? Container(
                          width: 500,
                          height: 320,
                          color: Colors.white,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 10),
                              Image.asset('assets/whatIs.png'),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: _onConfirmButtonPressed,
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: const Color.fromARGB(255, 18, 166, 45), 
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8), 
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), 
                                ),
                                child: const Text('확인'),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          width: 500,
                          height: 400,
                          color: Colors.white,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "‘나’는 아래와 같이 플로깅을 실천하겠습니다",
                                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              CheckboxListTile(
                                activeColor: const Color.fromARGB(255, 18, 166, 45),
                                title: const Text(
                                  "플로깅이 무엇인지 알고,\n실천하도록 노력하겠습니다",
                                  style: TextStyle(fontSize: 15),
                                ),
                                value: _isChecked1,
                                onChanged: (value) {
                                  _onCheckboxChanged(value, 1);
                                },
                              ),
                              CheckboxListTile(
                                activeColor: const Color.fromARGB(255, 18, 166, 45),
                                title: const Text(
                                  "‘나’뿐만 아니라 주변사람들에게도\n플로깅을 알려주고 함께 참여하겠습니다",
                                  style: TextStyle(fontSize: 15),
                                ),
                                value: _isChecked2,
                                onChanged: (value) {
                                  _onCheckboxChanged(value, 2);
                                },
                              ),
                              CheckboxListTile(
                                activeColor: const Color.fromARGB(255, 18, 166, 45),
                                title: const Text(
                                  "주 1회이상 플로깅을\n실천하도록 노력하겠습니다",
                                  style: TextStyle(fontSize: 15),
                                ),
                                value: _isChecked3,
                                onChanged: (value) {
                                  _onCheckboxChanged(value, 3);
                                },
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: _isLoginButtonEnabled ? _onLoginButtonPressed : null,
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: const Color.fromARGB(255, 18, 166, 45), 
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8), 
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), 
                                ),
                                child: const Text('로그인하기'),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
