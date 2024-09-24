import 'package:flutter/material.dart';

// 파이어베이스
import 'package:firebase_auth/firebase_auth.dart';

// 페이지
import '../main.dart';
import 'package:ait_project/Users/Edit/editBody.dart';
import 'package:ait_project/Users/Edit/deleteAccount.dart';
import 'package:ait_project/Users/Edit/editPassword.dart';

// 위젯
class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '더보기', 
          style: TextStyle(
            fontSize: 25, 
            color: Colors.white,
            fontWeight: FontWeight.w900,
          )),
        backgroundColor: aitNavy,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 10),

            // 내 정보
            const Text(
              '내 정보', 
              style: TextStyle(
                fontSize: 15, 
                color: Colors.white
              )
            ),
            const SizedBox(height: 20),

            // 신체 정보 수정
            _buildMenuItem('신체 정보 수정', onTap: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditBody(),
                ),
              );
            }),
            // 비밀번호 수정
            _buildMenuItem('비밀번호 수정', onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditPassword(),
                ),
              );
            }),

            const SizedBox(height: 30),

            // 설정
            const Text(
              '설정', 
              style: TextStyle(
                fontSize: 15,
                color: Colors.white
              )
            ),
            const SizedBox(height: 20),

            _buildMenuItem('알림설정', onTap: () {}),
            _buildMenuItem('도움말', onTap: () {}),
            _buildTextButton('로그아웃', onTap: () => _showLogoutDialog(context)),
            _buildTextButton('회원탈퇴', onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DeleteAccount(),
                ),
              );
            }),

          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title, 
              style: const TextStyle(
                fontSize: 20, 
                color: Colors.white,
                fontWeight: FontWeight.w900,
              )
            ),
            const Icon(
              Icons.chevron_right, 
              color: Colors.white,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextButton(String title, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title, 
              style: const TextStyle(
                fontSize: 20, 
                color: Colors.white,
                fontWeight: FontWeight.w900,
              )
            ),
          ],
        ),
      ),
    );
  }

  // 로그아웃 알림창
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: aitNavy,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 24), // 상하 패딩 추가
          content: SizedBox(
            height: 120, // 전체 높이 설정
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround, // 세로 방향으로 균등 배치
              children: [
                const SizedBox(height: 5), 
                const Text(
                  '로그아웃 하시겠습니까?',
                  style: TextStyle(
                    color: Colors.white, 
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5), 
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      child: Text('로그아웃', style: TextStyle(color: aitGreen, fontSize: 15)),
                      onPressed: () async {
                        try {
                          await FirebaseAuth.instance.signOut();
                           // 앱 재초기화
                          await initializeApp();
                          // 홈으로 이동
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => const MyApp()),
                            (Route<dynamic> route) => false,
                          );
                        } catch (e) {
                          print('로그아웃 중 오류 발생: $e');
                          // 오류 처리 로직 추가
                        }
                      },
                    ),
                    const SizedBox(width: 5), // 버튼 사이 간격 추가
                    TextButton(
                      child: const Text('취소', style: TextStyle(color: Colors.white, fontSize: 15)),
                      onPressed: () {
                        Navigator.of(context).pop(); // 모달 닫기
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}