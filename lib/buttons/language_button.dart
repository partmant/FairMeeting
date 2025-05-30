import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageSettingsPage extends StatefulWidget {
  const LanguageSettingsPage({Key? key}) : super(key: key);

  @override
  State<LanguageSettingsPage> createState() => _LanguageSettingsPageState();
}

class _LanguageSettingsPageState extends State<LanguageSettingsPage> {
  String _selectedLanguage = 'ko';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('language') ?? 'ko';
    });
  }

  Future<void> _saveLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', code);
  }

  void _onLanguageSelected(String code) {
    setState(() {
      _selectedLanguage = code;
    });
    _saveLanguage(code);
  }

  Widget buildDivider() {
    return const Divider(height: 13, thickness: 1.1, color: Color(0xFFD9C189));
  }

  Widget buildLanguageTile({required String label, required String code}) {
    final isSelected = _selectedLanguage == code;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: InkWell(
        onTap: () => _onLanguageSelected(code),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? Colors.black : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 25),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.language, color: Colors.black, size: 30),
              SizedBox(width: 8),
              Text(
                '언어/Language',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          buildLanguageTile(label: '한국어 (Korean)', code: 'ko'),
          buildDivider(),
          buildLanguageTile(label: '영어 (English)', code: 'en'),
          buildDivider(),
        ],
      ),
    );
  }
}
