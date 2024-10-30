// 카메라 화면 UI + 카메라에서 이미지 받아와서 포즈 추출기에 전달 + 스켈레톤 그려주기 + 줌인 줌아웃 기능 + 전면 후면 카메라 전환 기능
// ignore_for_file: unused_field
import 'dart:io';

import 'package:ait_project/models/workout_result.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

import '../main.dart';
import '/models/workout_analysis.dart';
import '/Pages/workout_result_page.dart';

enum ScreenMode { liveFeed, gallery }

final _orientations = {
  DeviceOrientation.portraitUp: 0,
  DeviceOrientation.landscapeLeft: 90,
  DeviceOrientation.portraitDown: 180,
  DeviceOrientation.landscapeRight: 270,
};

// 카메라 화면
// ignore: must_be_immutable
class CameraView extends StatefulWidget {
  CameraView({
    Key? key,
    required this.title,
    required this.customPaint,
    required this.onImage,
    this.initialDirection = CameraLensDirection.back,
    required this.workoutAnalysis,
  }) : super(key: key);

  final String title;
  // 스켈레톤 그려주는 객체
  final CustomPaint? customPaint;
  // 이미지 받을 때마다 실행하는 함수
  final Function(InputImage inputImage) onImage;
  // 카메라 렌즈 방향 변수
  final CameraLensDirection initialDirection;

  WorkoutAnalysis workoutAnalysis;

  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  ScreenMode _mode = ScreenMode.liveFeed;
  // 카메라 다루는 변수
  CameraController? _controller;

  File? _image;
  ImagePicker? _imagePicker;

  // 카메라 인덱스
  int _cameraIndex = -1;
  // 확대 축소 레벨
  double zoomLevel = 0.0, minZoomLevel = 0.0, maxZoomLevel = 0.0;
  // 카메라 렌즈 변경 변수
  bool _changingCameraLens = false;

