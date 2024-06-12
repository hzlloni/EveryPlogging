import 'package:everyplogging/widget/bottombar.dart';
import 'package:everyplogging/widget/mainappbar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:lottie/lottie.dart';  // Lottie 패키지 import

class Rank extends StatefulWidget {
  const Rank({super.key});

  @override
  State<Rank> createState() => _RankState();
}

class _RankState extends State<Rank> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> schools = [];
  bool isLoading = true;
  late AnimationController _animationController; // AnimationController 추가
  int _repeatCount = 0; // 반복 횟수 추적

  @override
  void initState() {
    super.initState();
    _fetchSchoolData();

    // AnimationController 초기화
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5), // 애니메이션 지속 시간 설정
    );

    // 애니메이션 상태 리스너 추가
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_repeatCount < 1) { // 2번 반복 (0번 + 1번)
          _animationController.reset();
          _animationController.forward();
          _repeatCount++;
        }
      }
    });

    // 애니메이션 시작
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose(); // AnimationController 해제
    super.dispose();
  }

  Future<void> _fetchSchoolData() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('school').get();
      List<Map<String, dynamic>> fetchedSchools = await Future.wait(snapshot.docs.map((doc) async {
        String logoUrl = await FirebaseStorage.instance
            .ref('goods/${doc['logo'] ?? 'logo.png'}')
            .getDownloadURL();
        return {
          'name': doc.id,
          'alltime': doc['alltime'],
          'logo': logoUrl,
        };
      }).toList());

      fetchedSchools.sort((a, b) => (b['alltime'] as int).compareTo(a['alltime'] as int));

      setState(() {
        schools = fetchedSchools;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching school data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // 이미지 크기와 위치 조정을 위한 변수
    double rankImageHeight = screenHeight * 0.3;
    double rankImageTop = screenHeight * 0.1;

    return Scaffold(
      appBar: MainAppBar(),
      bottomNavigationBar: BottomNavi(
        selectedIndex: 2,
        onItemTapped: (index) {
          print('Selected Index: $index');
        },
      ),
      backgroundColor: Color(0xFFCFEFFF),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (schools.length >= 3)
                  SizedBox(
                    height: rankImageHeight + 50,
                    child: Stack(
                      children: [
                        Positioned(
                          top: rankImageTop,
                          left: 0,
                          right: 0,
                          child: Image.asset(
                            'assets/rank.png', // 배경 이미지
                            width: screenWidth,
                            height: rankImageHeight,
                          ),
                        ),
                        Positioned(
                          top: rankImageTop - 20,
                          left: screenWidth * 0.132,
                          child: _buildTopSchool(schools[1]),
                        ),
                        Positioned(
                          top: rankImageTop - 42,
                          left: screenWidth * 0.415,
                          child: _buildTopSchool(schools[0]),
                        ),
                        Positioned(
                          top: rankImageTop + 10,
                          right: screenWidth * 0.13,
                          child: _buildTopSchool(schools[2]),
                        ),
                        Positioned(
                          top: rankImageTop + rankImageHeight * 0.54,
                          left: screenWidth * 0.175,
                          child: Text(
                            '${schools[1]['alltime']} ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Positioned(
                          top: rankImageTop + rankImageHeight * 0.5,
                          left: screenWidth * 0.453,
                          child: Text(
                            '${schools[0]['alltime']}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Positioned(
                          top: rankImageTop + rankImageHeight * 0.635,
                          right: screenWidth * 0.166,
                          child: Text(
                            '${schools[2]['alltime']}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        // Lottie 애니메이션 추가
                        Positioned(
                          top: rankImageTop * -1, // 원하는 위치로 조정
                          left: screenWidth * 0.1, // 원하는 위치로 조정
                          child: Lottie.asset(
                            'assets/congrats2.json',
                            width: screenWidth * 0.8,
                            height: screenHeight * 0.4,
                            controller: _animationController,
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: Container(
                    color: Colors.white,
                    margin: EdgeInsets.only(top: 0), // 중간쯤에서 시작하도록 설정
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('RANK', style: TextStyle(fontWeight: FontWeight.bold)),
                              Image.asset('assets/king.png', height: 30), // 이미지로 변경
                              Text('HOURS', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Divider(color: Colors.black, thickness: 0.5), // 첫 번째 줄 아래 얇은 검정색 줄 추가
                        Expanded(
                          child: ListView.builder(
                            itemCount: schools.length - 3,
                            itemBuilder: (context, index) {
                              final school = schools[index + 3];
                              return Column(
                                children: [
                                  ListTile(
                                    leading: Text(
                                      '${index + 4}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16, // 크기를 키우기
                                        color: Colors.black, // 색상을 검정색으로 설정
                                      ),
                                    ),
                                    title: Row(
                                      children: [
                                        Image.network(
                                          school['logo'],
                                          width: 40,
                                          height: 40,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Icon(Icons.error);
                                          },
                                        ),
                                        SizedBox(width: 55),
                                        Text(
                                          school['name'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16, // 크기를 키우기
                                            color: Colors.black, // 색상을 검정색으로 설정
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: Text(
                                      '${school['alltime']}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16, // 크기를 키우기
                                        color: Colors.black, // 색상을 검정색으로 설정
                                      ),
                                    ),
                                  ),
                                  Divider(color: Colors.black, thickness: 0.5), // 각 대학교 사이에 얇은 검정색 줄 추가
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTopSchool(Map<String, dynamic> school) {
    return Column(
      children: [
        Image.network(
          school['logo'],
          width: 70,
          height: 70,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.error);
          },
        ),
        SizedBox(height: 4),
        Text(
          school['name'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
