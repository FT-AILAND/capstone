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
  'right_hip': [12, 24, 26],
  'right_knee': [24, 26, 28]
};

class SquatAnalysis implements WorkoutAnalysis {
  final Voice speaker = Voice();
  String _state = 'up'; // up, down, none

  Map<String, List<double>> _tempAngleDict = {
    'right_hip': <double>[],
    'right_knee': <double>[],
    'avg_hip_knee': <double>[],
    'foot_length': <double>[],
    'toe_location': <double>[]
  };

  Map<String, List<int>> _feedBack = {
    'not_relaxation': <int>[],
    'not_contraction': <int>[],
    'hip_dominant': <int>[],
    'knee_dominant': <int>[],
    'not_knee_in': <int>[],
    'is_speed_fast': <int>[]
  };

  int _count = 0;
  bool _detecting = false;
  int targetCount;
  bool _end = false;

  get feedBack => _feedBack;
  get tempAngleDict => _tempAngleDict;
  get count => _count;
  get detecting => _detecting;
  get end => _end;
  get state => _state;

  SquatAnalysis({required this.targetCount});

  late int start;
  final List<String> _keys = jointIndx.keys.toList();
  final List<List<int>> _vals = jointIndx.values.toList();

  bool isStart = false;
  bool isKneeOut = false;
  late double footLength;
  late double kneeX;
  late double toeX;

