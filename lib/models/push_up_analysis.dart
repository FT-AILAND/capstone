import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:convert';

// 파이어베이스
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '/utils/function_utils.dart';
import '/googleTTS/voice.dart';

// 페이지
import '/models/workout_analysis.dart';
import '/models/workout_result.dart';

const Map<String, List<int>> jointIndx = {
  'right_elbow': [16, 14, 12],
  'right_hip': [12, 24, 26],
  'right_knee': [24, 26, 28]
};

class PushUpAnalysis implements WorkoutAnalysis {
  final Voice speaker = Voice();
  String _state = 'up'; // up, down, none

  Map<String, List<double>> _tempAngleDict = {
    'right_elbow': <double>[],
    'right_hip': <double>[],
    'right_knee': <double>[]
  };

  Map<String, List<int>> _feedBack = {
    'not_elbow_up': <int>[],
    'not_elbow_down': <int>[],
    'is_hip_up': <int>[],
    'is_hip_down': <int>[],
    'is_knee_down': <int>[],
    'is_speed_fast': <int>[]
  };

  int _count = 0;
  bool _detecting = false;
  bool _end = false;
  int targetCount;

  get count => _count;
  get feedBack => _feedBack;
  get tempAngleDict => _tempAngleDict;
  get detecting => _detecting;
  get end => _end;
  get state => _state;

  PushUpAnalysis({required this.targetCount});

  late int start;
  final List<String> _keys = jointIndx.keys.toList();
  final List<List<int>> _vals = jointIndx.values.toList();

  bool isStart = false;

  void detect(Pose pose) {
    // 포즈 추정한 관절값을 바탕으로 개수를 세고, 자세를 평가
    Map<PoseLandmarkType, PoseLandmark> landmarks = pose.landmarks;
    //포즈 추정한 관절값들을 가져오는 메서드
    try {
      for (int i = 0; i < jointIndx.length; i++) {
        List<List<double>> listXyz = findXyz(_vals[i], landmarks);
        double angle = calculateAngle2D(listXyz, direction: 1);

        _tempAngleDict[_keys[i]]!.add(angle);
      }
      double elbowAngle = _tempAngleDict['right_elbow']!.last;
      bool isElbowUp = (elbowAngle > 130);
      bool isElbowDown = (elbowAngle < 110);

      double hipAngle = _tempAngleDict['right_hip']!.last;
      bool hipCondition = (hipAngle > 140) && (hipAngle < 220);

      double kneeAngle = _tempAngleDict['right_knee']!.last;
      bool kneeCondition = kneeAngle > 130 && kneeAngle < 205;
      bool lowerBodyConditon = hipCondition && kneeCondition;
      if (!isStart && _detecting) {
        bool isPushUpAngle = elbowAngle > 140 &&
            elbowAngle < 190 &&
            hipAngle > 140 &&
            hipAngle < 190 &&
            kneeAngle > 125 &&
            kneeAngle < 180;
        if (isPushUpAngle) {
          speaker.sayStart();
          isStart = true;
        }
      }
      if (!isStart) {
        _tempAngleDict['right_elbow']!.removeLast();
        _tempAngleDict['right_hip']!.removeLast();
        _tempAngleDict['right_knee']!.removeLast();
      } else {
        if (isOutlierPushUps(_tempAngleDict['right_elbow']!, 0) ||
            isOutlierPushUps(_tempAngleDict['right_hip']!, 1) ||
            isOutlierPushUps(_tempAngleDict['right_knee']!, 2)) {
          _tempAngleDict['right_elbow']!.removeLast();
          _tempAngleDict['right_hip']!.removeLast();
          _tempAngleDict['right_knee']!.removeLast();
        } else {
          if (isElbowUp && (_state == 'down') && lowerBodyConditon) {
            int end = DateTime.now().second;
            _state = 'up';
            _count += 1;
            speaker.countingVoice(_count);
            //speaker.stopState();

            if (listMax(_tempAngleDict['right_elbow']!) > 160) {
              //팔꿈치를 완전히 핀 경우
              _feedBack['not_elbow_up']!.add(0);
            } else {
              //팔꿈치를 덜 핀 경우
              _feedBack['not_elbow_up']!.add(1);
            }

            if (listMin(_tempAngleDict['right_elbow']!) < 80) {
              //팔꿈치를 완전히 굽힌 경우
              _feedBack['not_elbow_down']!.add(0);
            } else {
              //팔꿈치를 덜 굽힌 경우
              _feedBack['not_elbow_down']!.add(1);
            }

            //푸쉬업 하나당 골반 판단
            if (listMin(_tempAngleDict['right_hip']!) < 160) {
              //골반이 내려간 경우
              _feedBack['is_hip_up']!.add(0);
              _feedBack['is_hip_down']!.add(1);
            } else if (listMax(_tempAngleDict['right_hip']!) > 250) {
              //골반이 올라간 경우
              _feedBack['is_hip_up']!.add(1);
              _feedBack['is_hip_down']!.add(0);
            } else {
              //정상
              _feedBack['is_hip_up']!.add(0);
              _feedBack['is_hip_down']!.add(0);
            }

            //knee conditon
            if (listMin(_tempAngleDict['right_knee']!) < 130) {
              //무릎이 내려간 경우
              _feedBack['is_knee_down']!.add(1);
            } else {
              //무릎이 정상인 경우
              _feedBack['is_knee_down']!.add(0);
            }

            //speed
            if ((end - start) < 1) {
              //속도가 빠른 경우
              _feedBack['is_speed_fast']!.add(1);
            } else {
              //속도가 적당한 경우
              _feedBack['is_speed_fast']!.add(0);
            }

            if (_feedBack['is_hip_down']!.last == 1) {
              //골반이 내려간 경우
              speaker.sayHipUp(_count);
            } else if (_feedBack['is_hip_up']!.last == 1) {
              //골반이 올라간 경우
              speaker.sayHipDown(_count);
            } else {
              if (_feedBack['is_knee_down']!.last == 1) {
                //무릎이 내려간 경우
                speaker.sayKneeUp(_count);
              } else {
                //무릎이 정상인 경우
                if (_feedBack['not_elbow_up']!.last == 0) {
                  // 팔꿈치를 완전히 핀 경우
                  if (_feedBack['not_elbow_down']!.last == 0) {
                    // 팔꿈치를 완전히 굽힌 경우
                    if (feedBack['is_speed_fast']!.last == 0) {
                      //속도가 적당한 경우
                      speaker.sayGood1(_count);
                    } else {
                      //속도가 빠른 경우
                      speaker.sayFast(_count);
                    }
                  } else {
                    //팔꿈치를 덜 굽힌 경우
                    speaker.sayBendElbow(_count);
                  }
                } else {
                  // 팔꿈치를 덜 핀 경우
                  speaker.sayStretchElbow(_count);
                }
              }
            }

            //초기화
            _tempAngleDict['right_elbow'] = <double>[];
            _tempAngleDict['right_hip'] = <double>[];
            _tempAngleDict['right_knee'] = <double>[];

            if (_count == targetCount) {
              stopAnalysingDelayed();
            }
          } else if (isElbowDown && _state == 'up' && lowerBodyConditon) {
            _state = 'down';
            start = DateTime.now().second;
          }
        }
      }
    } catch (e) {
      print("detect function에서 에러가 발생 : $e");
    }
  }

