import 'package:flutter/material.dart';

// 페이지
import '/Pages/goal.dart';
import '/Pages/more.dart';
import '/Pages/record.dart';
import '/Pages/routine.dart';
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
  late TabController _controller = TabController(length: 5, vsync: this);

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
            routinePage(),
            goalPage(),
            recordPage(),
            MorePage()
          ],
          controller: _controller,
        ),
        bottomNavigationBar: DefaultTabController(
          length: 5,
          child: TabBar(
            controller: _controller,
            indicatorWeight: 4,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorColor: Color(0XFF4EFE8A),
            unselectedLabelColor: Colors.grey,
            labelColor: Colors.white,
            unselectedLabelStyle: TextStyle(
                color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
            labelStyle: TextStyle(
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
                    Icons.recycling,
                    size: iconSize,
                  ),
                  text: "루틴"),
              Tab(
                  icon: Icon(
                    Icons.edit_document,
                    size: iconSize,
                  ),
                  text: "목표"),
              Tab(
                  icon: Icon(
                    Icons.equalizer,
                    size: iconSize,
                  ),
                  text: "기록"),
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
    );
  }
}
