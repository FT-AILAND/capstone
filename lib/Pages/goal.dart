import 'package:ait_project/Pages/goal_setting.dart';
import 'package:ait_project/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart'; // Firestore
import 'package:ait_project/Pages/calendar.dart';
import 'package:table_calendar/table_calendar.dart';

class goalPage extends StatefulWidget {
  const goalPage({super.key});

  @override
  State<goalPage> createState() => _goalPageState();
}

class _goalPageState extends State<goalPage> {
  Widget _buildMarker(Color color) {
    String workoutName =
        workoutColors.entries.firstWhere((entry) => entry.value == color).key;
    return Tooltip(
      message: workoutNames[workoutName] ?? workoutName,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 1.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
        width: 7.0,
        height: 7.0,
      ),
    );
  }

  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  Map<DateTime, List<Color>> _events = {};
  Map<DateTime, List<Map<String, dynamic>>> _eventDetails = {};
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _selectedDayEvents = [];

  final Map<String, Color> workoutColors = {
    'push_up': Colors.blue,
    'pull_up': Colors.yellow,
    'squat': Colors.green,
  };

  final Map<String, String> workoutNames = {
    'push_up': '푸시업',
    'pull_up': '풀업',
    'squat': '스쿼트',
  };
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
  // bool _isLoading = true; // Set to true initially to show loading spinner
  // Field names for Firestore
  final List<String> _exerciseFields = ['pull_up', 'push_up', 'squat'];

  @override
  void initState() {
    super.initState();
    _loadUserRepetitionData(); // Load existing data from Firestore
    _loadUserWorkData();
    _calendarFormat = CalendarFormat.month;
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
    _loadEvents();
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

  void _loadEvents() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('exercise_DB')
            .where('uid', isEqualTo: user.uid)
            .get();

        Map<DateTime, List<Color>> newEvents = {};
        Map<DateTime, List<Map<String, dynamic>>> newEventDetails = {};

        for (var doc in querySnapshot.docs) {
          final data = doc.data();
          DateTime? date;
          if (data['timestamp'] is Timestamp) {
            date = (data['timestamp'] as Timestamp).toDate();
          } else if (data['timestamp'] is String) {
            date = DateTime.tryParse(data['timestamp'] as String);
          }

          if (date == null) continue;

          final workoutName = data['workout_name'] as String?;
          final count = data['count'] as int?;

          if (count != null && count > 0) {
            final key = DateTime(date.year, date.month, date.day);
            if (!newEvents.containsKey(key)) {
              newEvents[key] = [];
              newEventDetails[key] = [];
            }

            Color? eventColor = workoutColors[workoutName];
            if (eventColor != null && !newEvents[key]!.contains(eventColor)) {
              newEvents[key]!.add(eventColor);
            }

            newEventDetails[key]!.add({
              'workout_name': workoutName,
              'count': count,
              'timestamp': date,
            });
          }
        }

        setState(() {
          _events = newEvents;
          _eventDetails = newEventDetails;
          _isLoading = false;
          if (_selectedDay != null) {
            _updateSelectedDayEvents(_selectedDay!);
          }
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to load events. Please try again later.';
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _errorMessage = 'User not logged in.';
        _isLoading = false;
      });
    }
  }

  List<Color> _getEventsForDay(DateTime day) {
    final eventDate = DateTime(day.year, day.month, day.day);
    return _events[eventDate] ?? [];
  }

  void _updateSelectedDayEvents(DateTime selectedDay) {
    final eventDate =
        DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    _selectedDayEvents = _eventDetails[eventDate] ?? [];
    _selectedDayEvents.sort((a, b) =>
        (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp.toDate());
    } else if (timestamp is DateTime) {
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp);
    } else if (timestamp is String) {
      return timestamp;
    } else {
      return 'Unknown';
    }
  }

  void _updateDailyGoalProgress() {
    // 각 운동의 현재 및 총 목표 설정
    List<int> currentStepsList = [0, 0, 0]; // 선택된 날짜의 진행 상황 초기화
    List<int> totalStepsList = _repetitions; // 각 운동의 총 목표

    for (var event in _selectedDayEvents) {
      String workoutName = event['workout_name'];
      int count = event['count'];
      int index = workoutNames.keys.toList().indexOf(workoutName);

      if (index != -1) {
        currentStepsList[index] += count;
      }
    }

    setState(() {
      _workcount = currentStepsList;
      _repetitions = totalStepsList;
    });
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
                      SizedBox(
                        height: 500,
                        child: Column(
                          children: [
                            TableCalendar<Color>(
                              firstDay: DateTime.utc(2020, 1, 1),
                              lastDay: DateTime.utc(2030, 12, 31),
                              focusedDay: _focusedDay,
                              calendarFormat: _calendarFormat,
                              selectedDayPredicate: (day) =>
                                  isSameDay(_selectedDay, day),
                              onDaySelected: (selectedDay, focusedDay) {
                                setState(() {
                                  _selectedDay = selectedDay;
                                  _focusedDay = focusedDay;
                                  _updateSelectedDayEvents(selectedDay);

                                  // 선택한 날짜에 따른 목표 달성률 계산
                                  _updateDailyGoalProgress();
                                });
                              },
                              onFormatChanged: (format) {
                                setState(() {
                                  _calendarFormat = format;
                                });
                              },
                              onPageChanged: (focusedDay) {
                                _focusedDay = focusedDay;
                              },
                              eventLoader: _getEventsForDay,
                              calendarBuilders: CalendarBuilders(
                                markerBuilder: (context, date, events) {
                                  if (events.isNotEmpty) {
                                    return Positioned(
                                      bottom: 1,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: events
                                            .map((color) => _buildMarker(color))
                                            .toList(),
                                      ),
                                    );
                                  }
                                  return null;
                                },
                              ),
                              calendarStyle: CalendarStyle(
                                weekendTextStyle:
                                    TextStyle(color: Colors.red[200]),
                                holidayTextStyle:
                                    TextStyle(color: Colors.red[200]),
                                selectedTextStyle:
                                    const TextStyle(color: Colors.white),
                                todayTextStyle:
                                    const TextStyle(color: Colors.white),
                                defaultTextStyle:
                                    const TextStyle(color: Colors.white),
                                outsideTextStyle:
                                    const TextStyle(color: Colors.grey),
                              ),
                              daysOfWeekStyle: DaysOfWeekStyle(
                                weekdayStyle:
                                    const TextStyle(color: Colors.white),
                                weekendStyle: TextStyle(color: Colors.red[200]),
                              ),
                              headerStyle: const HeaderStyle(
                                formatButtonVisible: false,
                                titleCentered: true,
                                leftChevronIcon: Icon(Icons.chevron_left,
                                    color: Colors.white),
                                rightChevronIcon: Icon(Icons.chevron_right,
                                    color: Colors.white),
                                titleTextStyle: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Display workout markers
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: workoutColors.entries.map((entry) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: entry.value,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(workoutNames[entry.key] ?? entry.key,
                                          style: const TextStyle(
                                              color: Colors.white)),
                                      const SizedBox(width: 10),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 20),
                            const Padding(
                              padding: EdgeInsets.only(left: 20, right: 20),
                              child: Row(
                                children: [
                                  Text(
                                    '기록',
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
                            const SizedBox(height: 10),
                            // Record list
                            Expanded(
                              child: _selectedDayEvents.isEmpty
                                  ? const Center(
                                      child: Text(
                                        '해당 날짜 기록이 없습니다',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: _selectedDayEvents.length,
                                      itemBuilder: (context, index) {
                                        final event = _selectedDayEvents[index];
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0, horizontal: 25.0),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        CircleAvatar(
                                                          backgroundColor:
                                                              workoutColors[event[
                                                                  'workout_name']],
                                                          radius: 8,
                                                        ),
                                                        const SizedBox(
                                                            width: 10),
                                                        Expanded(
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Flexible(
                                                                child: Text(
                                                                  '${workoutNames[event['workout_name']] ?? event['workout_name']}',
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          16),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ),
                                                              Text(
                                                                '${event['count']} 회',
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        16),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      _formatTimestamp(
                                                          event['timestamp']),
                                                      style: const TextStyle(
                                                          color: Colors.white70,
                                                          fontSize: 14),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding:
                              const EdgeInsets.only(left: 20.0, right: 20.0),
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
                          height: 200,
                          child: ListView.builder(
                            itemCount: 3,
                            itemBuilder: (BuildContext ctx, int idx) {
                              List<String> exercises = ['푸쉬업', '풀업', '스쿼트'];
                              List<int> totalStepsList = [
                                _repetitions[0],
                                _repetitions[1],
                                _repetitions[2]
                              ];
                              List<int> currentStepsList = [
                                _workcount[0],
                                _workcount[1],
                                _workcount[2]
                              ];
                              List<LinearGradient> selectedGradients = [
                                const LinearGradient(colors: [
                                  Colors.lightBlueAccent,
                                  Colors.blue
                                ]),
                                const LinearGradient(colors: [
                                  Colors.yellowAccent,
                                  Colors.yellow
                                ]),
                                const LinearGradient(
                                    colors: [Colors.greenAccent, Colors.green]),
                              ];
                              List<Color> unselectedColors = [
                                Colors.cyan,
                                Colors.grey,
                                Colors.purpleAccent
                              ];

                              // Check if there's a goal set for the exercise
                              bool hasGoal = totalStepsList[idx] > 0;
                              int currentStep = currentStepsList[idx];
                              double percentage = (currentStep >
                                      totalStepsList[idx])
                                  ? 100
                                  : (currentStep / totalStepsList[idx]) * 100;

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical:
                                        10.0), // Consistent vertical padding
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          exercises[idx],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          hasGoal
                                              ? '${currentStepsList[idx]} / ${totalStepsList[idx]}'
                                              : '0 / 0',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                        height: 10.0), // Consistent spacing
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: StepProgressIndicator(
                                            totalSteps: hasGoal
                                                ? totalStepsList[idx]
                                                : 1, // Set to 1 for an empty bar
                                            currentStep: hasGoal
                                                ? (currentStepsList[idx] >
                                                        totalStepsList[idx]
                                                    ? totalStepsList[idx]
                                                    : currentStepsList[idx])
                                                : 0,
                                            size: 20,
                                            padding: 0,
                                            selectedColor: hasGoal
                                                ? Colors.yellow
                                                : unselectedColors[idx],
                                            unselectedColor: aitGrey,
                                            selectedGradientColor: hasGoal
                                                ? selectedGradients[idx]
                                                : null,
                                            unselectedGradientColor:
                                                LinearGradient(
                                              colors: [
                                                Color(0xFF595B77)
                                                    .withOpacity(0.5),
                                                Color(0xFF595B77),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '${hasGoal ? percentage.toStringAsFixed(0) : 0}%', // Display 0% progress if no goal
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ));
  }
}
