// import 'package:flutter/material.dart';
// import 'package:table_calendar/table_calendar.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';

// import 'package:ait_project/main.dart';

// class ExerciseCalendarPage extends StatefulWidget {
//   @override
//   _ExerciseCalendarPageState createState() => _ExerciseCalendarPageState();
// }

// class _ExerciseCalendarPageState extends State<ExerciseCalendarPage> {
//   late CalendarFormat _calendarFormat;
//   late DateTime _focusedDay;
//   DateTime? _selectedDay;
//   Map<DateTime, List<Color>> _events = {};
//   Map<DateTime, List<Map<String, dynamic>>> _eventDetails = {};
//   bool _isLoading = true;
//   String? _errorMessage;
//   List<Map<String, dynamic>> _selectedDayEvents = [];

//   final Map<String, Color> workoutColors = {
//     'push_up': Colors.blue,
//     'pull_up': Colors.yellow,
//     'squat': Colors.green,
//   };

//   final Map<String, String> workoutNames = {
//     'push_up': '푸시업',
//     'pull_up': '풀업',
//     'squat': '스쿼트',
//   };

//   @override
//   void initState() {
//     super.initState();
//     _calendarFormat = CalendarFormat.month;
//     _focusedDay = DateTime.now();
//     _selectedDay = _focusedDay;
//     _loadEvents();
//   }

//   void _loadEvents() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       try {
//         final querySnapshot = await FirebaseFirestore.instance
//             .collection('exercise_DB')
//             .where('uid', isEqualTo: user.uid)
//             .get();

//         Map<DateTime, List<Color>> newEvents = {};
//         Map<DateTime, List<Map<String, dynamic>>> newEventDetails = {};

//         print('Total documents: ${querySnapshot.docs.length}');

//         for (var doc in querySnapshot.docs) {
//           final data = doc.data();
//           print('Document data: $data');

//           DateTime? date;

//           if (data['timestamp'] is Timestamp) {
//             date = (data['timestamp'] as Timestamp).toDate();
//           } else if (data['timestamp'] is String) {
//             date = DateTime.tryParse(data['timestamp'] as String);
//           }

//           if (date == null) {
//             print('Invalid timestamp for document ${doc.id}');
//             continue;
//           }

//           final workoutName = data['workout_name'] as String?;
//           final count = data['count'] as int?;
//           final feedbackCounts = data['feedback_counts'] as List<dynamic>?;

//           print(
//               'Processed data: Date: $date, Workout: $workoutName, Count: $count');

//           if (count != null && count > 0) {
//             final key = DateTime(date.year, date.month, date.day);
//             if (!newEvents.containsKey(key)) {
//               newEvents[key] = [];
//               newEventDetails[key] = [];
//             }

//             Color? eventColor = workoutColors[workoutName];

//             if (eventColor != null && !newEvents[key]!.contains(eventColor)) {
//               newEvents[key]!.add(eventColor);
//             }

//             newEventDetails[key]!.add({
//               'workout_name': workoutName,
//               'count': count,
//               'feedback_counts': feedbackCounts,
//               'timestamp': date,
//             });
//           }
//         }

//         print('Processed events: $newEvents');
//         print('Processed event details: $newEventDetails');

//         setState(() {
//           _events = newEvents;
//           _eventDetails = newEventDetails;
//           _isLoading = false;
//           if (_selectedDay != null) {
//             _updateSelectedDayEvents(_selectedDay!);
//           }
//         });
//       } catch (e) {
//         print('Error loading events: $e');
//         setState(() {
//           _errorMessage = 'Failed to load events. Please try again later.';
//           _isLoading = false;
//         });
//       }
//     } else {
//       print('User not logged in');
//       setState(() {
//         _errorMessage = 'User not logged in.';
//         _isLoading = false;
//       });
//     }
//   }

//   List<Color> _getEventsForDay(DateTime day) {
//     final eventDate = DateTime(day.year, day.month, day.day);
//     return _events[eventDate] ?? [];
//   }

