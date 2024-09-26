// 카메라 화면 UI + 카메라에서 이미지 받아와서 포즈 추출기에 전달 + 스켈레톤 그려주기 + 줌인 줌아웃 기능 + 전면 후면 카메라 전환 기능
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    // for (var i = 0; i < cameras.length; i++) {
    //   if (cameras[i].lensDirection == widget.initialDirection) {
    //     _cameraIndex = i;
    //   }
    // }
    // _startLiveFeed();
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
        title: Text(widget.title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: _switchLiveCamera,
              child: const Icon(
                Icons.flip_camera_android_outlined,
                size: 40,
              ),
            ),
          )
        ],
      ),
      // 카메라 화면 보여주기 + 화면에서 실시간으로 포즈. ㅜ출
      body: _liveFeedBody(),
      floatingActionButton: _floatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget? _floatingActionButton() { // change state when workoutAnalysis's detect & analysis value is change
    return SizedBox(
        height: 70.0,
        width: 70.0,
        child: FloatingActionButton(
          child: widget.workoutAnalysis.end
              ? Icon(Icons.poll ,size: 40)
              : (widget.workoutAnalysis.detecting
                  ? Icon(Icons.pause, size: 40)
                  : Icon(Icons.play_arrow_rounded, size: 40)),
          onPressed: () async {
            try{
              if (widget.workoutAnalysis.end){
                print("1");
                int count = 0;
                Navigator.popUntil(context, (route) => count++ == 3); // pop until go to mainpage
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => WorkoutResultPage(workoutResult: widget.workoutAnalysis.makeWorkoutResult())
                  ),
                );
              } else if (widget.workoutAnalysis.detecting) {
                print("2");
                widget.workoutAnalysis.stopAnalysing();
              } else {
                print("3");
                widget.workoutAnalysis.startDetectingDelayed(); // 8 second later
              }
            } catch(e){
              print(e);
            }
            }
        )
      );
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
          Positioned.fill(
            child: Align(
              alignment: Alignment.topCenter,
              child: _showWorkoutProcess(),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.topLeft,
              child: _showAngleText()
            )
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.topRight,
              child: _showFeedbackText()
            )
          )
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
    await _controller?.stopImageStream();
    await _controller?.dispose();
    _controller = null;
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

    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());

    final camera = cameras[_cameraIndex];

    // final imageRotation = 
    //   InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    // if (imageRotation == null) return;

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
      imageRotation = InputImageRotationValue.fromRawValue(rotationCompensation);
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
        (Platform.isIOS && inputImageFormat != InputImageFormat.bgra8888)) return null;


      // since format is constraint to nv21 or bgra8888, both only have one plane
      if (image.planes.length != 1) return null;
      final plane = image.planes.first;

      final inputImage =
          InputImage.fromBytes(
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

  Widget _showWorkoutProcess() {
    String processingString;
    if (widget.workoutAnalysis.end) {
      processingString = '운동분석종료';
    } else{
      if (widget.workoutAnalysis.detecting) {
        processingString = '운동분석중';
      } else {
        processingString = '운동분석대기중';
      }
    }
    return Column(
      children: [
        Text(processingString),
        Text("${widget.title} 개수: ${widget.workoutAnalysis.count}"),
      ],
      crossAxisAlignment: CrossAxisAlignment.center
    );
  }

  Widget _showAngleText() {
    List<Widget> li = <Widget>[Text("운동상태: ${widget.workoutAnalysis.state}", style: TextStyle(fontSize: 13),)];
    for (String key in widget.workoutAnalysis.tempAngleDict.keys.toList()) {
      try {
        if (widget.workoutAnalysis.tempAngleDict[key]?.isNotEmpty) {
          double angle = widget.workoutAnalysis.tempAngleDict[key]?.last;
          li.add(Text(
            "$key : ${double.parse((angle.toStringAsFixed(1)))}",
            style: const TextStyle(
              color: Colors.black,
              fontSize: 13
            ),
          ));
        }
      } catch (e) {
        print("앵글을 텍스트로 불러오는데 에러. 에러코드 : $e");
      }
    }
    return Column(children: li, crossAxisAlignment: CrossAxisAlignment.start,);
  }

  Widget _showFeedbackText() {
    List<Widget> li = <Widget>[const Text("피드백 결과", style: TextStyle(fontSize: 13),)];
    for (String key in widget.workoutAnalysis.feedBack.keys.toList()) {
      try {
        if (widget.workoutAnalysis.feedBack[key]?.isNotEmpty) {
          String val = widget.workoutAnalysis.feedBack[key]?.last == 1 ? 'O' : 'X';
          li.add(Text(
            "$key : $val",
            style: TextStyle(
              color: widget.workoutAnalysis.feedBack[key]?.last == 1 ? Colors.redAccent : Colors.greenAccent,
              fontSize: 13
            ),
          ));
        }
      } catch (e) {
        print("피드백 결과를 불러오는데 에러. 에러코드 : $e");
      }
    }
    return Column(children: li, crossAxisAlignment: CrossAxisAlignment.start,);
  }
}