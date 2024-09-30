
class WorkoutResult {
  final String? uid;
  final String? user;
  final String? workoutName; // only the strings push_up, pull_up, or squat is available
  final int? count;
  final List<int>? feedbackCounts;
  final DateTime? timestamp; // 타임스탬프 필드 추가
  /*
  feedbackCounts: (index)
    push_up:

  */ 

  WorkoutResult({
      this.uid,
      this.user,
      this.workoutName,
      this.count,
      this.feedbackCounts,
      this.timestamp,
      });

  factory WorkoutResult.fromJson(Map<String, dynamic> json) {
    // // 피드백 카운트 변환 처리
    // List<int>? feedbackCounts;
    // if (json['feedback_counts'] != null) {
    //   feedbackCounts = List<int>.from(json['feedback_counts'].map((item) => item as int));
    // }

    return WorkoutResult(
        uid: json['uid'],
        user: json['user'],
        workoutName: json['workout_name'] as String?,
        count: json['count'],
        feedbackCounts: List<int>.from(json['feedback_counts']),
        timestamp: DateTime.parse(json['timestamp']) // 타임스탬프 파싱 추가
    ); 
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'user': user,
        'workout_name': workoutName,
        'count': count,
        'feedback_counts': feedbackCounts,
        'timestamp': timestamp?.toIso8601String() // 타임스탬프 추가
  };
}