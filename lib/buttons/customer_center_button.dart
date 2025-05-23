import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(home: CustomerCenterSettingsPage()));

class CustomerCenterSettingsPage extends StatefulWidget {
  @override
  _CustomerCenterSettingsPageState createState() => _CustomerCenterSettingsPageState();
}

class _CustomerCenterSettingsPageState extends State<CustomerCenterSettingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();               // TabBarView와 TabBar 동기화에 사용되는 컨트롤러 생성
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();        // 컨트롤러 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 25),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.headset_mic, color: Colors.black, size: 28),
              SizedBox(width: 8),
              Text('고객센터   ', style: TextStyle(color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        bottom: TabBar(           // 하단 TabBar 설정
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.black,
          tabs: [
            Tab(text: '내 문의내역'),
            Tab(text: '문의하기'),
          ],
        ),
      ),
      body: TabBarView(           // 각 탭에 해당하는 화면 콘텐츠들
        controller: _tabController,
        children: [
          MyInquiriesTab(),       // 1 번째 탭
          InquiryTab(),           // 2 번째 탭
        ],
      ),
    );
  }
}

class MyInquiriesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('진행중인 문의가 없어요', style: TextStyle(fontSize: 16)),
    );
  }
}

class InquiryTab extends StatefulWidget {
  @override
  _InquiryTabState createState() => _InquiryTabState();
}

class _InquiryTabState extends State<InquiryTab> {
  String selectedCategory = '';

  void selectCategory(String title) {
    setState(() {
      selectedCategory = title;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Text('어떤 점이 궁금하신가요?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 16),
        InquiryCategory(         // 탭 안의 카테고리들 구성
          title: '로그인',
          examples: ['카카오계정 로그인이 안 돼요', '비회원으로 이용할 수 있나요'],
          selected: selectedCategory == '로그인',
          onTap: () => selectCategory('로그인'),
        ),
        InquiryCategory(
          title: '약속',
          examples: ['약속 알람이 안 와요', '약속을 취소하고 싶어요'],
          selected: selectedCategory == '약속',
          onTap: () => selectCategory('약속'),
        ),
        InquiryCategory(
          title: '위치',
          examples: ['약속 위치가 안 떠요', '현재 위치가 정확하지 않아요'],
          selected: selectedCategory == '위치',
          onTap: () => selectCategory('위치'),
        ),
        SizedBox(height: 24),
        HelpBox(),
      ],
    );
  }
}

class InquiryCategory extends StatelessWidget {     // 문의 카테고리 위젯 (GestureDetector로 클릭 이벤트 감지)
  final String title;
  final List<String> examples;
  final bool selected;
  final VoidCallback onTap;

  const InquiryCategory({
    required this.title,
    required this.examples,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,       // 박스 클릭 시 선택 처리
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: selected ? Color(0xFFD9C189) : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            ...examples.map((e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('예시', style: TextStyle(fontSize: 12, color: Colors.black54)),
                  ),
                  SizedBox(width: 8),
                  Expanded(child: Text(e, style: TextStyle(color: Colors.grey[700]))),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class HelpBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('도움이 필요하신가요?', style: TextStyle(fontSize: 14)),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              side: BorderSide(color: Colors.grey.shade400),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: Text('문의하기'),
          )
        ],
      ),
    );
  }
}
