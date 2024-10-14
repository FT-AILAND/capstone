import 'dart:math';

import 'package:ait_project/main.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '/models/workout_result.dart';

class CustomizedBarChart extends StatefulWidget {
  CustomizedBarChart({Key? key, required this.workoutResult}) : super(key: key);
  final WorkoutResult workoutResult;

  @override
  State<StatefulWidget> createState() => CustomizedBarChartState();
}

class CustomizedBarChartState extends State<CustomizedBarChart> with SingleTickerProviderStateMixin {
  final Color barBackgroundColor = const Color(0xff72d8bf);
  final Duration animDuration = const Duration(milliseconds: 500);
  late List<String> feedbackNames;
  late AnimationController _animationController;
  late Animation<double> _animation;

  int touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    if(widget.workoutResult.workoutName == 'push_up'){
      feedbackNames = pushUpFeedbackNames;
    } else if(widget.workoutResult.workoutName == 'pull_up'){
      feedbackNames = pullUpFeedbackNames;
    } else { // squat
      feedbackNames = squatFeedbackNames;
    }

    _animationController = AnimationController(
      vsync: this,
      duration: animDuration,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        color: aitNavy,
        child: Padding(
          padding: const EdgeInsets.only(top: 30, bottom: 10, left: 15, right: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Row(
                children: [
                  const Text(
                    '피드백 그래프',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 10), // 텍스트와 구분선 사이의 간격
                  Expanded(
                    child: Container(
                      height: 1, // 구분선의 높이
                      color: Colors.white, // 구분선의 색상
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return BarChart(
                        mainBarData(),
                        swapAnimationDuration: animDuration,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  BarChartGroupData makeGroupData(
    int x,
    double y, {
    bool isTouched = false,
    double width = 22,
    List<int> showTooltips = const [],
  }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: max(y * _animation.value, 0.1),  // 최소 높이 설정
          color: isTouched ? Colors.white : aitGreen,
          width: width,
          borderSide: isTouched
              ? BorderSide(color: Colors.white, width: 1)
              : BorderSide(color: aitGreen, width: 0),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: max(widget.workoutResult.count!.toDouble(), 1),  // 최소 높이 설정
            color: Colors.white30,
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  List<BarChartGroupData> showingGroups() => List.generate(widget.workoutResult.feedbackCounts!.length, (i) {
        return makeGroupData(i, widget.workoutResult.feedbackCounts![i].toDouble(), isTouched: i == touchedIndex);
      });

  BarChartData mainBarData() {
    return BarChartData(
      maxY: max(widget.workoutResult.count!.toDouble(), 1),  // 최소 높이 설정
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            return BarTooltipItem(
              feedbackNames[group.x.toInt()] + '\n',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: (rod.toY / _animation.value).toStringAsFixed(0),
                  style: const TextStyle(
                    color: Colors.yellow,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        ),
        touchCallback: (FlTouchEvent event, barTouchResponse) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                barTouchResponse == null ||
                barTouchResponse.spot == null) {
              touchedIndex = -1;
              return;
            }
            touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
          });
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        // 상단 텍스트
        topTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (double value, TitleMeta meta) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  widget.workoutResult.feedbackCounts![value.toInt()].toString(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12),
                ),
              );
            },
          ),
        ),
        // 하단 텍스트
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (double value, TitleMeta meta) {
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: SizedBox(
                  width: 40,
                  child: Text(
                    feedbackNames[value.toInt()],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 4,  // 최대 4줄까지 표시
                    overflow: TextOverflow.ellipsis, 
                  ),
                ),
              );
            },
            reservedSize: 60,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: showingGroups(),
      gridData: const FlGridData(show: false),
      alignment: BarChartAlignment.spaceBetween,
    );
  }
}

// feedbackNames lists remain unchanged
List<String> pushUpFeedbackNames = [
  '이완\n부족', 
  '수축\n부족', 
  '골반\n상승', 
  '골반\n하강', 
  '무릎\n하강',
  '속도\n과다',
];

List<String> pullUpFeedbackNames = [
  '이완\n부족', 
  '수축\n부족', 
  '팔\n불안정', 
  '반동\n사용', 
  '속도\n과다',
];

List<String> squatFeedbackNames = [
  '이완\n부족', 
  '수축\n부족',  
  '엉덩이\n빠른\n수축', 
  '무릎\n빠른\n수축', 
  '무릎\n전방\n이동',
  '속도\n과다',
];
