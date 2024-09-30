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
  'right_shoulder': [14, 12, 24],
  'right_hip': [12, 24, 26],
};

class PullUpAnalysis implements WorkoutAnalysis {
  final Voice speaker = Voice();
  String _state = 'down'; // up, down, none

  Map<String, List<double>> _tempAngleDict = {
    'right_elbow': <double>[],
    'right_shoulder': <double>[],
    'right_hip': <double>[],
    'elbow_normY': <double>[],
  };

  Map<String, List<int>> _feedBack = {
    'not_relaxation': <int>[],
    'not_contraction': <int>[],
    'not_elbow_stable': <int>[],
    'is_recoil': <int>[],
    'is_speed_fast': <int>[],
  };

  int _count = 0;
  bool _detecting = false;
  int targetCount;
  bool _end = false;

  get count => _count;
  get feedBack => _feedBack;
  get tempAngleDict => _tempAngleDict;
  get detecting => _detecting;
  get end => _end;
  get state => _state;

  PullUpAnalysis({required this.targetCount});

  late int start;
  List<String> _keys = jointIndx.keys.toList();
  List<List<int>> _vals = jointIndx.values.toList();

  bool isStart = false;
  bool isTotallyContraction = false;
  bool wasTotallyContraction = false;

  void detect(Pose pose) {
    // 포즈 추정한 관절값을 바탕으로 개수를 세고, 자세를 평가
    Map<PoseLandmarkType, PoseLandmark> landmarks = pose.landmarks;
    for (int i = 0; i < jointIndx.length; i++) {
      List<List<double>> listXyz = findXyz(_vals[i], landmarks);
      double angle = calculateAngle2D(listXyz, direction: 1);

      if ((_keys[i] == 'right_shoulder') && (angle < 190)) {
        angle = 360 - angle;
      } else if ((_keys[i] == 'right_elbow') &&
          (angle > 190) &&
          (angle < 360)) {
        angle = 360 - angle;
      }
      _tempAngleDict[_keys[i]]!.add(angle);
    }
    List<double> arm = [
      landmarks[PoseLandmarkType.values[14]]!.x -
          landmarks[PoseLandmarkType.values[16]]!.x,
      landmarks[PoseLandmarkType.values[14]]!.y -
          landmarks[PoseLandmarkType.values[16]]!.y
    ];

    List<double> normY = [0, 1];
    double normY_angle = calculateAngle2DVector(arm, normY);
    if (normY_angle >= 90) {
      normY_angle = 10;
    }
    _tempAngleDict['elbow_normY']!.add(normY_angle);

    double elbowAngle = _tempAngleDict['right_elbow']!.last;
    double shoulderAngle = _tempAngleDict['right_shoulder']!.last;
    double hipAngle = _tempAngleDict['right_hip']!.last;
    if (!isStart &&
        _detecting &&
        shoulderAngle > 190 &&
        shoulderAngle < 220 &&
        elbowAngle > 140 &&
        elbowAngle < 180 &&
        normY_angle < 15 &&
        hipAngle > 120 &&
        hipAngle < 200) {
      speaker.sayStart();
      isStart = true;
    }
    if (!isStart) {
      _tempAngleDict['right_elbow']!.removeLast();
      _tempAngleDict['right_shoulder']!.removeLast();
      _tempAngleDict['right_hip']!.removeLast();
      _tempAngleDict['elbow_normY']!.removeLast();
    } else {
      if (isOutlierPullUps(_tempAngleDict['right_elbow']!, 0) ||
          isOutlierPullUps(_tempAngleDict['right_shoulder']!, 1) ||
          isOutlierPullUps(_tempAngleDict['right_hip']!, 2)) {
        _tempAngleDict['right_elbow']!.removeLast();
        _tempAngleDict['right_shoulder']!.removeLast();
        _tempAngleDict['right_hip']!.removeLast();
        _tempAngleDict['elbow_normY']!.removeLast();
      } else {
        bool isElbowUp = elbowAngle < 97.5;
        bool isElbowDown = elbowAngle > 110 && elbowAngle < 180;
        bool isShoulderUp = shoulderAngle > 268 && shoulderAngle < 360;
        double rightMouthY = landmarks[PoseLandmarkType.values[10]]!.y;
        double rightElbowY = landmarks[PoseLandmarkType.values[14]]!.y;
        double rightWristY = landmarks[PoseLandmarkType.values[16]]!.y;

        bool isMouthUpperThanElbow = rightMouthY < rightElbowY;
        bool isMouthUpperThanWrist = rightMouthY < rightWristY;
        //완전 수축 정의
        if (!isTotallyContraction &&
            isMouthUpperThanWrist &&
            elbowAngle < 100 &&
            shoulderAngle > 280) {
          isTotallyContraction = true;
        } else if (elbowAngle > 76 && !isMouthUpperThanWrist) {
          isTotallyContraction = false;
          wasTotallyContraction = true;
        }

        if (isElbowDown &&
            !isShoulderUp &&
            _state == 'up' &&
            !isMouthUpperThanElbow) {
          //개수 카운팅
          ++_count;
          speaker.countingVoice(_count);
          //speaker.stopState();

          int end = DateTime.now().second;
          _state = 'down';
          //IsRelaxation !
          if (listMax(_tempAngleDict['right_elbow']!) > 145 &&
              listMin(_tempAngleDict['right_shoulder']!) < 250) {
            //완전히 이완한 경우
            _feedBack['not_relaxation']!.add(0);
          } else {
            //덜 이완한 경우(팔을 덜 편 경우)
            _feedBack['not_relaxation']!.add(1);
          }
          //IsContraction
          if (wasTotallyContraction) {
            //완전히 수축
            _feedBack['not_contraction']!.add(0);
          } else {
            //덜 수축된 경우
            _feedBack['not_contraction']!.add(1);
          }

          //IsElbowStable
          if (listMax(_tempAngleDict['elbow_normY']!) < 40) {
            //팔꿈치를 고정한 경우
            _feedBack['not_elbow_stable']!.add(0);
          } else {
            //팔꿈치를 고정하지 않은 경우
            _feedBack['not_elbow_stable']!.add(1);
          }

          //is_recoil
          if (listMax(_tempAngleDict['right_hip']!) > 240 &&
              listMax(_tempAngleDict['right_hip']!) < 330) {
            // 반동을 사용햇던 경우
            _feedBack['is_recoil']!.add(1);
          } else {
            // 반동을 사용하지 않은 경우
            _feedBack['is_recoil']!.add(0);
          }

          //IsSpeedGood
          if ((end - start) < 1.5) {
            //속도가 빠른 경우
            _feedBack['is_speed_fast']!.add(1);
          } else {
            //속도가 적당한 경우
            _feedBack['is_speed_fast']!.add(0);
          }

          wasTotallyContraction = false;
          isTotallyContraction = false;

          if (_feedBack['is_recoil']!.last == 0) {
            //반동을 사용하지 않은 경우
            if (_feedBack['not_elbow_stable']!.last == 0) {
              //팔꿈치를 고정한 경우
              if (_feedBack['not_contraction']!.last == 0) {
                // 완전히 수축
                if (_feedBack['not_relaxation']!.last == 0) {
                  // 완전히 이완한 경우
                  if (_feedBack['is_speed_fast']!.last == 0) {
                    //속도가 적당한 경우
                    speaker.sayGood2(_count);
                  } else {
                    //속도가 빠른 경우
                    speaker.sayFast(_count);
                  }
                } else {
                  // 덜 이완한 경우(팔을 덜 편 경우)
                  speaker.sayStretchElbow(_count);
                }
              } else {
                // 덜 수축된 경우
                speaker.sayUp(_count);
              }
            } else {
              //팔꿈치를 고정하지 않은 경우
              speaker.sayElbowFixed(_count);
            }
          } else {
            // 반동을 사용한경우
            speaker.sayDontUseRecoil(_count);
          }

          _tempAngleDict['right_hip'] = <double>[];
          _tempAngleDict['right_knee'] = <double>[];
          _tempAngleDict['right_elbow'] = <double>[];
          _tempAngleDict['elbow_normY'] = <double>[];

          if (_count == targetCount) {
            stopAnalysingDelayed();
          }
        } else if (isElbowUp &&
            isShoulderUp &&
            _state == 'down' &&
            isMouthUpperThanElbow) {
          _state = 'up';
          start = DateTime.now().second;
        }
      }
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
      workoutName: 'pull_up',
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