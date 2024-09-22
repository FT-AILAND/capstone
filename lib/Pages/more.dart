import 'package:flutter/material.dart';

// 페이지
import '../main.dart';

// 위젯
class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '더보기', 
          style: TextStyle(
            color: Colors.white
            )),
        backgroundColor: aitNavy,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('내 정보', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            _buildMenuItem('신체 정보 수정', onTap: () {}),
            _buildMenuItem('비밀번호 수정', onTap: () {}),
            SizedBox(height: 24),
            Text('설정', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            _buildMenuItem('알림설정', onTap: () {}),
            _buildMenuItem('도움말', onTap: () {}),
            SizedBox(height: 8),
            _buildTextButton('로그아웃', onPressed: () {}),
            _buildTextButton('회원탈퇴', onPressed: () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontSize: 16)),
            Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildTextButton(String title, {required VoidCallback onPressed}) {
    return TextButton(
      onPressed: onPressed,
      child: Text(title, style: TextStyle(color: Colors.black, fontSize: 16)),
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 12.0),
        alignment: Alignment.centerLeft,
      ),
    );
  }
}