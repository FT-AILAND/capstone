import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GoalSettingPage extends StatefulWidget {
  final List<int> currentRepetitions;

  const GoalSettingPage({super.key, required this.currentRepetitions});

  @override
  State<GoalSettingPage> createState() => _GoalSettingPageState();
}

class _GoalSettingPageState extends State<GoalSettingPage> {
  late List<int> _updatedRepetitions;

  @override
  void initState() {
    super.initState();
    _updatedRepetitions = List.from(widget.currentRepetitions);
  }

  void _showRepetitionPicker(int idx) {
    int tempRepetition = _updatedRepetitions[idx];
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => Container(
        height: 300,
        padding: const EdgeInsets.only(top: 6.0),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text(
                      '취소',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  CupertinoButton(
                    child: const Text(
                      '선택',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _updatedRepetitions[idx] = tempRepetition;
                      });

                      Navigator.of(context).pop();
                      _saveAndReturn();
                    },
                  ),
                ],
              ),
              Expanded(
                child: CupertinoPicker(
                  magnification: 1.22,
                  squeeze: 1.2,
                  useMagnifier: true,
                  itemExtent: 32,
                  scrollController: FixedExtentScrollController(
                    initialItem: _updatedRepetitions[idx] - 1,
                  ),
                  onSelectedItemChanged: (int selectedItem) {
                    tempRepetition = selectedItem + 1;
                  },
                  children: List<Widget>.generate(100, (int index) {
                    return Center(
                      child: Text('${index + 1}'),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveAndReturn() {
    Navigator.of(context).pop(_updatedRepetitions);
  }

  @override
  Widget build(BuildContext context) {
    List<String> exercises = ['푸쉬업', '턱걸이', '스쿼트'];

    return Scaffold(
      backgroundColor: const Color(0xFF3D3F5A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3D3F5A),
        title: const Text(
          "목표 설정",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.check, color: Colors.white),
        //     onPressed: _saveAndReturn,
        //   ),
        // ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            const SizedBox(
              height: 30,
              child: Padding(
                padding: EdgeInsets.only(right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.only(left: 10.0),
                        child: Text(
                          '운동 목표 설정',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5, right: 5, top: 15.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF595B77).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x595B77),
                      spreadRadius: 2,
                      blurRadius: 7.0,
                      offset: Offset(2, 5),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: 400,
                  height: 110,
                  child: ListView.builder(
                    itemCount: 3,
                    itemBuilder: (BuildContext ctx, int idx) {
                      return InkWell(
                        onTap: () {
                          _showRepetitionPicker(idx);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  exercises[idx],
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    '${_updatedRepetitions[idx]}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Icon(
                                    Icons.settings,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