  @override
  void startDetecting() {
    _detecting = true;
  }

  Future<void> startDetectingDelayed() async {
    speaker.sayStartDelayed();
    await Future.delayed(const Duration(seconds: 5), () {
      startDetecting();
    });
  }

  void stopDetecting() {
    _detecting = false;
  }

  void stopAnalysing() {
    _end = true;
  }

  Future<void> stopAnalysingDelayed() async {
    stopAnalysing();
    await Future.delayed(const Duration(seconds: 1), () {
      speaker.sayEnd();
    });
  }

  Future<WorkoutResult> makeWorkoutResult() async {

    User? user = FirebaseAuth.instance.currentUser;
    String userUid = user!.uid;

    // 사용자의 nickname을 가져옵니다.
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();
    String nickname = userDoc.get('nickname') as String;

    // 피드백 합을 저장할 리스트 선언
    List<int> feedbackCounts = <int>[]; // sum of feedback which value is 1
    // 맵의 모든 키를 가져와서 반복문을 실행
    for (String key in _feedBack.keys.toList()) {
      int tmp = 0;
      // 각 키에 해당하는 피드백 리스트의 값을 반복문을 통해 하나씩 가져와서 더함
      for (int i = 0; i < _count; i++) {
        tmp += _feedBack[key]![i];
      }
      feedbackCounts.add(tmp); // feedback_counts 리스트에 추가
    }

    WorkoutResult workoutResult = WorkoutResult(
      user: nickname, // firebase로 구현
      uid: userUid, // firebase로 구현
      workoutName: 'push_up',
      count: _count,
      feedbackCounts: feedbackCounts,
      timestamp: DateTime.now(),
    );

    return workoutResult;
  }

  void saveWorkoutResult() async {
    WorkoutResult workoutResult = await makeWorkoutResult();
    String json = jsonEncode(workoutResult);

    // 콘솔 확인 - 생성되는 json 객체 확인
    print(json);

    // WidgetsFlutterBinding.ensureInitialized();
    // await Firebase.initializeApp();

    // 파이어베이스에서 exercise_DB 컬렉션 참조
    CollectionReference exerciseDB = FirebaseFirestore.instance.collection('exercise_DB');

    // 파이어베이스에 운동데이터 저장하는 함수
    Future<void> exercisestart() {
      print("streamstart");
      // Firestore에 새로운 문서를 추가하고, 운동 결과 데이터를 JSON 형식으로 저장합니다.
      // doc()을 호출하면 Firestore가 자동으로 문서 ID를 생성해 줍니다.
      return exerciseDB.doc().set(workoutResult.toJson())
          .then((value) => print("json added")) // 저장 성공 시 콘솔에 성공 메시지를 출력
          .catchError((error) => print("Failed to add json: $error")); // 저장 실패 시 오류 메시지를 출력
    }
    exercisestart(); // 함수 실행

    print("streamend");
  }
}