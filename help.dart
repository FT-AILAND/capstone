import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ait_project/main.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  Widget _buildInfoSection(String title, String content, {required IconData icon, String? link}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: SizedBox(
              width: 40,
              height: 40,
              child: CircleAvatar(
                backgroundColor: Colors.white60,
                child: Icon(icon, color: Colors.white, size: 24),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 10),
            child: SizedBox(
              height: 45,
              child: VerticalDivider(
                color: Colors.white30,
                thickness: 1,
                width: 20,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                Text(
                  title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 15),
                Text(
                  content,
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
                if (link != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _launchURL(link),
                      child: const Text('자세히 보기', style: TextStyle(color: Colors.blue)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: aitNavy,
      appBar: AppBar(
        backgroundColor: aitNavy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '도움말',
          style: TextStyle(
            fontSize: 25,
            color: Colors.white,
            fontWeight: FontWeight.w900,
          )
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          children: [
            _buildInfoSection(
              '심장 점수를 통해 건강 유지하기',
              '미국심장협회(AHA)에서는 심장을 건강하게 유지하기 위해 자주 움직이는 것을 권장합니다. AHA에 따르면 매주 적어도 150분간의 적당한 활동 또는 75분간의 격렬한 활동을 하는 것이 좋습니다. AIT에서는 전문 기관에서 제시한 권장사항을 따르는 데 도움이 되도록 운동량을 추적합니다.',
              icon: Icons.favorite,
            ),
            _buildInfoSection(
              '제3자와 공유되는 데이터 없음',
              '개발자에 따르면 앱에서 사용자 데이터를 타사 또는 타 기관과 공유하지 않습니다.',
              icon: Icons.security,
              link: 'https://support.google.com/googleplay?p=data_disclosure'
            ),
            _buildInfoSection(
              '수집된 데이터',
              '이 앱에서 수집할 수 있는 데이터',
              icon: Icons.data_usage,
            ),
            _buildInfoSection(
              '기기 또는 기타 ID',
              '기기 또는 기타 ID',
              icon: Icons.phone_android,
            ),
            _buildInfoSection(
              '건강 및 피트니스',
              '피트니스 정보',
              icon: Icons.fitness_center,
            ),
            _buildInfoSection(
              '앱 활동',
              '앱 상호작용',
              icon: Icons.touch_app,
            ),
            _buildInfoSection(
              '앱 정보 및 성능',
              '비정상 종료 로그 및 진단',
              icon: Icons.info,
            ),
            _buildInfoSection(
              '개인 정보',
              '이름 및 이메일 주소',
              icon: Icons.person,
            ),
            _buildInfoSection(
              '보안 관행',
              '다음은 앱에서 수집하고 공유할 수 있는 데이터의 유형 및 앱에서 사용할 수 있는 보안 관행에 관해 개발자가 제공한 세부정보입니다. 데이터 관행은 앱 버전 및 사용, 사용자의 지역, 연령에 따라 다를 수 있습니다.',
              icon: Icons.security,
              link: 'https://support.google.com/googleplay?p=data_disclosure'
            ),
            _buildInfoSection(
              '전송 중 데이터 암호화됨',
              '데이터가 보안 연결을 통해 전송됩니다.',
              icon: Icons.lock,
            ),
            _buildInfoSection(
              '데이터 삭제를 요청할 수 있음',
              '개발자가 데이터 삭제를 요청할 방법을 제공합니다.',
              icon: Icons.delete,
            ),
          ],
        ),
      ),
    );
  }
}