import 'package:flutter/material.dart';

class WorkDetailPage extends StatefulWidget {
  String workoutName;
  String description;
  bool isReadyForAI;
  String imageUrl;
  String korName;

  WorkDetailPage({
    super.key, 
    required this.workoutName,
    required this.description,
    required this.isReadyForAI,
    required this.imageUrl,
    required this.korName,
  });

  @override
  // ignore: no_logic_in_create_state
  State<WorkDetailPage> createState() => _WorkDetailPageState(
    workoutName: workoutName,
    description: description,
    isReadyForAI: isReadyForAI,
    imageUrl: imageUrl,
    korName: korName,
  );
}

class _WorkDetailPageState extends State<WorkDetailPage> {
  int _repetition = 10;
  String workoutName;
  String description;
  bool isReadyForAI;
  String imageUrl;
  String korName;

  _WorkDetailPageState({
    required this.workoutName,
    required this.description,
    required this.isReadyForAI,
    required this.imageUrl,
    required this.korName,
  });

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}