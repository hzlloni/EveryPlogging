import 'package:everyplogging/widget/bottombar.dart';
import 'package:everyplogging/widget/subappbar.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class Notify extends StatefulWidget {
  const Notify({super.key});

  @override
  State<Notify> createState() => _NotifyState();
}

class _NotifyState extends State<Notify> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildYoutubePlayer(String videoId) {
    return YoutubePlayer(
      controller: YoutubePlayerController(
        initialVideoId: videoId,
        flags: YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
        ),
      ),
      showVideoProgressIndicator: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SubAppBar(),
      bottomNavigationBar: BottomNavi(
        selectedIndex: 1,
        onItemTapped: (index) {
          print('Selected Index: $index');
        },
      ),
      body: Column(
        children: [
          Container(
            color: Color(0xFFDCF1FF),
            child: TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: '플로깅 데이'),
                Tab(text: '플로깅이란?'),
              ],
              labelStyle: TextStyle(fontSize: 17), // 선택된 탭의 글자 크기
              unselectedLabelStyle: TextStyle(fontSize: 15),
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPloggingDayTab(),
                _buildPloggingInfoTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPloggingInfoTab() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Text(
          '플로깅 YouTube',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        _buildYoutubePlayer('7XrxTrejx8w'),
        SizedBox(height: 16),
        Text(
          '요즘 유행하는 북유럽 운동문화 플로깅(Plogging) 건강을 지키며 환경도 지켜요!',
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 16),
        _buildYoutubePlayer('Ej1Ks-9p2c8'),
        SizedBox(height: 16),
        Text(
          '우리 플로깅 할까요?...달리며 쓰레기 줍는 청년들_YTN',
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildPloggingDayTab() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        // Text(
        //   '플로깅 데이',
        //   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        // ),
        SizedBox(height: 16),
        Image.asset(
          'assets/notice.png',
          fit: BoxFit.cover,
          height: 200,
        ),
        SizedBox(height: 16),
        Text(
          '플로깅 데이 in 영일대',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          '2024.05.26 14:00 ~ 2024.05.26 16:00',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }
}
