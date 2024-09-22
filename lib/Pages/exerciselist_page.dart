import 'package:flutter/material.dart';

class ExerciseListPage extends StatefulWidget {
  const ExerciseListPage({super.key});

  @override
  State<ExerciseListPage> createState() => ExerciseListPageState();
}

class ExerciseListPageState extends State<ExerciseListPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFF3D3F5A),
      ),
      home: DefaultTabController(
        length: 5,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xFF3D3F5A),
            title: Center(
                child: const Text(
              "운동",
              style: TextStyle(color: Colors.white),
            )),
            bottom: const TabBar(
              tabs: [
                Tab(
                  child: Text(
                    "AI",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                ),
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
                    "팔",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    "복부",
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
              ],
            ),
          ),
          body: TabBarView(
            children: [
              Expanded(
                  child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          border: Border.all(
                              color: Colors.grey.shade400, width: 1.5),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x595B77),
                              spreadRadius: 2,
                              blurRadius: 7.0,
                              offset:
                                  Offset(2, 5), // changes position of shadow
                            ),
                          ],
                        ),
                        child: SizedBox(
                          width: 400,
                          height: 110,
                          child: Row(
                            children: [
                              Container(
                                child: Image.asset(
                                  'assets/images/pushup.png',
                                ),
                              ),
                              //여긴 어차피 바꿀 것
                              Column(
                                children: [
                                  Text(
                                    "푸시업",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white),
                                  ),
                                  Text(
                                    "가슴 근력 강화",
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black),
                                  ),
                                  Text("#맨몸  #어깨  #가슴",
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black))
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          border: Border.all(
                              color: Colors.grey.shade400, width: 1.5),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x595B77),
                              spreadRadius: 2,
                              blurRadius: 7.0,
                              offset:
                                  Offset(2, 5), // changes position of shadow
                            ),
                          ],
                        ),
                        child: SizedBox(
                          width: 400,
                          height: 110,
                          child: Row(
                            children: [
                              Container(
                                child: Image.asset(
                                  'assets/images/squat.png',
                                ),
                              ),
                              Column(
                                children: [
                                  Text(
                                    "스쿼트",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white),
                                  ),
                                  Text(
                                    "힙업 및 하체 근력 강화",
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black),
                                  ),
                                  Text("#맨몸  #하체",
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black))
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          border: Border.all(
                              color: Colors.grey.shade400, width: 1.5),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x595B77),
                              spreadRadius: 2,
                              blurRadius: 7.0,
                              offset:
                                  Offset(2, 5), // changes position of shadow
                            ),
                          ],
                        ),
                        child: SizedBox(
                          width: 400,
                          height: 110,
                          child: Row(
                            children: [
                              Container(
                                child: Image.asset(
                                  'assets/images/weight.png',
                                ),
                              ),
                              Column(
                                children: [
                                  Text(
                                    "숄더프레스",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white),
                                  ),
                                  Text(
                                    "어깨 근력 강화",
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black),
                                  ),
                                  Text("#덤벨  #어깨  #팔",
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black))
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              )),
              Expanded(
                  child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          border: Border.all(
                              color: Colors.grey.shade400, width: 1.5),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x595B77),
                              spreadRadius: 2,
                              blurRadius: 7.0,
                              offset:
                                  Offset(2, 5), // changes position of shadow
                            ),
                          ],
                        ),
                        child: SizedBox(
                          width: 400,
                          height: 110,
                          child: Row(
                            children: [
                              Container(
                                child: Image.asset(
                                  'assets/images/pushup.png',
                                ),
                              ),
                              Column(
                                children: [
                                  Text(
                                    "푸시업",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white),
                                  ),
                                  Text(
                                    "가슴 근력 강화",
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black),
                                  ),
                                  Text("#맨몸  #어깨  #가슴",
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black))
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          border: Border.all(
                              color: Colors.grey.shade400, width: 1.5),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x595B77),
                              spreadRadius: 2,
                              blurRadius: 7.0,
                              offset:
                                  Offset(2, 5), // changes position of shadow
                            ),
                          ],
                        ),
                        child: SizedBox(
                          width: 400,
                          height: 110,
                          child: Row(
                            children: [
                              Container(
                                child: Image.asset(
                                  'assets/images/squat.png',
                                ),
                              ),
                              Column(
                                children: [
                                  Text(
                                    "스쿼트",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white),
                                  ),
                                  Text(
                                    "힙업 및 하체 근력 강화",
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black),
                                  ),
                                  Text("#맨몸  #하체",
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black))
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          border: Border.all(
                              color: Colors.grey.shade400, width: 1.5),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x595B77),
                              spreadRadius: 2,
                              blurRadius: 7.0,
                              offset:
                                  Offset(2, 5), // changes position of shadow
                            ),
                          ],
                        ),
                        child: SizedBox(
                          width: 400,
                          height: 110,
                          child: Row(
                            children: [
                              Container(
                                child: Image.asset(
                                  'assets/images/weight.png',
                                ),
                              ),
                              Column(
                                children: [
                                  Text(
                                    "숄더프레스",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white),
                                  ),
                                  Text(
                                    "어깨 근력 강화",
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black),
                                  ),
                                  Text("#덤벨  #어깨  #팔",
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black))
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              )),
              Expanded(
                  child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          border: Border.all(
                              color: Colors.grey.shade400, width: 1.5),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x595B77),
                              spreadRadius: 2,
                              blurRadius: 7.0,
                              offset:
                                  Offset(2, 5), // changes position of shadow
                            ),
                          ],
                        ),
                        child: SizedBox(
                          width: 400,
                          height: 110,
                          child: Row(
                            children: [
                              Container(
                                child: Image.asset(
                                  'assets/images/weight.png',
                                ),
                              ),
                              Column(
                                children: [
                                  Text(
                                    "숄더프레스",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white),
                                  ),
                                  Text(
                                    "어깨 근력 강화",
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black),
                                  ),
                                  Text("#덤벨  #어깨  #팔",
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black))
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              )),
              Expanded(
                  child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          border: Border.all(
                              color: Colors.grey.shade400, width: 1.5),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x595B77),
                              spreadRadius: 2,
                              blurRadius: 7.0,
                              offset:
                                  Offset(2, 5), // changes position of shadow
                            ),
                          ],
                        ),
                        child: SizedBox(
                          width: 400,
                          height: 110,
                          child: Row(
                            children: [
                              Container(
                                child: Image.asset(
                                  'assets/images/pushup.png',
                                ),
                              ),
                              Column(
                                children: [
                                  Text(
                                    "푸시업",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white),
                                  ),
                                  Text(
                                    "가슴 근력 강화",
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black),
                                  ),
                                  Text("#맨몸  #어깨  #가슴",
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black))
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              )),
              Expanded(
                  child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          border: Border.all(
                              color: Colors.grey.shade400, width: 1.5),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x595B77),
                              spreadRadius: 2,
                              blurRadius: 7.0,
                              offset:
                                  Offset(2, 5), // changes position of shadow
                            ),
                          ],
                        ),
                        child: SizedBox(
                          width: 400,
                          height: 110,
                          child: Row(
                            children: [
                              Container(
                                child: Image.asset(
                                  'assets/images/squat.png',
                                ),
                              ),
                              Column(
                                children: [
                                  Text(
                                    "스쿼트",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white),
                                  ),
                                  Text(
                                    "힙업 및 하체 근력 강화",
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black),
                                  ),
                                  Text("#맨몸  #하체",
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black))
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
