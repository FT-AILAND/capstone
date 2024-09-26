import 'package:ait_project/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WorkDetailPage extends StatefulWidget {
  String workoutName;
  String description;
  bool isReadyForAI;
  String imageUrl;
  String korName;
  String guide;
  String shortDes;

  WorkDetailPage({
    super.key, 
    required this.workoutName,
    required this.description,
    required this.isReadyForAI,
    required this.imageUrl,
    required this.korName,
    required this.guide,
    required this.shortDes,
  });

  @override
  // ignore: no_logic_in_create_state
  State<WorkDetailPage> createState() => _WorkDetailPageState(
    workoutName: workoutName,
    description: description,
    isReadyForAI: isReadyForAI,
    imageUrl: imageUrl,
    korName: korName,
    guide: guide,
    shortDes: shortDes,
  );
}

class _WorkDetailPageState extends State<WorkDetailPage> {
  int _repetition = 10;
  String workoutName;
  String description;
  bool isReadyForAI;
  String imageUrl;
  String korName;
  String guide;
  String shortDes;

  _WorkDetailPageState({
    required this.workoutName,
    required this.description,
    required this.isReadyForAI,
    required this.imageUrl,
    required this.korName,
    required this.guide,
    required this.shortDes,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3D3F5A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3D3F5A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: isReadyForAI
          ? Text('AI', 
              style: TextStyle(
                fontSize: 25, 
                color: aitGreen,
                fontWeight: FontWeight.w900,
              )
            )
          : null,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 운동 이름, 한 줄 설명
                  Padding(
                    padding: const EdgeInsets.only(top: 15, left: 25, right: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.korName,
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          widget.shortDes,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: aitGreen,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 이미지
                  Padding(
                    // 이미지 외부 패딩
                    padding: const EdgeInsets.only(top: 15, left: 20, right: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF595B77).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      //margin: EdgeInsets.all(30),
                      child: Padding(
                        // 이미지 내부 패딩
                        padding: const EdgeInsets.all(15),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            widget.imageUrl,
                            // width: 80,
                            // height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 가이드, 운동설명
                  Padding(
                    padding: const EdgeInsets.only(top: 30, left: 25, right: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '가이드',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.guide,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          '운동설명',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.description,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 100), // Space for the bottom button
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.all(16),
                color: const Color(0xFF3D3F5A),
                child: ElevatedButton(
                  onPressed: widget.isReadyForAI ? _showRepetitionPicker : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.isReadyForAI ? Colors.green : Colors.grey,
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    widget.isReadyForAI ? '트레이닝 세트 횟수 지정' : 'AI기능 준비중',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRepetitionPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: CupertinoPicker(
            magnification: 1.22,
            squeeze: 1.2,
            useMagnifier: true,
            itemExtent: 32,
            scrollController: FixedExtentScrollController(
              initialItem: _repetition - 1,
            ),
            onSelectedItemChanged: (int selectedItem) {
              setState(() {
                _repetition = selectedItem + 1;
              });
            },
            children: List<Widget>.generate(100, (int index) {
              return Center(
                child: Text(
                  '${index + 1}',
                ),
              );
            }),
          ),
        ),
      ),
    ); 
  }
}