import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class goalPage extends StatefulWidget {
  const goalPage({super.key});

  @override
  State<goalPage> createState() => _goalPageState();
}

class _goalPageState extends State<goalPage> {
  // List to store repetitions for each exercise
  List<int> _repetitions = [0, 0, 0]; // Initial repetitions for each exercise
  bool _isRepetitionSelected = false;

  // Function to show repetition picker for a specific exercise
  void _showRepetitionPicker(int idx) {
    int tempRepetition = _repetitions[idx]; // Temporary value for repetition
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => Container(
        height: 300,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
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
                      Navigator.of(context).pop(); // Close the picker
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
                        _repetitions[idx] =
                            tempRepetition; // Set the selected repetition for this exercise
                        _isRepetitionSelected = true;
                      });
                      Navigator.of(context).pop(); // Close the picker
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
                    initialItem:
                        _repetitions[idx] - 1, // Initialize to current value
                  ),
                  onSelectedItemChanged: (int selectedItem) {
                    tempRepetition = selectedItem + 1; // Update temp value
                  },
                  children: List<Widget>.generate(100, (int index) {
                    return Center(
                      child: Text(
                        '${index + 1}',
                      ),
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFF3D3F5A),
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF3D3F5A),
          title: const Center(
            child: Text(
              "목표",
              style: TextStyle(
                fontSize: 25,
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            SizedBox(
              height: 30,
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Text(
                          '일일 목표 개수 ',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.normal,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF595B77).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x595B77),
                      spreadRadius: 2,
                      blurRadius: 7.0,
                      offset: Offset(2, 5), // changes position of shadow
                    ),
                  ],
                ),
                child: SizedBox(
                  width: 400,
                  height: 110,
                  child: ListView.builder(
                    itemCount: 3,
                    itemBuilder: (BuildContext ctx, int idx) {
                      List<String> exercises = ['Push up', 'Pull up', 'Squat'];
                      return InkWell(
                        onTap: () {
                          // Show the picker when the item is tapped
                          _showRepetitionPicker(idx);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  child: Text('${exercises[idx]}',
                                      style: TextStyle(color: Colors.white))),
                              Row(
                                children: [
                                  Text(
                                    '${_repetitions[idx]}', // Display the selected repetition
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                      width:
                                          10), // Space between number and icon
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
            )
          ],
        ),
      ),
    );
  }
}