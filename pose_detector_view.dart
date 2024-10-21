import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '/painter/pose_painter.dart';

// 페이지
import '/models/pull_up_analysis.dart';
import '/models/push_up_analysis.dart';
import '/models/squat_analysis.dart';
import '/models/workout_analysis.dart';

import 'camera_view.dart';

// 카메라에서 스켈레톤 추출하는 화면
// ignore: must_be_immutable
class PoseDetectorView extends StatefulWidget { // using mlkit poseDetector object
  PoseDetectorView({
      Key? key, 
      required this.workoutName, 
      required this.targetCount})
      : super(key: key);
  String workoutName;
  int targetCount;

  @override
  State<StatefulWidget> createState() => _PoseDetectorViewState();
}

class _PoseDetectorViewState extends State<PoseDetectorView> {
  // PoseDetector poseDetector = GoogleMlKit.vision.poseDetector(
  //     poseDetectorOptions:
  //         PoseDetectorOptions(model: PoseDetectionModel.accurate));

  // 스켈레톤 추출 변수 선언(google_mlkit_pose_detection 라이브러리)
  final PoseDetector poseDetector =
      PoseDetector(options: PoseDetectorOptions());
  bool _canProcess = true;
  bool isBusy = false;
  // 스켈레톤 모양을 그려주는 변수
  CustomPaint? customPaint;
  late WorkoutAnalysis workoutAnalysis;
  Map<String, double> inputMap = {};

  @override
  void initState() { // initiate workoutAnalysis abstract class object
    super.initState();
    if (widget.workoutName == 'Push Up') { 
      workoutAnalysis = PushUpAnalysis(targetCount: widget.targetCount);
    } else if (widget.workoutName == 'Squat') {
      workoutAnalysis = SquatAnalysis(targetCount: widget.targetCount);
    } else if (widget.workoutName == 'Pull Up') {
      workoutAnalysis = PullUpAnalysis(targetCount: widget.targetCount);
    } else {
      workoutAnalysis = PullUpAnalysis(targetCount: widget.targetCount);
    }
  }

  @override
  void dispose() async {
    _canProcess = false;
    poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 카메라뷰 보이기
    return CameraView(
      title: widget.workoutName,
      // 스켈레톤 그려주는 객체 전달
      customPaint: customPaint,
      // 카메라에서 전해주는 이미지 받을 때마다 아래 함수 실행
      onImage: (inputImage) {
        processImage(inputImage);
      },
      workoutAnalysis: workoutAnalysis,
    );
  }

  // 카메라에서 실시간으로 받아온 이미지 처리: 이미지에 포즈가 추출되었으면 스켈레톤 그려주기
  Future<void> processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (isBusy) return;
    isBusy = true;

    if (workoutAnalysis.end && workoutAnalysis.detecting) {
      workoutAnalysis.saveWorkoutResult(); // send workout result to firebase server
      workoutAnalysis.stopDetecting(); 
    }

    // poseDetector에서 추출된 포즈 가져오기
    List<Pose> poses = await poseDetector.processImage(inputImage);

    // 콘솔 확인용
    // print('Found ${poses.length} poses');

    // 이미지가 정상적이면 포즈에 스켈레톤 그려주기
    if (inputImage.metadata?.size != null && 
      inputImage.metadata?.rotation != null) {
        if (poses.isNotEmpty && workoutAnalysis.detecting && !workoutAnalysis.end) {
          workoutAnalysis.detect(poses[0]); // analysis workout by poseDector pose value
          // 콘솔 확인용 (너무 많이 떠서 없앰)
          // print("현재 ${widget.workoutName} 개수 :");
          // print(workoutAnalysis.count);
        }
        final painter = PosePainter(
          poses, 
          inputImage.metadata!.size,
          inputImage.metadata!.rotation
        );
        customPaint = CustomPaint(
          painter: painter
        );
    } else {
      // 추출된 포즈 없음
      customPaint = null;
    }
    isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}