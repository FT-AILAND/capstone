import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import '/painter/pose_painter.dart';
import '/utils/function_utils.dart';

// 페이지
import '/models/pull_up_analysis.dart';
import '/models/push_up_analysis.dart';
import '/models/squat_analysis.dart';
import '/models/workout_analysis.dart';
import '/Pages/workout_result_page.dart';

import 'camera_view.dart';

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
  PoseDetector poseDetector = GoogleMlKit.vision.poseDetector(
      poseDetectorOptions:
          PoseDetectorOptions(model: PoseDetectionModel.accurate));

  // // 스켈레톤 추출 변수 선언(google_mlkit_pose_detection 라이브러리)
  // final PoseDetector poseDetector =
  //     PoseDetector(options: PoseDetectorOptions());

  bool isBusy = false;
  CustomPaint? customPaint;
  late WorkoutAnalysis workoutAnalysis;

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
    super.dispose();
    await poseDetector.close();
  }

  @override
  Widget build(BuildContext context) {
    return CameraView(
      title: widget.workoutName,
      customPaint: customPaint,
      onImage: (inputImage) {
        processImage(inputImage);
      },
      workoutAnalysis: workoutAnalysis,
    );
  }

  Future<void> processImage(InputImage inputImage) async {
    isBusy = true;
    if (workoutAnalysis.end && workoutAnalysis.detecting) {
      workoutAnalysis.saveWorkoutResult(); // send workout result to firebase server
      workoutAnalysis.stopDetecting(); 
    }
    final poses = await poseDetector.processImage(inputImage);
    print('Found ${poses.length} poses');
    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null) {
      if (poses.isNotEmpty &&
          workoutAnalysis.detecting &&
          !workoutAnalysis.end) {
        workoutAnalysis.detect(poses[0]); // analysis workout by poseDector pose value
        print("현재 ${widget.workoutName} 개수 :");
        print(workoutAnalysis.count);
      }
      final painter = PosePainter(poses, inputImage.metadata!.size,
          inputImage.metadata!.rotation);
      customPaint = CustomPaint(painter: painter);
    } else {
      customPaint = null;
    }
    isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}