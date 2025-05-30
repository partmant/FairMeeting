import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart'; // 외부 앱(Gmail 등) 실행을 위한 패키지

void main() => runApp(MaterialApp(home: CustomerCenterSettingsPage()));

// TabBar를 통해 문의내역 / 문의하기 탭으로 구성
class CustomerCenterSettingsPage extends StatefulWidget {
  @override
  _CustomerCenterSettingsPageState createState() => _CustomerCenterSettingsPageState();
}

class _CustomerCenterSettingsPageState extends State<CustomerCenterSettingsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController; // 탭 컨트롤러로 두 개의 탭 관리
  List<String> inquiryHistory = []; // SharedPreferences로 저장된 문의내역

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // 두 개 탭 초기화
    _loadInquiryHistory(); // 저장된 문의내역 불러오기
  }

  // SharedPreferences에서 문의내역 불러오기
  Future<void> _loadInquiryHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedHistory = prefs.getStringList('inquiryHistory');
    if (savedHistory != null) {
      setState(() => inquiryHistory = savedHistory);
    }
  }

  // 문의내역을 SharedPreferences에 저장
  Future<void> _saveInquiryHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('inquiryHistory', inquiryHistory);
  }

  // 새로운 문의 항목을 추가 및 저장
  void _addInquiry(String category, String content) {
    final now = DateTime.now();
    final entry = "[${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}]\n"
        "카테고리: $category\n문의내용: $content";
    setState(() => inquiryHistory.insert(0, entry));
    _saveInquiryHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 전체 UI의 scaffold 구성
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(), // 상단 탭 앱바
      body: TabBarView(
        controller: _tabController,
        children: [
          MyInquiriesTab(history: inquiryHistory), // 문의 내역 탭
          InquiryTab(onInquirySent: _addInquiry),  // 문의하기 탭
        ],
      ),
    );
  }

  // 상단 앱바 + 탭 UI 구성
  AppBar _buildAppBar() {
    return AppBar(
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
            Text('고객센터', style: TextStyle(color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      bottom: TabBar(
        controller: _tabController,
        labelColor: Colors.black,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.black,
        tabs: const [
          Tab(text: '내 문의내역'),
          Tab(text: '문의하기'),
        ],
      ),
    );
  }
}

// 문의 내역 탭 위젯
// SharedPreferences에서 불러온 문의 리스트를 출력
class MyInquiriesTab extends StatelessWidget {
  final List<String> history;

  const MyInquiriesTab({required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return Center(child: Text('진행중인 문의가 없어요', style: TextStyle(fontSize: 16)));
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: history.length,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black), // 테두리
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(history[index]),
        );
      },
    );
  }
}

// 문의하기 탭 위젯
// 카테고리 선택 → 문의내용 작성 → 메일 앱 호출
class InquiryTab extends StatefulWidget {
  final void Function(String, String) onInquirySent;

  const InquiryTab({required this.onInquirySent});

  @override
  _InquiryTabState createState() => _InquiryTabState();
}

class _InquiryTabState extends State<InquiryTab> {
  String selectedCategory = ''; // 선택된 카테고리 저장

  // 카테고리 선택 처리
  void _selectCategory(String title) {
    setState(() => selectedCategory = title);
  }

  // 메일 앱 실행 (url_launcher 사용, Gmail URI 스킴 적용)
  Future<void> _sendEmail(String content, String category) async {
    final fullBody = '[문의 카테고리]\n$category\n\n[문의 내용]\n$content';
    final encodedBody = Uri.encodeComponent(fullBody);
    final Uri gmailUri = Uri.parse(
      'https://mail.google.com/mail/?view=cm&fs=1'
          '&to=jomecena26@naver.com'
          '&su=${Uri.encodeComponent("FAIR-MEETING 문의사항")}'
          '&body=$encodedBody',
    );

    if (await canLaunchUrl(gmailUri)) {
      await launchUrl(gmailUri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gmail을 열 수 없습니다')));
    }
  }

  // 문의 입력창 팝업 생성
  void _showInquiryDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('문의하기'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: '문의 내용을 입력하세요',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            child: Text('취소', style: TextStyle(color: Colors.black)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFFD9C189),
              elevation: 0,
            ),
            child: Text('보내기'),
            onPressed: () {
              final content = controller.text.trim();
              if (content.isNotEmpty && selectedCategory.isNotEmpty) {
                widget.onInquirySent(selectedCategory, content);
                _sendEmail(content, selectedCategory);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('메일 앱으로 이동 중입니다')));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('카테고리를 선택하고 내용을 입력해주세요')));
              }
            },
          ),
        ],
      ),
    );
  }

  // 전체 UI 구성
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Text('어떤 점이 궁금하신가요?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 16),
        // 카테고리 목록 생성
        ...[
          ('로그인', ['카카오계정 로그인이 안 돼요', '비회원으로 이용할 수 있나요']),
          ('약속', ['약속 알람이 안 와요', '약속을 취소하고 싶어요']),
          ('위치', ['약속 위치가 안 떠요', '현재 위치가 정확하지 않아요']),
        ].map((e) => InquiryCategory(
          title: e.$1,
          examples: e.$2,
          selected: selectedCategory == e.$1,
          onTap: () => _selectCategory(e.$1),
        )),
        SizedBox(height: 24),
        HelpBox(onPressed: _showInquiryDialog), // 하단 문의하기 박스
      ],
    );
  }
}

// 문의 카테고리 선택 카드 위젯
class InquiryCategory extends StatelessWidget {
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
      onTap: onTap,
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
              padding: const EdgeInsets.symmetric(vertical: 4),
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

// 하단 '문의하기' 버튼 박스 위젯
class HelpBox extends StatelessWidget {
  final VoidCallback onPressed;

  const HelpBox({required this.onPressed});

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
            onPressed: onPressed,
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
