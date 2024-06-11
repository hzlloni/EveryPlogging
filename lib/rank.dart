import 'package:everyplogging/widget/bottombar.dart';
import 'package:everyplogging/widget/mainappbar.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Firebase Storage 추가

class Rank extends StatefulWidget {
  const Rank({super.key});

  @override
  State<Rank> createState() => _RankState();
}

class _RankState extends State<Rank> {
  List<Map<String, dynamic>> schools = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSchoolData();
  }

  Future<void> _fetchSchoolData() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('school').get();
      List<Map<String, dynamic>> fetchedSchools = await Future.wait(snapshot.docs.map((doc) async {
        String logoUrl;
        try {
          logoUrl = await _getImageUrl(doc['logo'] ?? 'logo.png');
        } catch (e) {
          print('Error fetching logo for ${doc.id}: $e');
          logoUrl = 'assets/logo.png'; // 기본 이미지 URL
        }
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

  Future<String> _getImageUrl(String imageName) async {
    return await FirebaseStorage.instance.ref('goods/$imageName').getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
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
          : ListView.builder(
              itemCount: schools.length,
              itemBuilder: (context, index) {
                final school = schools[index];
                return ListTile(
                  leading: Image.network(
                    school['logo'],
                    width: 50,
                    height: 50,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.error);
                    },
                  ),
                  title: Text('${index + 1}. ${school['name']}'),
                  trailing: Text('${school['alltime']} Hours'),
                );
              },
            ),
    );
  }
}
