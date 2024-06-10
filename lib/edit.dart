import 'package:everyplogging/widget/bottombar.dart';
import 'package:everyplogging/widget/mainappbar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';

import 'package:path/path.dart' as Path;
import 'package:firebase_storage/firebase_storage.dart';
import 'login.dart';
import 'homepage.dart';

class EditGroupPage extends StatefulWidget {
  final Map<String, dynamic> group;

  const EditGroupPage({required this.group, super.key});

  @override
  State<EditGroupPage> createState() => _EditGroupPageState();
}

class _EditGroupPageState extends State<EditGroupPage> {
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<XFile> _images = [];
  List<String> _existingImages = [];
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
    _initializeFields();
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

  void _initializeFields() {
    _noticeController.text = widget.group['notice'];
    _selectedLocation = LatLng(widget.group['location'].latitude, widget.group['location'].longitude);
    _existingImages = List<String>.from(widget.group['image_names']);
  }

  Future<void> _pickImage() async {
    final List<XFile>? selectedImages = await _picker.pickMultiImage();
    if (selectedImages != null) {
      setState(() {
        _images = selectedImages;
      });
    }
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

  Future<void> _updateData() async {
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
              imageNames = List<String>.from(widget.group['image_names']);
            } else {
              for (final image in _images) {
                await uploadFile(image);
                String imageName = Path.basename(image.path);
                imageNames.add(imageName);
              }
            }

            DocumentReference schoolDocRef =
                FirebaseFirestore.instance.collection('school').doc(schoolName);

            await schoolDocRef
                .collection('group')
                .doc(widget.group['title']) // Assume title is unique and used as document ID
                .update({
              'image_names': imageNames,
              'notice': _noticeController.text,
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('모임이 업데이트되었습니다.')),
            );

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

  Future<String> getImageUrl(String imageName) async {
    return await _storage.ref('goods/$imageName').getDownloadURL();
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
                '*사진과 주의사항만 변경할 수 있습니다.',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 16),
              FutureBuilder<List<String>>(
                future: Future.wait(_existingImages.map((imageName) => getImageUrl(imageName)).toList()),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    List<String> imageUrls = snapshot.data!;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _images.isEmpty ? imageUrls.length : _images.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                      ),
                      itemBuilder: (context, index) {
                        String imageUrl = _images.isEmpty ? imageUrls[index] : _images[index].path;
                        return Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Container(
                              height: 300,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: _images.isEmpty
                                      ? NetworkImage(imageUrl)
                                      : FileImage(File(imageUrl)) as ImageProvider,
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
                                    if (_images.isEmpty) {
                                      _existingImages.removeAt(index);
                                    } else {
                                      _images.removeAt(index);
                                    }
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
              TextField(
                controller: TextEditingController(text: widget.group['title']),
                decoration: InputDecoration(
                  labelText: '제목',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 10.0),
                ),
                readOnly: true,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: TextEditingController(text: widget.group['total'].toString()),
                      decoration: InputDecoration(
                        labelText: '참여인원',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 10.0),
                      ),
                      readOnly: true,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: TextEditingController(text: widget.group['date']),
                      decoration: InputDecoration(
                        labelText: '날짜',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 10.0),
                      ),
                      readOnly: true,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: TextEditingController(text: widget.group['start_time']),
                      decoration: InputDecoration(
                        labelText: '시작 시간',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 10.0),
                      ),
                      readOnly: true,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: TextEditingController(text: widget.group['end_time']),
                      decoration: InputDecoration(
                        labelText: '종료 시간',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 10.0),
                      ),
                      readOnly: true,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              GestureDetector(
                onTap: _toggleMapSize,
                child: Container(
                  height: _isMapExpanded ? screenHeight * 0.6 : screenHeight * 0.3,
                  width: screenWidth,
                  child: _initialPosition == null
                      ? Center(child: CircularProgressIndicator())
                      : GoogleMap(
                          onMapCreated: (GoogleMapController controller) {
                            _mapController = controller;
                            _determinePosition();
                          },
                          initialCameraPosition: CameraPosition(
                            target: _selectedLocation!,
                            zoom: 14,
                          ),
                          markers: {
                            Marker(
                              markerId: MarkerId('selectedLocation'),
                              position: _selectedLocation!,
                            ),
                          },
                        ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 20.0,
                      ),
                    ),
                    child: Text(
                      '돌아가기',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _updateData,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color(0xFF7EC1DE),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 20.0,
                      ),
                    ),
                    child: Text(
                      '모임 수정하기',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
