import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../main.dart';
import '../models/workout_result.dart';
import 'package:ait_project/Pages/workout_result_page.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({Key? key}) : super(key: key);

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isDescending = true; // 정렬 순서를 저장하는 상태 변수

  String _getWorkoutImage(String workoutName) {
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

  void _toggleSortOrder() {
    setState(() {
      _isDescending = !_isDescending;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '기록',
          style: TextStyle(
            fontSize: 25,
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: true,
        backgroundColor: aitNavy,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 정렬 옵션 위젯
          SizedBox(
            height: 30, // 높이를 약간 늘렸습니다
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: _toggleSortOrder,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        _isDescending ? '최신순 ' : '오래된순 ',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Icon(
                        _isDescending
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 기록 내용
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('exercise_DB')
                  .where('uid', isEqualTo: _auth.currentUser?.uid)
                  .orderBy('timestamp', descending: _isDescending)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text(
                    '기록이 없습니다.',
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    var data = doc.data() as Map<String, dynamic>;

                    String workoutName =
                        data['workout_name'] as String? ?? '알 수 없는 운동';
                    DateTime? timestamp = _safeGetDateTime(data, 'timestamp');
                    String formattedTimestamp = timestamp != null
                        ? DateFormat('yyyy-MM-dd HH:mm').format(timestamp)
                        : '날짜 정보 없음';

                    String displayName = _getDisplayName(workoutName);

                    return GestureDetector(
                        onTap: () {
                          WorkoutResult workoutResult =
                              WorkoutResult.fromJson(data);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WorkoutResultPage(
                                  workoutResult: workoutResult),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 20, left: 15, right: 15),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF595B77).withOpacity(0.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 25, right: 10, top: 15, bottom: 15),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 10),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                child: Image.asset(
                                                  _getWorkoutImage(workoutName),
                                                  width: 30,
                                                  height: 30,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              displayName,
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w900,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 3, bottom: 5),
                                          child: Text(
                                            formattedTimestamp,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '${data['count']} 회',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0XFF9FA2CE),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ));
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getDisplayName(String workoutName) {
    switch (workoutName) {
      case 'pull_up':
        return '풀업';
      case 'push_up':
        return '푸시업';
      case 'squat':
        return '스쿼트';
      default:
        return workoutName;
    }
  }

  DateTime? _safeGetDateTime(Map<String, dynamic> data, String key) {
    var value = data[key];
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
