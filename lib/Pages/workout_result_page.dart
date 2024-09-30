import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/utils/function_utils.dart';
import 'package:ait_project/main.dart';
import '/Navigator/customized_bar_chart.dart';
import '/models/workout_result.dart';

// ignore: must_be_immutable
class WorkoutResultPage extends StatelessWidget {
  WorkoutResultPage({Key? key, required this.workoutResult}) : super(key: key);
  WorkoutResult workoutResult;

  String getKoreanWorkoutName(String? workoutName) {
    switch (workoutName) {
      case 'squat':
        return '스쿼트';
      case 'push_up':
        return '푸시업';
      case 'pull_up':
        return '풀업';
      default:
        return workoutName ?? '';
    }
  }

  String getFormattedTimestamp(DateTime? timestamp) {
    if (timestamp == null) return '날짜 정보 없음';
    return DateFormat('yyyy-MM-dd HH:mm').format(timestamp);
  }

  String _getWorkoutImage(String? workoutName) {
    switch (workoutName) {
      case 'squat':
        return 'assets/squat.gif';
      case 'push_up':
        return 'assets/pushUp.gif';
      case 'pull_up':
        return 'assets/pullUp.gif';
      default:
        return 'assets/test.gif'; // 기본 이미지 경로
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '분석 결과',
          style: TextStyle(
            fontSize: 25,
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF3D3F5A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),

      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.asset(
                                _getWorkoutImage(workoutResult.workoutName),
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  getKoreanWorkoutName(workoutResult.workoutName),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900),
                                ),
                                Text(
                                  getFormattedTimestamp(workoutResult.timestamp),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${workoutResult.count}회',
                      style: const TextStyle(
                        color: Color(0XFF9FA2CE),
                        fontSize: 20,
                        fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
        
              // 피드백 그래프
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Center(
                  child: CustomizedBarChart(
                    workoutResult: workoutResult,
                  ),
                ),
              ),
        
              // 피드백 텍스트
              ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    color: aitNavy,
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                '운동 피드백',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(width: 10),  // 텍스트와 구분선 사이의 간격
                              Expanded(
                                child: Container(
                                  height: 1,  // 구분선의 높이
                                  color: Colors.white,  // 구분선의 색상
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: _buildFeedback(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedback() {
    List<int> feedbackIdx = sortFeedback(workoutResult.feedbackCounts!);
    List<String> feedbackString;
    if (workoutResult.workoutName! == 'push_up') {
      feedbackString = PushUpFeedbackString;
    } else if (workoutResult.workoutName! == 'pull_up') {
      feedbackString = PullUpFeedbackString;
    } else {
      // squat
      feedbackString = SquatFeedbackString;
    }
    
    return Column(
      children: [
        const SizedBox(height: 10),  // 상단 여백 추가
        ...feedbackIdx.take(2).map((i) => 
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),  // 각 피드백 항목의 상하 패딩
            child: Text(
              feedbackString[i],
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ).toList(),
        const SizedBox(height: 10),  // 하단 여백 추가
      ],
    );
  }
}

List<String> SquatFeedbackString = [
  '''신장 단계를 더 강조해 주세요. 적절한 근육 신장은 근섬유의 길이를 증가시켜 근비대와 가동 범위 향상에 도움이 됩니다.''',
  '''수축 강도를 높여주세요. 충분한 근수축이 이루어지지 않으면 근력 향상과 근비대 효과가 제한될 수 있습니다.''',
  '''고관절(엉덩이)이 슬관절(무릎)보다 먼저 신전되고 있습니다. 대퇴사두근과 둔근의 균형 잡힌 발달을 위해 동시에 신전되어야 합니다.''',
  '''슬관절(무릎)이 고관절(엉덩이)보다 먼저 신전되고 있습니다. 대퇴사두근과 둔근의 균형 잡힌 발달을 위해 동시에 신전되어야 합니다.''',
  '''슬관절(무릎)이 발끝을 넘어가고 있습니다. 이는 슬개건에 과도한 스트레스를 줄 수 있으며, 장기적으로 슬관절 통증을 유발할 수 있습니다.''',
  '''동작 속도가 과도하게 빠릅니다. 근육의 신장-수축 주기를 충분히 느끼며, 올바른 자세로 천천히 수행하는 것이 근육 활성화에 더 효과적입니다.'''
];

List<String> PullUpFeedbackString = [
  '''신장 단계를 더 강조해 주세요. 충분한 광배근과 상완이두근의 신장은 근섬유 길이 증가와 근력 향상에 중요합니다.''',
  '''수축 강도를 높여주세요. 특히 광배근의 완전한 수축은 상체 근력과 근비대에 필수적입니다.''',
  '''팔의 흔들림이 관찰됩니다. 광배근과 대원근에 집중하여 등 근육을 주도적으로 사용하세요. 이는 더 효과적인 상체 근력 발달을 돕습니다.''',
  '''과도한 반동을 사용하고 있습니다. 이는 근육의 집중적 활성화를 감소시킵니다. 저항밴드를 활용하여 보조받는 풀업으로 시작해 보세요.''',
  '''동작 속도가 과도하게 빠릅니다. 근육의 신장-수축 주기를 충분히 느끼며, 올바른 자세로 천천히 수행하는 것이 근육 활성화와 근력 향상에 더 효과적입니다.'''
];

List<String> PushUpFeedbackString = [
  '''신장 단계를 더 강조해 주세요. 대흉근과 상완삼두근의 충분한 신장은 근섬유 길이 증가와 근력 향상에 중요합니다.''',
  '''수축 강도를 높여주세요. 특히 대흉근과 상완삼두근의 완전한 수축은 상체 근력과 근비대에 필수적입니다.''',
  '''골반이 과도하게 상승된 상태입니다. 이는 견갑골, 주관절, 수근관절에 부상 위험을 증가시키며, 대흉근과 삼각근의 효과적인 활성화를 저해합니다.''',
  '''골반이 과도하게 하강된 상태입니다. 이는 복근의 적절한 긴장을 방해하고, 요추에 과도한 스트레스를 줄 수 있습니다. 코어를 단단히 유지하세요.''',
  '''슬관절(무릎)이 굴곡된 상태입니다. 이는 전신의 근육 연쇄를 방해하여 코어와 대퇴사두근의 적절한 활성화를 저해합니다. 전신을 일직선으로 유지하세요.''',
  '''동작 속도가 과도하게 빠릅니다. 근육의 신장-수축 주기를 충분히 느끼며, 올바른 자세로 천천히 수행하는 것이 근육 활성화와 근력 향상에 더 효과적입니다.'''
];