//   void _updateSelectedDayEvents(DateTime selectedDay) {
//     final eventDate =
//         DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
//     _selectedDayEvents = _eventDetails[eventDate] ?? [];
//     _selectedDayEvents.sort((a, b) =>
//         (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));
//   }

//   String _formatTimestamp(dynamic timestamp) {
//     if (timestamp is Timestamp) {
//       return DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp.toDate());
//     } else if (timestamp is DateTime) {
//       return DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp);
//     } else if (timestamp is String) {
//       return timestamp;
//     } else {
//       return 'Unknown';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: aitNavy,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: const Text('운동 달력',
//             style: TextStyle(
//               fontSize: 25,
//               color: Colors.white,
//               fontWeight: FontWeight.w900,
//             )),
//         centerTitle: true,
//       ),
//       body: _isLoading
//           ? Center(child: CircularProgressIndicator())
//           : _errorMessage != null
//               ? Center(child: Text(_errorMessage!))
//               : Column(
//                   children: [
//                     TableCalendar<Color>(
//                       firstDay: DateTime.utc(2020, 1, 1),
//                       lastDay: DateTime.utc(2030, 12, 31),
//                       focusedDay: _focusedDay,
//                       calendarFormat: _calendarFormat,
//                       selectedDayPredicate: (day) =>
//                           isSameDay(_selectedDay, day),
//                       onDaySelected: (selectedDay, focusedDay) {
//                         setState(() {
//                           _selectedDay = selectedDay;
//                           _focusedDay = focusedDay;
//                           _updateSelectedDayEvents(selectedDay);
//                         });
//                       },
//                       onFormatChanged: (format) {
//                         setState(() {
//                           _calendarFormat = format;
//                         });
//                       },
//                       onPageChanged: (focusedDay) {
//                         _focusedDay = focusedDay;
//                       },
//                       eventLoader: _getEventsForDay,
//                       calendarBuilders: CalendarBuilders(
//                         markerBuilder: (context, date, events) {
//                           if (events.isNotEmpty) {
//                             return Positioned(
//                               bottom: 1,
//                               child: Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: events
//                                     .map((color) => _buildMarker(color))
//                                     .toList(),
//                               ),
//                             );
//                           }
//                           return null;
//                         },
//                       ),
//                       calendarStyle: CalendarStyle(
//                         weekendTextStyle: TextStyle(color: Colors.red[200]),
//                         holidayTextStyle: TextStyle(color: Colors.red[200]),
//                         selectedTextStyle: const TextStyle(color: Colors.white),
//                         todayTextStyle: const TextStyle(color: Colors.white),
//                         defaultTextStyle: const TextStyle(color: Colors.white),
//                         outsideTextStyle: const TextStyle(color: Colors.grey),
//                       ),
//                       daysOfWeekStyle: DaysOfWeekStyle(
//                         weekdayStyle: const TextStyle(color: Colors.white),
//                         weekendStyle: TextStyle(color: Colors.red[200]),
//                       ),
//                       headerStyle: const HeaderStyle(
//                         formatButtonVisible: false,
//                         titleCentered: true,
//                         leftChevronIcon:
//                             Icon(Icons.chevron_left, color: Colors.white),
//                         rightChevronIcon:
//                             Icon(Icons.chevron_right, color: Colors.white),
//                         titleTextStyle:
//                             TextStyle(color: Colors.white, fontSize: 18),
//                       ),
//                     ),

//                     const SizedBox(height: 10),

