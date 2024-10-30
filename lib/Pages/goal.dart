import 'package:ait_project/Pages/goal_setting.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart'; // Firestore
import 'package:ait_project/Pages/calendar.dart';

class goalPage extends StatefulWidget {
  const goalPage({super.key});

  @override
  State<goalPage> createState() => _goalPageState();
}

class _goalPageState extends State<goalPage> {
  // List to store repetitions for each exercise
  List<int> _repetitions = [
    0,
    0,
    0
  ]; // Initial repetitions for push_up, pull_up, squat`\

  List<int> _workcount = [0, 0, 0];
  bool _isRepetitionSelected = false;

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Loading indicator
  bool _isLoading = true; // Set to true initially to show loading spinner
  // Field names for Firestore
  final List<String> _exerciseFields = ['pull_up', 'push_up', 'squat'];

  @override
  void initState() {
    super.initState();
    _loadUserRepetitionData(); // Load existing data from Firestore
    _loadUserWorkData();
  }

  // Load current user's exercise repetitions from Firestore
  Future<void> _loadUserRepetitionData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot doc =
            await _firestore.collection('Goal').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            _repetitions[0] = doc['pull_up'] ?? 0;
            _repetitions[1] = doc['push_up'] ?? 0;
            _repetitions[2] = doc['squat'] ?? 0;
            _isLoading = false; // Data loaded, stop showing loading spinner
          });
        }
      }
    } catch (e) {
      print("Error loading data: $e");
      setState(() {
        _isLoading = false; // Stop showing spinner even if there's an error
      });
    }
  }

  Future<void> _loadUserWorkData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Query the exercise_DB collection for the user's document
        QuerySnapshot querySnapshot = await _firestore
            .collection('exercise_DB')
            .where('uid', isEqualTo: user.uid)
            .get();

        // Loop through the documents in the result to find the workout counts
        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          // Check workout_name and assign the count to the correct exercise
          if (data['workout_name'] == 'pull_up') {
            _workcount[0] = data['count'] ?? 0;
          } else if (data['workout_name'] == 'push_up') {
            _workcount[1] = data['count'] ?? 0;
          } else if (data['workout_name'] == 'squat') {
            _workcount[2] = data['count'] ?? 0;
          }
        }

        // Once data is loaded, update the UI
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading data: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

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
                            tempRepetition; // Set the selected repetition
                        _isRepetitionSelected = true;
                      });
                      // Save the repetition to Firebase Firestore
                      _saveRepetitionToFirestore();
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

  // Save the repetition count to Firestore (all exercises in one document)
  void _saveRepetitionToFirestore() async {
    User? user = _auth.currentUser; // Get current user

    if (user != null) {
      // Update the document in Firestore for the current user's exercise data
      await _firestore.collection('Goal').doc(user.uid).set({
        'uid': user.uid,
        'pull_up': _repetitions[0],
        'push_up': _repetitions[1],
        'squat': _repetitions[2],
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('운동 기록이 저장되었습니다.'),
          backgroundColor: Colors.green,
        ),
      );
    }
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
          title: const Text(
            "목표",
            style: TextStyle(
              fontSize: 25,
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.settings,
                color: Colors.white,
                size: 28,
              ),
              onPressed: () async {
                // Navigate to GoalSettingPage and pass the current repetitions
                final updatedRepetitions = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        GoalSettingPage(currentRepetitions: _repetitions),
                  ),
                );

                // If user has updated the repetitions, update the state and save to Firestore
                if (updatedRepetitions != null &&
                    updatedRepetitions is List<int>) {
                  setState(() {
                    _repetitions = updatedRepetitions;
                  });
                  _saveRepetitionToFirestore(); // Save updated repetitions to Firestore
                }
              },
            ),
          ],
        ),
        // Inside the `build` method
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  children: [
                    SizedBox(height: 500, child: ExerciseCalendarWidget()),
                    // const SizedBox(
                    //   height: 30,
                    //   child: Padding(
                    //     padding: EdgeInsets.only(right: 10),
                    //     child: Row(
                    //       mainAxisAlignment: MainAxisAlignment.start,
                    //       children: [
                    //         Align(
                    //           alignment: Alignment.center,
                    //           child: Padding(
                    //             padding: EdgeInsets.only(left: 10.0),
                    //             child: Text(
                    //               '일일 목표 개수',
                    //               style: TextStyle(
                    //                 color: Colors.white,
                    //                 fontWeight: FontWeight.normal,
                    //                 fontSize: 16,
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    // Padding(
                    //   padding: const EdgeInsets.all(10.0),
                    //   child: Container(
                    //     decoration: BoxDecoration(
                    //       color: Color(0xFF595B77).withOpacity(0.5),
                    //       borderRadius: BorderRadius.circular(15),
                    //       boxShadow: const [
                    //         BoxShadow(
                    //           color: Color(0x595B77),
                    //           spreadRadius: 2,
                    //           blurRadius: 7.0,
                    //           offset: Offset(2, 5),
                    //         ),
                    //       ],
                    //     ),
                    //     child: SizedBox(
                    //       width: 400,
                    //       height:
                    //           110, // Increased height to better fit the list items
                    //       child: ListView.builder(
                    //         itemCount: 3,
                    //         itemBuilder: (BuildContext ctx, int idx) {
                    //           // Korean exercise names
                    //           List<String> exercises = [
                    //             '푸쉬업', // Push_up -> 푸쉬업
                    //             '턱걸이', // Pull_up -> 턱걸이
                    //             '스쿼트' // Squat -> 스쿼트
                    //           ];
                    //           return InkWell(
                    //             onTap: () {
                    //               // Show the picker when the item is tapped
                    //               _showRepetitionPicker(idx);
                    //             },
                    //             child: Padding(
                    //               padding: const EdgeInsets.all(8.0),
                    //               child: Row(
                    //                 mainAxisAlignment:
                    //                     MainAxisAlignment.spaceBetween,
                    //                 children: [
                    //                   Expanded(
                    //                     child: Text(
                    //                       '${exercises[idx]}',
                    //                       style: TextStyle(color: Colors.white),
                    //                     ),
                    //                   ),
                    //                   Row(
                    //                     children: [
                    //                       Text(
                    //                         '${_repetitions[idx]}', // Display the selected repetition
                    //                         style: TextStyle(
                    //                           color: Colors.white,
                    //                           fontWeight: FontWeight.bold,
                    //                         ),
                    //                       ),
                    //                       const SizedBox(
                    //                           width:
                    //                               10), // Space between number and icon
                    //                       const Icon(
                    //                         Icons.settings,
                    //                         color: Colors.white,
                    //                         size: 20,
                    //                       ),
                    //                     ],
                    //                   ),
                    //                 ],
                    //               ),
                    //             ),
                    //           );
                    //         },
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                        child: Row(
                          children: [
                            Text(
                              '일일 목표 달성률',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(left: 20),
                                child: Divider(
                                  color: Colors.white60,
                                  thickness: 1,
                                  height: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SizedBox(
                        width: 400,
                        height:
                            200, // Increased height to better fit the list items
                        child: ListView.builder(
                          itemCount: 3,
                          itemBuilder: (BuildContext ctx, int idx) {
                            // Korean exercise names
                            List<String> exercises = [
                              '푸쉬업', // Push_up
                              '풀업', // Pull_up
                              '스쿼트', // Squat
                            ];

                            List<int> totalStepsList = [
                              _repetitions[0], // Each exercise goal count
                              _repetitions[1],
                              _repetitions[2],
                            ];

                            List<int> currentStepsList = [
                              _workcount[0], // Current count for each exercise
                              _workcount[1],
                              _workcount[2],
                            ];

                            int currentStep =
                                currentStepsList[idx] > totalStepsList[idx]
                                    ? totalStepsList[idx]
                                    : currentStepsList[idx];

                            // Percentage calculation
                            double percentage =
                                (currentStep / totalStepsList[idx]) * 100;

                            // Define different gradient colors for each exercise
                            List<LinearGradient> selectedGradients = [
                              const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  // Colors.yellowAccent, // Gradient for Push_up
                                  // Colors.deepOrange,
                                  Colors
                                      .lightBlueAccent, // Gradient for Pull_up
                                  Colors.blue,
                                ],
                              ),
                              const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.yellowAccent, // Gradient for Push_up
                                  Colors.yellow
                                ],
                              ),
                              const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.greenAccent, // Gradient for Squat
                                  Colors.green,
                                ],
                              ),
                            ];

                            List<Color> unselectedColors = [
                              Colors.cyan, // Unselected color for Push_up
                              Colors.grey, // Unselected color for Pull_up
                              Colors.purpleAccent, // Unselected color for Squat
                            ];

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      exercises[
                                          idx], // Display exercise name in Korean
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '$currentStep / ${totalStepsList[idx]}', // Display current progress / goal
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10.0),
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: StepProgressIndicator(
                                        totalSteps: totalStepsList[
                                            idx], // Total goal count
                                        currentStep:
                                            currentStep, // Current progress
                                        size: 20,
                                        padding: 0,
                                        selectedColor: Colors.yellow,
                                        unselectedColor: unselectedColors[
                                            idx], // Apply unselected color based on index
                                        selectedGradientColor: selectedGradients[
                                            idx], // Apply gradient based on index
                                        unselectedGradientColor: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color(0xFF595B77).withOpacity(0.5),
                                            Color(0xFF595B77),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Center the percentage text
                                    Text(
                                      '${percentage.toStringAsFixed(0)}%', // Display percentage with no decimals
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                    height:
                                        10), // Padding between progress bars
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
