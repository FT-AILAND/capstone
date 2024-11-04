import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:ait_project/Pages/notification_service.dart';

// 파이어베이스 패키지
import 'package:ait_project/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';

// 페이지
import 'Users/join.dart';
import 'Users/login.dart';
import 'Navigator/bottomAppBar.dart'; // BulidBottomAppBar 위젯을 임포트

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

double appBarHeight = 40;
double mediaHeight(BuildContext context, double scale) =>
    (MediaQuery.of(context).size.height - appBarHeight) * scale;
double mediaWidth(BuildContext context, double scale) =>
    (MediaQuery.of(context).size.width) * scale;

// 메인 컬러
Color aitGreen = const Color(0xFF4EFE8A); // 초록 (하이라이트)
Color aitGrey = const Color(0xFFD9D9D9); // 회색
Color aitNavy = const Color(0xFF3D3F5A); // 네이비 (배경)

// 카메라
List<CameraDescription> cameras = [];

// 파이어베이스 초기화 함수
Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  // firebase_options import 후 options 지정을 해줘야 init이 정상적으로 진행됨
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones(); // Initialize timezone early
  await NotificationService().init(); // Initialize the notification service
  // 파이어베이스 초기화 함수
  await initializeApp();
  _initNotiSetting();

  // 카메라
  cameras = await availableCameras();
  // 앱 실행 전에 NotificationService 인스턴스 생성
  final notificationService = NotificationService();
  // Flutter 엔진 초기화
  WidgetsFlutterBinding.ensureInitialized();
  // 로컬 푸시 알림 초기화
  await notificationService.init();

  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones(); // Initialize timezone early
  await NotificationService().init(); // Initialize the notification service

  if (await Permission.scheduleExactAlarm.isDenied) {
    await Permission.scheduleExactAlarm.request();
  }
  runApp(const MyApp());
}

void _initNotiSetting() async {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final initSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  // final initSettingsIOS = IOSInitializationSettings(
  //   requestSoundPermission: false,
  //   requestBadgePermission: false,
  //   requestAlertPermission: false,
  // );
  final initSettings = InitializationSettings(
    android: initSettingsAndroid,
    // iOS: initSettingsIOS,
  );
  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]); // 세로고정
    return GetMaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF3D3F5A),
      ),
      home: const Root(), // Root 위젯을 home으로 설정
    );
  }
}

class Root extends StatelessWidget {
  const Root({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // 로그인되지 않은 상태일 때 로그인 페이지 반환
          return const MyHomePage();
        } else {
          // 로그인된 상태일 때, BuildBottomAppBar로 이동
          Future.microtask(() {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => BulidBottomAppBar(index: 0),
              ),
              (route) => false,
            );
          });
          return const SizedBox.shrink(); // Navigator로 이동 중에는 빈 위젯 반환
        }
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 로고
                SizedBox(
                  height: mediaHeight(context, 0.5),
                  child: Center(
                    child: Text(
                      'AIT',
                      style: TextStyle(
                        fontSize: 100,
                        fontWeight: FontWeight.w900,
                        color: aitGreen,
                      ),
                    ),
                  ),
                ),
                // 로그인 버튼
                const SizedBox(height: 100),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: aitGreen,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LogInPage()));
                    },
                    child: const Text(
                      '로그인',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                // 회원가입 버튼
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: aitGrey,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const JoinPage()));
                    },
                    child: const Text(
                      '회원가입',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
