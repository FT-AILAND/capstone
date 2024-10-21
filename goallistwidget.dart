import 'package:flutter/material.dart';

class GoalListWidget extends StatelessWidget {
  final List<String> exercises;
  final List<int> repetitions;
  final Function(int) onTap;

  GoalListWidget({
    required this.exercises,
    required this.repetitions,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
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
              offset: Offset(2, 5),
            ),
          ],
        ),
        child: SizedBox(
          width: 400,
          height: 110, // Increased height to better fit the list items
          child: ListView.builder(
            itemCount: exercises.length,
            itemBuilder: (BuildContext ctx, int idx) {
              return InkWell(
                onTap: () => onTap(idx), // Callback for handling tap
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          exercises[idx],
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            '${repetitions[idx]}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                              width: 10), // Space between number and icon
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
    );
  }
}
