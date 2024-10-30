import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../main.dart';
import 'notification_service.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationPage extends StatefulWidget {
  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  TimeOfDay? _selectedTime; // Store selected time here

  @override
  void initState() {
    super.initState();
    _requestNotificationPermissions(); // Request notification permissions
  }

  void _requestNotificationPermissions() async {
    final status = await NotificationService().requestNotificationPermissions();
    if (status.isDenied && context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('알림 권한이 거부되었습니다.'),
          content: Text('알림을 받으려면 앱 설정에서 권한을 허용해야 합니다.'),
          actions: <Widget>[
            TextButton(
              child: Text('설정'),
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
            ),
            TextButton(
              child: Text('취소'), //흠
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            '알림 설정',
            style: TextStyle(
              fontSize: 25,
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          backgroundColor: aitNavy,
          elevation: 0,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                _selectTime(); // Function to select time
              },
              child: Padding(
                // padding: const EdgeInsets.symmetric(vertical: 12.0),
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        _selectedTime == null
                            ? "알림 시간 설정"
                            : '알림 시간: ${_selectedTime!.format(context)}',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        )),
                    const Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                      size: 30,
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                _scheduleDailyNotification(); // Schedule daily notification at selected time
              },
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("알림 예약하기",
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        )),
                    const Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                      size: 30,
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
        // Center(
        //   child: Column(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: [
        //       ElevatedButton(
        //         onPressed: _selectTime, // Function to select time
        //         child: Text(_selectedTime == null
        //             ? '알림 시간 설정'
        //             : '알림 시간: ${_selectedTime!.format(context)}'),
        //       ),
        //       const SizedBox(height: 16),
        //       ElevatedButton(
        //         onPressed:
        //             _scheduleDailyNotification, // Schedule daily notification at selected time
        //         child: Text('알림 예약'),
        //       ),
        //       const SizedBox(height: 16),
        //       ElevatedButton(
        //         onPressed: () async {
        //           await NotificationService().scheduleImmediateNotification();
        //           ScaffoldMessenger.of(context).showSnackBar(
        //             SnackBar(
        //                 content:
        //                     Text('Test notification will appear in 5 seconds')),
        //           );
        //         }, // Call immediate notification
        //         child: Text('5초 후 알림 테스트'),
        //       ),
        //     ],
        //   ),
        // ),
        );
  }

  // Function to show TimePicker and allow user to select time
  Future<void> _selectTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(), // Start with current time
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  // Function to schedule a notification at the selected time daily
  Future<void> _scheduleDailyNotification() async {
    if (_selectedTime != null) {
      final now = DateTime.now();
      DateTime scheduledTime = DateTime(
        now.year,
        now.month,
        now.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      // If the scheduled time is already passed today, schedule it for tomorrow
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(Duration(days: 1));
      }

      print('Scheduled time: $scheduledTime');

      print(
          'Scheduled notification time: $scheduledTime'); // Log the scheduled time

      // Schedule the notification using NotificationService
      await NotificationService()
          .scheduleDailyNotification(scheduledTime)
          .then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('알림이 ${_selectedTime!.format(context)}로 예약되었습니다.')),
        );
        print('Notification scheduled successfully.');
      }).catchError((error) {
        print('Error scheduling notification: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('알림 예약에 실패했습니다.')),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('알림 시간을 설정하세요.')),
      );
    }
  }

  // // Method to show time picker
  // Future<void> _selectTime(BuildContext context) async {
  //   final TimeOfDay? picked = await showTimePicker(
  //     context: context,
  //     initialTime: selectedTime,
  //   );

  //   if (picked != null && picked != selectedTime) {
  //     setState(() {
  //       selectedTime = picked;
  //     });
  //   }
  // }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: const Color(0xFF3D3F5A),
  //     appBar: AppBar(
  //       backgroundColor: const Color(0xFF3D3F5A),
  //       title: const Text(
  //         "알림 설정",
  //         style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
  //       ),
  //       centerTitle: true,
  //     ),
  //     body: Padding(
  //       padding: const EdgeInsets.all(10.0),
  //       child: Column(
  //         children: [
  //           const SizedBox(
  //             height: 30,
  //             child: Padding(
  //               padding: EdgeInsets.only(right: 10),
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.start,
  //                 children: [
  //                   Align(
  //                     alignment: Alignment.center,
  //                     child: Padding(
  //                       padding: EdgeInsets.only(left: 10.0),
  //                       child: Text(
  //                         '운동 알림 설정',
  //                         style: TextStyle(
  //                           color: Colors.white,
  //                           fontWeight: FontWeight.normal,
  //                           fontSize: 16,
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //           const SizedBox(height: 20),
  //           ElevatedButton(
  //             onPressed: () => _selectTime(context), // Open time picker
  //             child: const Text('알림 시간을 선택하세요'),
  //           ),
  //           const SizedBox(height: 20),
  //           Text(
  //             '선택된 시간: ${selectedTime.format(context)}',
  //             style: const TextStyle(color: Colors.white, fontSize: 16),
  //           ),
  //           const SizedBox(height: 20),
  //           ElevatedButton(
  //             onPressed: () {
  //               // Schedule notification using the selected time
  //               scheduleNotification(selectedTime.hour, selectedTime.minute);
  //             },
  //             child: const Text('알림 설정'),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