//                     // 푸시업 풀업 스쿼트 표시
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: workoutColors.entries.map((entry) {
//                         return Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 4.0),
//                           child: Row(
//                             children: [
//                               Container(
//                                 width: 10,
//                                 height: 10,
//                                 decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   color: entry.value,
//                                 ),
//                               ),
//                               const SizedBox(width: 5),
//                               Text(workoutNames[entry.key] ?? entry.key,
//                                   style: const TextStyle(color: Colors.white)),
//                               const SizedBox(width: 10),
//                             ],
//                           ),
//                         );
//                       }).toList(),
//                     ),

//                     const SizedBox(height: 20),
//                     const Padding(
//                       padding: EdgeInsets.only(left: 20, right: 20),
//                       child: Row(
//                         children: [
//                           Text(
//                             '기록',
//                             style: TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white),
//                           ),
//                           Expanded(
//                             child: Padding(
//                               padding: EdgeInsets.only(left: 20),
//                               child: Divider(
//                                 color: Colors.white60,
//                                 thickness: 1,
//                                 height: 20,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 10),

//                     // 목록
//                     Expanded(
//                       child: ListView.builder(
//                         itemCount: _selectedDayEvents.length,
//                         itemBuilder: (context, index) {
//                           final event = _selectedDayEvents[index];
//                           return Padding(
//                             padding: const EdgeInsets.symmetric(
//                                 vertical: 8.0, horizontal: 25.0),
//                             child: Row(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Row(
//                                         children: [
//                                           CircleAvatar(
//                                             backgroundColor: workoutColors[
//                                                 event['workout_name']],
//                                             radius: 8,
//                                           ),
//                                           const SizedBox(width: 10),
//                                           Expanded(
//                                             child: Row(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment
//                                                       .spaceBetween,
//                                               children: [
//                                                 Flexible(
//                                                   child: Text(
//                                                     '${workoutNames[event['workout_name']] ?? event['workout_name']}',
//                                                     style: const TextStyle(
//                                                         color: Colors.white,
//                                                         fontSize: 16),
//                                                     overflow:
//                                                         TextOverflow.ellipsis,
//                                                   ),
//                                                 ),
//                                                 Text(
//                                                   '${event['count']} 회',
//                                                   style: const TextStyle(
//                                                       color: Colors.white,
//                                                       fontSize: 16),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       const SizedBox(height: 4),
//                                       Text(
//                                         _formatTimestamp(event['timestamp']),
//                                         style: const TextStyle(
//                                             color: Colors.white70,
//                                             fontSize: 14),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//     );
//   }

//   Widget _buildMarker(Color color) {
//     String workoutName =
//         workoutColors.entries.firstWhere((entry) => entry.value == color).key;
//     return Tooltip(
//       message: workoutNames[workoutName] ?? workoutName,
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 1.0),
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           color: color,
//         ),
//         width: 7.0,
//         height: 7.0,
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ExerciseCalendarWidget extends StatefulWidget {
  @override
  _ExerciseCalendarWidgetState createState() => _ExerciseCalendarWidgetState();
}

class _ExerciseCalendarWidgetState extends State<ExerciseCalendarWidget> {
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

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
    _loadEvents();
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar<Color>(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
              _updateSelectedDayEvents(selectedDay);
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
                    children:
                        events.map((color) => _buildMarker(color)).toList(),
                  ),
                );
              }
              return null;
            },
          ),
          calendarStyle: CalendarStyle(
            weekendTextStyle: TextStyle(color: Colors.red[200]),
            holidayTextStyle: TextStyle(color: Colors.red[200]),
            selectedTextStyle: const TextStyle(color: Colors.white),
            todayTextStyle: const TextStyle(color: Colors.white),
            defaultTextStyle: const TextStyle(color: Colors.white),
            outsideTextStyle: const TextStyle(color: Colors.grey),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: const TextStyle(color: Colors.white),
            weekendStyle: TextStyle(color: Colors.red[200]),
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
            rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
        const SizedBox(height: 10),
        // Display workout markers
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: workoutColors.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
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
                      style: const TextStyle(color: Colors.white)),
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
          child: ListView.builder(
            itemCount: _selectedDayEvents.length,
            itemBuilder: (context, index) {
              final event = _selectedDayEvents[index];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 25.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor:
                                    workoutColors[event['workout_name']],
                                radius: 8,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        '${workoutNames[event['workout_name']] ?? event['workout_name']}',
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 16),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      '${event['count']} 회',
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatTimestamp(event['timestamp']),
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 14),
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
    );
  }

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
}
