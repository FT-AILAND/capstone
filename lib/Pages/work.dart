import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ait_project/data/muscle_list.dart';
import 'package:ait_project/main.dart';

class workPage extends StatefulWidget {
  final Map<String, Map<String, dynamic>>? exerciseList;
  const workPage({super.key, this.exerciseList});

  @override
  State<workPage> createState() => _workPageState();
}

class _workPageState extends State<workPage> with TickerProviderStateMixin {
  // muscleList에 전체 운동 데이터 추가
  List<Map<String, dynamic>> allExercises = [];

  @override
  void initState() {
    super.initState();
    // 전체 리스트 만들기
    allExercises.addAll(chestExerciseList.entries.map((entry) => {
          'name': entry.key,
          'image': entry.value['image'],
          'nextPage': entry.value['nextPage'],
          'hashTag': entry.value['hashTag'],
        }));
    allExercises.addAll(legsExerciseList.entries.map((entry) => {
          'name': entry.key,
          'image': entry.value['image'],
          'nextPage': entry.value['nextPage'],
          'hashTag': entry.value['hashTag'],
        }));
    allExercises.addAll(pullUpExerciseList.entries.map((entry) => {
          'name': entry.key,
          'image': entry.value['image'],
          'nextPage': entry.value['nextPage'],
          'hashTag': entry.value['hashTag'],
        }));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: aitNavy,
      ),
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: aitNavy,
              title: const Center(
                  child: Text(
                "운동",
                style: TextStyle(
                  fontSize: 25,
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              )),
              bottom: TabBar(
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: aitGreen,
                      width: 4.0,
                    ),
                  ),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                unselectedLabelColor: Colors.grey,
                labelColor: Colors.white,
                unselectedLabelStyle: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
                labelStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(
                    child: Text(
                      "전체",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Tab(
                    child: Text(
                      "상체",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Tab(
                    child: Text(
                      "하체",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Tab(
                    child: Text(
                      "등",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _buildExerciseList(allExercises), // 전체 리스트
                _buildExerciseList(chestExerciseList.entries
                    .map((entry) => {
                          'name': entry.key,
                          'image': entry.value['image'],
                          'nextPage': entry.value['nextPage'],
                          'hashTag': entry.value['hashTag'],
                        })
                    .toList()), // Chest 리스트
                _buildExerciseList(legsExerciseList.entries
                    .map((entry) => {
                          'name': entry.key,
                          'image': entry.value['image'],
                          'nextPage': entry.value['nextPage'],
                          'hashTag': entry.value['hashTag'],
                        })
                    .toList()), // Legs 리스트
                _buildExerciseList(pullUpExerciseList.entries
                    .map((entry) => {
                          'name': entry.key,
                          'image': entry.value['image'],
                          'nextPage': entry.value['nextPage'],
                          'hashTag': entry.value['hashTag'],
                        })
                    .toList()), // Back 리스트
              ],
            )),
      ),
    );
  }

  // 운동 리스트를 보여주는 위젯
  Widget _buildExerciseList(List<Map<String, dynamic>> exerciseList) {
    return ListView.builder(
      itemCount: exerciseList.length,
      itemBuilder: (context, index) {
        final exercise = exerciseList[index];

        return GestureDetector(
          onTap: () {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => exercise['nextPage']),
            // );
            Get.to(exercise['nextPage']);
          },
          child: Padding(
            padding: const EdgeInsets.only(
                top: 20, left: 15, right: 15), // 컨테이너 외부 패딩
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF595B77).withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15), // 컨테이너 내부 패딩
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start, // 세로 정렬 방식
                  children: [
                    // 왼쪽 이미지
                    Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          exercise['image'],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15), // 이미지와 텍스트 사이 간격

                    // 중간 텍스트 부분
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise['nextPage']?.korName ?? ' ',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 3, bottom: 5),
                            child: Text(
                              exercise['nextPage']?.shortDes ?? ' ',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Text(
                            exercise['hashTag'] ?? '',
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0XFF9FA2CE),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 오른쪽 상단 AI 표시
                    if (exercise['nextPage']?.isReadyForAI == true)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 0),
                        child: Text(
                          'AI',
                          style: TextStyle(
                            color: aitGreen,
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
