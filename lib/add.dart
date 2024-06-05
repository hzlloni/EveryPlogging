import 'package:everyplogging/widget/bottombar.dart';
import 'package:everyplogging/widget/mainappbar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';

import 'login.dart'; 
import 'homepage.dart'; 

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddState();
}

class _AddState extends State<AddPage> {
  File? _image;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _noticeController = TextEditingController();

  LatLng? _initialPosition;
  LatLng? _selectedLocation;
  GoogleMapController? _mapController;
  bool _isMapExpanded = false;

  @override
  void initState() {
    super.initState();
    _printCurrentUserId();
    _determinePosition();
  }

  void _printCurrentUserId() {
    if (currentUserId != null) {
      print('Current User ID: $currentUserId');
    } else {
      print('No user is currently signed in.');
    }
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
    });
    _mapController?.animateCamera(CameraUpdate.newLatLng(_initialPosition!));
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text = pickedDate.toString().substring(0, 10);
      });
    }
  }

  Future<void> _pickTime(TextEditingController controller) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        controller.text = pickedTime.format(context);
      });
    }
  }

  Future<void> _saveData() async {
    if (_titleController.text.isEmpty || _totalController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('제목, 참여인원, 주의사항을 모두 입력해주세요.')),
      );
      return;
    }

    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('위치를 선택해주세요.')),
      );
      return;
    }

    try {
      if (currentUserId != null) {
        print('User ID used for Firestore query: $currentUserId');

        // 사용자 문서를 참조하여 school 필드를 가져옴
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .get();

        if (userDoc.exists) {
          String? schoolName = userDoc['school'];

          if (schoolName != null) {
            // school 문서 참조
            DocumentReference schoolDocRef =
                FirebaseFirestore.instance.collection('school').doc(schoolName);

            // 새로운 모임 데이터를 group 컬렉션에 추가
            await schoolDocRef
                .collection('group')
                .doc(_titleController.text)
                .set({
              'title': _titleController.text,
              'image_path': _image?.path ?? 'assets/placeholder.png',
              'created_at': Timestamp.now(),
              'created_by': currentUserId, 
              'total': int.tryParse(_totalController.text), 
              'date': _dateController.text, 
              'start_time': _startTimeController.text, 
              'end_time': _endTimeController.text, 
              'notice': _noticeController.text, 
              'location': GeoPoint(_selectedLocation!.latitude,
                  _selectedLocation!.longitude), 
              'current' : 1,
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('모임이 저장되었습니다.')),
            );

            // 입력 필드 초기화
            _titleController.clear();
            _totalController.clear();
            _dateController.clear();
            _startTimeController.clear();
            _endTimeController.clear();
            _noticeController.clear();
            setState(() {
              _image = null;
              _selectedLocation = null;
            });

            // Navigate to HomePage
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => HomePage()));
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

  void _onMapTapped(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
  }

  void _toggleMapSize() {
    setState(() {
      _isMapExpanded = !_isMapExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
        child: SingleChildScrollView(
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
                        'assets/placeholder.png', 
                        height: screenHeight * 0.1,
                        width: screenWidth,
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        _image!,
                        height: screenHeight * 0.1,
                        width: screenWidth,
                        fit: BoxFit.cover,
                      ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  SizedBox(
                    height: screenHeight * 0.06,
                    width: screenWidth * 0.6,
                    child: TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: '제목',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 10.0),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  SizedBox(
                    height: screenHeight * 0.06,
                    width: screenWidth * 0.25,
                    child: TextField(
                      controller: _totalController,
                      decoration: InputDecoration(
                        labelText: '참여인원',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 10.0),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  SizedBox(
                    height: screenHeight * 0.06,
                    width: screenWidth * 0.41,
                    child: TextField(
                      controller: _dateController,
                      decoration: InputDecoration(
                        labelText: '날짜 선택',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 10.0),
                      ),
                      readOnly: true,
                      onTap: _pickDate,
                    ),
                  ),
                  SizedBox(width: 10),
                  SizedBox(
                    height: screenHeight * 0.06,
                    width: screenWidth * 0.21,
                    child: TextField(
                      controller: _startTimeController,
                      decoration: InputDecoration(
                        labelText: '시작 시간',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 10.0),
                      ),
                      readOnly: true,
                      onTap: () => _pickTime(_startTimeController),
                    ),
                  ),
                  SizedBox(width: 10),
                  SizedBox(
                    height: screenHeight * 0.06,
                    width: screenWidth * 0.21,
                    child: TextField(
                      controller: _endTimeController,
                      decoration: InputDecoration(
                        labelText: '종료 시간',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 10.0),
                      ),
                      readOnly: true,
                      onTap: () => _pickTime(_endTimeController),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextField(
                controller: _noticeController,
                decoration: InputDecoration(
                  labelText: '주의사항',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                ),
                maxLines: 3,
                keyboardType: TextInputType.multiline,
              ),
              SizedBox(height: 16),
              GestureDetector(
                onTap: _toggleMapSize,
                child: Container(
                  height:
                      _isMapExpanded ? screenHeight * 0.6 : screenHeight * 0.3,
                  width: screenWidth,
                  child: _initialPosition == null
                      ? Center(child: CircularProgressIndicator())
                      : GoogleMap(
                          onMapCreated: (GoogleMapController controller) {
                            _mapController = controller;
                            _determinePosition();
                          },
                          onTap: _onMapTapped,
                          scrollGesturesEnabled: true,
                          zoomGesturesEnabled: true,
                          initialCameraPosition: CameraPosition(
                            target: _initialPosition!,
                            zoom: 14,
                          ),
                          markers: _selectedLocation != null
                              ? {
                                  Marker(
                                    markerId: MarkerId('selectedLocation'),
                                    position: _selectedLocation!,
                                  ),
                                }
                              : {},
                        ),
                ),
              ),
              SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: ElevatedButton(
                    onPressed: _saveData,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color(0xFF7EC1DE),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0), 
                    ),
                    child: Text(
                      '모임 만들기',
                      style: TextStyle(fontWeight: FontWeight.bold), 
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
