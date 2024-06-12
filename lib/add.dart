import 'package:everyplogging/widget/bottombar.dart';
import 'package:everyplogging/widget/mainappbar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'dart:math';
import 'package:intl/intl.dart';

import 'package:path/path.dart' as Path;
import 'package:firebase_storage/firebase_storage.dart';
import 'login.dart';
import 'homepage.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddState();
}

class _AddState extends State<AddPage> {
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<XFile> _images = [];
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
    final List<XFile>? selectedImages = await _picker.pickMultiImage();
    if (selectedImages != null) {
      setState(() {
        _images = selectedImages;
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
      final now = DateTime.now();
      final dt = DateTime(
          now.year, now.month, now.day, pickedTime.hour, pickedTime.minute);
      final format = DateFormat('HH:mm');
      setState(() {
        controller.text = format.format(dt);
      });
    }
  }

  String _generateRandomCode(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  Future<void> uploadFile(XFile file) async {
    try {
      await _storage
          .ref('goods/${Path.basename(file.path)}')
          .putFile(File(file.path));
    } on FirebaseException catch (e) {
      print(e);
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

        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .get();

        if (userDoc.exists) {
          String? schoolName = userDoc['school'];

          if (schoolName != null) {
            List<String> imageNames = [];
            if (_images.isEmpty) {
              imageNames.add('placeholder.png'); // Default image
            } else {
              for (final image in _images) {
                await uploadFile(image);
                String imageName = Path.basename(image.path);
                imageNames.add(imageName);
              }
            }

            String randomCode = _generateRandomCode(6);

            DocumentReference schoolDocRef =
                FirebaseFirestore.instance.collection('school').doc(schoolName);

            await schoolDocRef
                .collection('group')
                .doc(_titleController.text)
                .set({
              'title': _titleController.text,
              'image_names': imageNames,
              'created_at': Timestamp.now(),
              'created_by': currentUserId,
              'total': int.tryParse(_totalController.text),
              'date': _dateController.text,
              'start_time': _startTimeController.text,
              'end_time': _endTimeController.text,
              'notice': _noticeController.text,
              'location': GeoPoint(
                  _selectedLocation!.latitude, _selectedLocation!.longitude),
              'current': 1,
              'code': randomCode,
            });

            // 모임 생성 후 현재 유저의 attend 필드에 해당 모임 추가
            await FirebaseFirestore.instance
                .collection('users')
                .doc(currentUserId)
                .update({
              'attend': FieldValue.arrayUnion([_titleController.text])
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('모임이 저장되었습니다.')),
            );

            _titleController.clear();
            _totalController.clear();
            _dateController.clear();
            _startTimeController.clear();
            _endTimeController.clear();
            _noticeController.clear();
            setState(() {
              _images = [];
              _selectedLocation = null;
            });

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

  Future<String> getDefaultImageUrl() async {
    String downloadURL =
        await _storage.ref('goods/placeholder.png').getDownloadURL();
    return downloadURL;
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
              FutureBuilder<String>(
                future: getDefaultImageUrl(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return _images.isEmpty
                        ? Image.network(snapshot.data!)
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: _images.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 1,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                            ),
                            itemBuilder: (context, index) {
                              return Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  Container(
                                    height: 300, // 원하는 높이로 설정
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: FileImage(
                                          File(_images[index].path),
                                        ),
                                      ),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 15,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _images.removeAt(index);
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                  }
                },
              ),
              Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.lightBlueAccent,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 0.5,
                      blurRadius: 5,
                    )
                  ],
                ),
                child: IconButton(
                  onPressed: _pickImage,
                  icon: const Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 30,
                    color: Colors.white,
                  ),
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