  @override
  void initState() {
    super.initState();
    // Change the status bar appearance
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Makes the status bar transparent
      statusBarIconBrightness:
          Brightness.dark, // Dark icons for light background
    ));

    _imagePicker = ImagePicker();

    // 카메라 설정. 기기에서 실행 가능한 카메라, 카메라 방향 설정...
    if (cameras.any(
      (element) =>
          element.lensDirection == widget.initialDirection &&
          element.sensorOrientation == 90,
    )) {
      _cameraIndex = cameras.indexOf(
        cameras.firstWhere((element) =>
            element.lensDirection == widget.initialDirection &&
            element.sensorOrientation == 90),
      );
    } else {
      for (var i = 0; i < cameras.length; i++) {
        if (cameras[i].lensDirection == widget.initialDirection) {
          _cameraIndex = i;
          break;
        }
      }
    }

    // 카메라 실행 가능하면 포즈 추출 시작
    if (_cameraIndex != -1) {
      _startLiveFeed();
    }
  }

  @override
  void dispose() {
    _stopLiveFeed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title == 'Pull Up'
              ? '풀업'
              : widget.title == 'Squat'
                  ? '스쿼트'
                  : widget.title == 'Push Up'
                      ? '푸시업'
                      : widget.title,
          style: TextStyle(color: const Color(0xFF4EFE8A)),
        ),
        backgroundColor: const Color(0xFF3D3F5A),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: _switchLiveCamera,
              child: const Icon(
                Icons.flip_camera_android_outlined,
                size: 40,
                color: const Color(0xFF4EFE8A),
              ),
            ),
          )
        ],
      ),
      // 카메라 화면 보여주기 + 화면에서 실시간으로 포즈 추출
      body: _liveFeedBody(),
      floatingActionButton: _floatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget? _floatingActionButton() {
    // change state when workoutAnalysis's detect & analysis value is change
    return SizedBox(
        height: 70.0,
        width: 70.0,
        child: FloatingActionButton(
            backgroundColor:
                const Color(0xFF4EFE8A), // Green highlight color for AppBar,
            child: widget.workoutAnalysis.end
                ? const Icon(
                    Icons.poll,
                    size: 40,
                  ) // 그래프 아이콘 (end = true)
                : (widget.workoutAnalysis.detecting // (end = false)
                    ? const Icon(Icons.stop,
                        size: 40) // 일시정지 아이콘 (detecting = true)
                    : const Icon(Icons.play_arrow_rounded,
                        size: 40)), // 재생 아이콘 (detecting = false)
            onPressed: () async {
              try {
                // 그래프 아이콘 (end = true) 일 때 누르면 동작
                if (widget.workoutAnalysis.end) {
                  // 카메라 컨트롤러가 있다면 해제
                  if (_controller != null) {
                    await _controller!.stopImageStream();
                    await _controller!.dispose();
                    _controller = null;
                  }

                  try {
                    // 운동이 끝났을 때
                    WorkoutResult workoutResult =
                        await widget.workoutAnalysis.makeWorkoutResult();

                    // 현재 라우트 스택 출력
                    print('Current route stack: ${Get.routeTree}');

                    // WorkDetailPage로 돌아가기 시도
                    Get.until((route) {
                      print('Checking route: ${route.settings.name}');
                      return route.settings.name == '/WorkDetailPage';
                    });

                    // 결과 페이지로 이동
                    await Get.to(
                        () => WorkoutResultPage(workoutResult: workoutResult));
                  } catch (e) {
                    print('운동 종료 처리 중 오류 발생: $e');
                    Get.snackbar('오류', '오류가 발생했습니다. 다시 시도해주세요.');
                  }
                } else if (widget.workoutAnalysis.detecting) {
                  // detecting = true 일 때 stopAnalysing()을 호출하여 운동을 일시정지
                  widget.workoutAnalysis.stopAnalysing();
                } else {
                  // 운동이 시작되지 않았을 때 startDetectingDelayed()를 호출하여 지연 후 운동을 시작
                  widget.workoutAnalysis.startDetectingDelayed();
                }
              } catch (e) {
                print(e);
              }
            }));
  }

  // 카메라 화면 보여주기 + 화면에서 실시간으로 포즈 추출
  Widget _liveFeedBody() {
    if (_controller?.value.isInitialized == false) {
      return Container();
    }
    final size = MediaQuery.of(context).size;
    // 화면 및 카메라 비율에 따른 스케일 계산
    // 원문: calculate scale depending on screen and camera ratios
    // this is actually size.aspectRatio / (1 / camera.aspectRatio)
    // because camera preview size is received as landscape
    // but we're calculating for portrait orientation
    var scale = size.aspectRatio * _controller!.value.aspectRatio;

    // to prevent scaling down, invert the value
    if (scale < 1) scale = 1 / scale;

    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // 전면 후면 변경 시 화면 변경 처리
          Transform.scale(
            scale: scale,
            child: Center(
              child: _changingCameraLens
                  ? const Center(
                      child: Text('Changing camera lens'),
                    )
                  : CameraPreview(_controller!),
            ),
          ),
          // 추출된 스켈레톤 그리기
          if (widget.customPaint != null) widget.customPaint!,
          // Positioned.fill(
          //   child: Align(
          //     alignment: Alignment.topCenter,
          //     child: _showWorkoutProcess(),
          //   ),
          // ),
          Positioned.fill(
              child: Align(
            alignment: Alignment.topLeft,
            child:
                // _showAngleText()
                _buildTextWithBackground("${widget.workoutAnalysis.count}"),
          )),
          Positioned.fill(
              child: Align(
                  alignment: Alignment.topRight, child: _showFeedbackText()))
        ],
      ),
    );
  }

  // 실시간으로 카메라에서 이미지 받기(비동기적)
  Future _startLiveFeed() async {
    final camera = cameras[_cameraIndex];
    _controller = CameraController(
      camera,
      ResolutionPreset.low,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21 // for Android
          : ImageFormatGroup.bgra8888, // for iOS
    );
    _controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }
      // 이미지 받은 것을 _processCameraImage 함수로 처리
      _controller?.startImageStream(_processCameraImage);
      setState(() {});
    });
  }

  Future _stopLiveFeed() async {
    if (_controller != null) {
      await _controller!.stopImageStream();
      await _controller!.dispose();
      _controller = null;
    }
  }

  // 전면<->후면 카메라 변경 함수
  Future _switchLiveCamera() async {
    setState(() => _changingCameraLens = true);
    _cameraIndex = (_cameraIndex + 1) % cameras.length;

    await _stopLiveFeed();
    await _startLiveFeed();
    setState(() => _changingCameraLens = false);
  }

  // 카메라에서 실시간으로 받아온 이미치 처리: PoseDetectorView에서 받아온 함수인 onImage(이미지에 포즈가 추출되었으면 스켈레톤 그려주는 함수) 실행
  Future _processCameraImage(CameraImage image) async {
    final WriteBuffer allBytes = WriteBuffer();

    for (Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }

    // final bytes = allBytes.done().buffer.asUint8List();

    // final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());

    final camera = cameras[_cameraIndex];

    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? imageRotation;
    if (Platform.isIOS) {
      imageRotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation =
          _orientations[_controller!.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        // front-facing
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        // back-facing
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      imageRotation =
          InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (imageRotation == null) return null;

    // get image format
    final inputImageFormat =
        InputImageFormatValue.fromRawValue(image.format.raw);
    // validate format depending on platform
    // only supported formats:
    // * nv21 for Android
    // * bgra8888 for iOS
    if (inputImageFormat == null ||
        (Platform.isAndroid && inputImageFormat != InputImageFormat.nv21) ||
        (Platform.isIOS && inputImageFormat != InputImageFormat.bgra8888))
      return null;

    // since format is constraint to nv21 or bgra8888, both only have one plane
    if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    final inputImage = InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: imageRotation, // used only in Android
        format: inputImageFormat, // used only in iOS
        bytesPerRow: plane.bytesPerRow, // used only in iOS
      ),
    );

    widget.onImage(inputImage);
  }

  // Widget _showWorkoutProcess() {
  //   String processingString;
  //   if (widget.workoutAnalysis.end) {
  //     processingString = '운동분석종료';
  //   } else {
  //     if (widget.workoutAnalysis.detecting) {
  //       processingString = '운동분석';
  //     } else {
  //       processingString = '운동분석대기';
  //     }
  //   }

  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.center,
  //     children: [
  //       _buildTextWithBackground(processingString),
  //       _buildTextWithBackground(
  //           "${widget.title == 'Pull Up' ? '풀업' : widget.title == 'Squat' ? '스쿼트' : widget.title == 'Push Up' ? '푸시업' : widget.title} 개수: ${widget.workoutAnalysis.count}"),
  //     ],
  //   );
  // }

  // Widget _showAngleText() {
  //   List<Widget> li = <Widget>[
  //     _buildTextWithBackground("운동상태: ${widget.workoutAnalysis.state}"),
  //   ];
  //   for (String key in widget.workoutAnalysis.tempAngleDict.keys.toList()) {
  //     try {
  //       if (widget.workoutAnalysis.tempAngleDict[key]?.isNotEmpty) {
  //         double angle = widget.workoutAnalysis.tempAngleDict[key]?.last;
  //         li.add(_buildTextWithBackground(
  //           "$key : ${double.parse((angle.toStringAsFixed(1)))}",
  //         ));
  //       }
  //     } catch (e) {
  //       print("각도 텍스트화 에러. 에러코드 : $e");
  //     }
  //   }
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: li,
  //   );
  // }

  final Map<String, String> feedbackTranslation = {
    'not_elbow_up': '이완 부족',
    'not_elbow_down': '수축 부족',
    'is_hip_up': '골반 상승',
    'is_hip_down': '골반 하강',
    'is_knee_down': '무릎 하강',
    'is_speed_fast': '속도 과다',
    'not_relaxation': '이완 부족',
    'not_contraction': '수축 부족',
    'not_elbow_stable': '팔 불안정',
    'is_recoil': '반동 사용',
    'hip_dominant': '엉덩이빠른수축',
    'knee_dominant': '무릎빠른수축',
    'not_knee_in': '무릎전방이동',
  };

  Widget _showFeedbackText() {
    List<Widget> li = <Widget>[
      _buildTextWithBackground("피드백 결과"),
    ];

    for (String key in widget.workoutAnalysis.feedBack.keys.toList()) {
      try {
        if (widget.workoutAnalysis.feedBack[key]?.isNotEmpty) {
          String val =
              widget.workoutAnalysis.feedBack[key]?.last == 1 ? 'O' : 'X';

          // Translate the key from English to Korean
          String translatedKey = feedbackTranslation[key] ??
              key; // Use the Korean translation or the key if not found

          li.add(_buildTextWithBackground(
            "$translatedKey : $val",
            textColor: widget.workoutAnalysis.feedBack[key]?.last == 1
                ? Colors.redAccent
                : Colors.greenAccent,
          ));
        }
      } catch (e) {
        print("피드백 결과 불러오기 에러. 에러코드: $e");
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: li,
    );
  }

// Helper method to build text with a background for better readability
  Widget _buildTextWithBackground(String text,
      {Color textColor = Colors.white, double fontSize = 20}) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0),
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
        decoration: BoxDecoration(
          color: Colors.black
              .withOpacity(0.3), // Semi-transparent black background
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
