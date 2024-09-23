import 'package:ait_project/main.dart';
import 'package:flutter/material.dart';

// 페이지
import '/Pages/goal.dart';
import '/Pages/more.dart';
import '/Pages/record.dart';
import '/Pages/work.dart';

double iconSize = 35;

class BulidBottomAppBar extends StatefulWidget {
  const BulidBottomAppBar({required this.index, Key? key}) : super(key: key);
  final index;

  @override
  State<BulidBottomAppBar> createState() => _BulidBottomAppBarState();
}

class _BulidBottomAppBarState extends State<BulidBottomAppBar>
    with TickerProviderStateMixin {
  late TabController _controller = TabController(length: 4, vsync: this);

  var index = 0;
  changeIndex(index) {
    setState(() {
      _controller.index = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _controller.index = widget.index;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFF3D3F5A), useMaterial3: true),
      home: Scaffold(
        body: TabBarView(
          children: [
            workPage(),
            recordPage(),
            goalPage(),
            MorePage()
          ],
          controller: _controller,
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: aitNavy, 
              // border: Border(
              //   top: BorderSide(
              //       color: aitGrey.withOpacity(0.2),
              //       width: 3.0,
              //   ),
              // ),
            ),
            child: DefaultTabController(
              length: 4,
              child: TabBar(
                dividerColor: Colors.transparent,
                controller: _controller,
                indicator: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: aitGreen,
                      width: 4.0,
                    ),
                  ),
                ),
                indicatorSize: TabBarIndicatorSize.label,
                unselectedLabelColor: Colors.grey,
                labelColor: Colors.white,
                unselectedLabelStyle: const TextStyle(
                    color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
                labelStyle: const TextStyle(
                    color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold),
              
                tabs: [
                  Tab(
                      icon: Icon(
                        Icons.fitness_center,
                        size: iconSize,
                      ),
                      text: "운동"),
                  Tab(
                      icon: Icon(
                        Icons.equalizer,
                        size: iconSize,
                      ),
                      text: "기록"),
                  Tab(
                      icon: Icon(
                        Icons.edit_document,
                        size: iconSize,
                      ),
                      text: "목표"),
                  Tab(
                      icon: Icon(
                        Icons.more_horiz,
                        size: iconSize,
                      ),
                      text: "더보기"),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}