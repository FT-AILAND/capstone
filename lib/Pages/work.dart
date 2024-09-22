import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class WorkData {
  final int workId;
  final String name;
  final String effect;
  final String tag1;
  final String? tag2;
  final String? tag3;
  final String? imgsrc;

  WorkData({
    required this.workId,
    required this.name,
    required this.effect,
    required this.tag1,
    this.tag2,
    this.tag3,
    this.imgsrc,
  });

  factory WorkData.fromJson(Map<String, dynamic> json) {
    return WorkData(
      workId: json['workId'],
      name: json['name'],
      effect: json['effect'],
      tag1: json['tag1'],
      tag2: json['tag2'],
      tag3: json['tag3'],
      imgsrc: json['imgsrc'],
    );
  }
}

// Future<List<WorkData>> loadworkdata() async {
//   var dio = Dio();
//   final response = await dio.get('http://192.168.56.1:3000/work/get');
//   print(response.statusCode);
//   if (response.statusCode == 200) {
//     List<dynamic> data = response.data;

//     print("ㅡㅡ");
//     List<WorkData> list =
//         data.map((dynamic e) => WorkData.fromJson(e)).toList();
//     return list;
//   } else {
//     throw Exception('Failed to Load');
//   }
// }

Future<List<WorkData>> loadworkdata() async {
  try {
    var dio = Dio();
    final response = await dio.get('http://192.168.56.1:3000/work/get');
    print(response.statusCode);

    if (response.statusCode == 200) {
      var responseData = response.data;
      print('Data: $responseData');

      if (responseData is Map<String, dynamic> &&
          responseData.containsKey('data')) {
        var dataList = responseData['data'];

        if (dataList is List) {
          List<WorkData> list =
              dataList.map((dynamic e) => WorkData.fromJson(e)).toList();
          return list;
        } else {
          throw Exception('Unexpected data format for key "data"');
        }
      } else {
        throw Exception('Expected key "data" not found in response');
      }
    } else {
      throw Exception('Failed to Load: ${response.statusCode}');
    }
  } catch (e) {
    print('Error in loadworkdata: $e');
    throw Exception('Failed to Load');
  }
  // try {
  //   var dio = Dio();
  //   final response = await dio.get('http://192.168.56.1:3000/work/get');
  //   print(response.statusCode);
  //   if (response.statusCode == 200) {
  //     List<dynamic> data = response.data;
  //     print('Data: $data');
  //     List<WorkData> list =
  //         data.map((dynamic e) => WorkData.fromJson(e)).toList();
  //     return list;
  //   } else {
  //     throw Exception('Failed to Load: ${response.statusCode}');
  //   }
  // } catch (e) {
  //   print('Error in loadworkdata: $e');
  //   throw Exception('Failed to Load');
  // }
}

Future<List<WorkData>> getEntries() async {
  List<WorkData> entries = await loadworkdata();
  return entries;
}

class workPage extends StatefulWidget {
  const workPage({super.key});

  @override
  State<workPage> createState() => _workPageState();
}

class _workPageState extends State<workPage> {
  late Future<List<WorkData>> worklist;
  @override
  initState() {
    super.initState();
    // MyApiService();
    print("응애");
  }

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
                // Use Builder widget to get a new BuildContext
                //AI 부분
                Builder(
                  builder: (BuildContext context) {
                    return SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          FutureBuilder<List<WorkData>>(
                            future: getEntries(),
                            builder: (context,
                                AsyncSnapshot<List<WorkData>> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                List<WorkData> entries = snapshot.data!;
                                print(entries.length);
                                print("ㅡㅡㅡㅡㅡㅡㅡㅡ");
                                return Column(
                                  children: [
                                    SizedBox(
                                      // Use Container to give it constraints
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.height -
                                                kToolbarHeight,
                                        child: ListView.builder(
                                          padding: const EdgeInsets.all(8),
                                          itemCount: entries.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[400],
                                                  border:
                                                      Border.all(width: 1.5),
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Color(0x595B77),
                                                      spreadRadius: 2,
                                                      blurRadius: 7.0,
                                                      offset: Offset(2,
                                                          5), // changes position of shadow
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
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 30.0),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              entries[index]
                                                                  .name,
                                                              style: TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      top: 10.0,
                                                                      bottom:
                                                                          20.0),
                                                              child: Text(
                                                                entries[index]
                                                                    .effect,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        13,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    color: Colors
                                                                        .black),
                                                              ),
                                                            ),
                                                            Text(
                                                                entries[index]
                                                                    .tag1,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        13,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    color: Colors
                                                                        .black))
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
                //전체
                Builder(
                  builder: (BuildContext context) {
                    return SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          FutureBuilder<List<WorkData>>(
                            future: getEntries(),
                            builder: (context,
                                AsyncSnapshot<List<WorkData>> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                List<WorkData> entries = snapshot.data!;
                                print(entries.length);
                                print("ㅡㅡㅡㅡㅡㅡㅡㅡ");
                                return Column(
                                  children: [
                                    SizedBox(
                                      // Use Container to give it constraints
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.height -
                                                kToolbarHeight,
                                        child: ListView.builder(
                                          padding: const EdgeInsets.all(8),
                                          itemCount: entries.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[400],
                                                  border:
                                                      Border.all(width: 1.5),
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Color(0x595B77),
                                                      spreadRadius: 2,
                                                      blurRadius: 7.0,
                                                      offset: Offset(2,
                                                          5), // changes position of shadow
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
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 30.0),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              entries[index]
                                                                  .name,
                                                              style: TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      top: 10.0,
                                                                      bottom:
                                                                          20.0),
                                                              child: Text(
                                                                entries[index]
                                                                    .effect,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        13,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    color: Colors
                                                                        .black),
                                                              ),
                                                            ),
                                                            Row(
                                                              children: [
                                                                Text(
                                                                    entries[index]
                                                                        .tag1,
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            13,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w700,
                                                                        color: Colors
                                                                            .black)),
                                                                if (entries[index]
                                                                        .tag2 !=
                                                                    null)
                                                                  Text(
                                                                    entries[index]
                                                                        .tag2!,
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          13,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      color: Colors
                                                                          .black,
                                                                    ),
                                                                  ),
                                                                if (entries[index]
                                                                        .tag3 !=
                                                                    null)
                                                                  Text(
                                                                    entries[index]
                                                                        .tag3!,
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          13,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      color: Colors
                                                                          .black,
                                                                    ),
                                                                  ),
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Container(),
                Container(),
                Container()
              ],
            )),
      ),
    );
  }
}