  void detect(Pose pose) {
    // 포즈 랜드마크 추출 및 각도 계산
    Map<PoseLandmarkType, PoseLandmark> landmarks = pose.landmarks; // 관절 위치 추출
    for (int i = 0; i < jointIndx.length; i++) { // 정의된 관절 좌표 가져오기
      List<List<double>> listXyz = findXyz(_vals[i], landmarks);
      double angle = calculateAngle3D(listXyz, direction: 1); // 관절 각도 계산
      _tempAngleDict[_keys[i]]!.add(angle); // 관절 각도 저장
    }
    kneeX = landmarks[PoseLandmarkType.values[26]]!.x; // 무릎 x좌표
    toeX = landmarks[PoseLandmarkType.values[32]]!.x; // 발가락 x좌표 무릎이 발보다 바깥에 있는지 확인하는 용도

    // 발 길이와 발가락 위치 초기화
    if (_state == 'up') { // up 상태일 때는 발길이, 발가락 위치 초기화 해서 _tempAngleDict에 저장
      if (isStart == true) {
        footLength = getDistance(landmarks[PoseLandmarkType.values[32]]!,
            landmarks[PoseLandmarkType.values[30]]!);
        _tempAngleDict['foot_length']!.add(footLength);
        _tempAngleDict['toe_location']!.add(toeX);
      }
    } else if (_tempAngleDict['foot_length']!.isNotEmpty &&
        _tempAngleDict['toe_location']!.isNotEmpty) {
      if (customSum(_tempAngleDict['foot_length']!) /
                  _tempAngleDict['foot_length']!.length *
                  0.15 +
              customSum(_tempAngleDict['toe_location']!) /
                  _tempAngleDict['toe_location']!.length <
          kneeX) {
        isKneeOut = true; // down 상태일 때는 무릎이 발보다 바깥에 있는지 판단
      }
    }
    // 엉덩이와 무릎 각도 계산 및 운동 시작 확인
    double hipAngle = _tempAngleDict['right_hip']!.last;
    double kneeAngle = _tempAngleDict['right_knee']!.last;
    if (hipAngle > 215 && hipAngle < 350) { // 엉덩이 각도가 215도에서 350도 사이일 때, 엉덩이와 무릎의 평균 각도를 _tempAngleDict에 추가
      _tempAngleDict['avg_hip_knee']!.add((hipAngle + kneeAngle) / 2);
    }
    if (!isStart &&
        _detecting &&
        hipAngle > 160 &&
        hipAngle < 205 &&
        kneeAngle > 160 &&
        kneeAngle < 205) {
      speaker.sayStart();
      isStart = true;
    }

    if (!isStart) {
      int indx = _tempAngleDict['right_hip']!.length - 1;
      _tempAngleDict['right_hip']!.removeAt(indx);
      _tempAngleDict['right_knee']!.removeAt(indx);
      if (hipAngle > 215 && hipAngle < 350) {
        int indx2 = _tempAngleDict['avg_hip_knee']!.length - 1;
        _tempAngleDict['avg_hip_knee']!.removeAt(indx2);
      }
    } else {
      if (isOutlierSquats(_tempAngleDict['right_hip']!, 0) ||
          isOutlierSquats(_tempAngleDict['right_knee']!, 1)) {
        int indx = _tempAngleDict['right_hip']!.length - 1;
        _tempAngleDict['right_hip']!.removeAt(indx);
        _tempAngleDict['right_knee']!.removeAt(indx);
        if (hipAngle > 215 && hipAngle < 350) {
          int indx2 = _tempAngleDict['avg_hip_knee']!.length - 1;
          _tempAngleDict['avg_hip_knee']!.removeAt(indx2);
        }
      } else {
        bool isHipUp = hipAngle < 215;
        bool isHipDown = hipAngle > 240;
        bool isKneeUp = kneeAngle > 147.5;

        if (isHipUp && isKneeUp && _state == 'down') {
          //개수 카운팅
          ++_count;
          speaker.countingVoice(_count);
          //speaker.stopState();
          int end = DateTime.now().second;
          _state = 'up';

          if (listMin(_tempAngleDict['right_hip']!) < 205) {
            //엉덩이를 완전히 이완
            _feedBack['not_relaxation']!.add(0);
          } else {
            //엉덩이 덜 이완
            _feedBack['not_relaxation']!.add(1);
          }
          if (listMax(_tempAngleDict['right_hip']!) > 270) {
            //엉덩이가 완전히 내려간 경우
            _feedBack['not_contraction']!.add(0);
          } else {
            //엉덩이가 덜 내려간 경우
            _feedBack['not_contraction']!.add(1);
          }
          if (listMax(_tempAngleDict['avg_hip_knee']!) > 205) {
            //엉덩이가 먼저 내려간 경우
            _feedBack['hip_dominant']!.add(1);
            _feedBack['knee_dominant']!.add(0);
          } else if (listMin(_tempAngleDict['avg_hip_knee']!) < 173) {
            //무릎이 먼저 내려간 경우
            _feedBack['hip_dominant']!.add(0);
            _feedBack['knee_dominant']!.add(1);
          } else {
            //무릎과 엉덩이가 균형있게 내려간 경우
            _feedBack['hip_dominant']!.add(0);
            _feedBack['knee_dominant']!.add(0);
            ;
          }
          if (isKneeOut) {
            //무릎이 발 밖으로 나간 경우
            _feedBack['not_knee_in']!.add(1);
          } else {
            //무릎이 발 안쪽에 있는 경우
            _feedBack['not_knee_in']!.add(0);
          }
          if ((end - start) < 1.5) {
            _feedBack['is_speed_fast']!.add(1);
          } else {
            _feedBack['is_speed_fast']!.add(0);
          }

          if (_feedBack['not_knee_in']!.last == 1) {
            //무릎이 발 밖으로 나간 경우
            speaker.sayKneeOut(_count);
          } else {
            //무릎이 발 안쪽에 있는 경우
            if (_feedBack['hip_dominant']!.last == 1 ||
                _feedBack['knee_dominant']!.last == 1) {
              // 엉덩이가 먼저 내려가거나 무릎이 먼저 내려간 경우
              speaker.sayHipKnee(_count);
            } else {
              //무릎과 엉덩이가 균형있게 내려간 경우
              if (_feedBack['not_relaxation']!.last == 0) {
                //엉덩이를 완전히 이완
                if (_feedBack['not_contraction']!.last == 0) {
                  //엉덩이가 완전히 내려간 경우
                  if (_feedBack['is_speed_fast']!.last == 0) {
                    //속도가 적당한 경우
                    speaker.sayGood1(_count);
                  } else {
                    //속도가 빠른 경우
                    speaker.sayFast(_count);
                  }
                } else {
                  //엉덩이가 덜 내려간 경우
                  speaker.sayHipDown(_count);
                }
              } else {
                //엉덩이 덜 이완
                speaker.sayStretchKnee(_count);
              }
            }
          }

          //초기화
          _tempAngleDict['right_hip'] = <double>[];
          _tempAngleDict['right_knee'] = <double>[];
          _tempAngleDict['avg_hip_knee'] = <double>[];
          _tempAngleDict['foot_length'] = <double>[];
          _tempAngleDict['toe_location'] = <double>[];

          isKneeOut = false;

          if (_count == targetCount) {
            stopAnalysingDelayed();
          }
        } else if (isHipDown && !isKneeUp && _state == 'up') {
          _state = 'down';
          start = DateTime.now().second;
        }
      }
    }
  }

  // 설정한 개수만큼 score 리스트에 점수가 들어감
  // List<int> workoutToScore() {
  //   List<int> score = [];
  //   int n = _count;
  //   for (int i = 0; i < n; i++) {
  //     //_e는 pushups에 담겨있는 각각의 element
  //     int isRelaxation = 1 - _feedBack['not_relaxation']![i];
  //     int isContraction = 1 - _feedBack['not_contraction']![i];
  //     int isHipKneeGood = (_feedBack['hip_dominant']![i] == 0 &&
  //             _feedBack['knee_dominant']![i] == 0)
  //         ? 1
  //         : 0;
  //     int isKneeIn = 1 - _feedBack['not_knee_in']![i];
  //     int isSpeedgood = 1 - _feedBack['is_speed_fast']![i];
  //     score.add(isRelaxation * 10 +
  //         isContraction * 20 +
  //         isHipKneeGood * 50 +
  //         isKneeIn * 13 +
  //         isSpeedgood * 7);
  //   }
  //   return score;
  // }

  @override
  void startDetecting() {
    _detecting = true;
  }

  @override
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
      workoutName: 'squat',
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