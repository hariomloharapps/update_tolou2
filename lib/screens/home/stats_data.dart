import 'package:flutter/material.dart';

import 'package:tolu_7/data/database/database_helper.dart';
import 'package:tolu_7/data/models/todo.dart';

class WeeklyAverageData {
  final String duration;
  final double percentageChange;
  final bool isIncrease;

  WeeklyAverageData({
    required this.duration,
    required this.percentageChange,
    required this.isIncrease,
  });
}
//
// class TasksData {
//   final int completedTasks;
//   final int totalTasks;
//   final double progress;
//
//   TasksData({
//     required this.completedTasks,
//     required this.totalTasks,
//   }) : progress = totalTasks == 0 ? 0 : completedTasks / totalTasks;
//
//   String get taskRatio => '$completedTasks/$totalTasks';
// }

// Sample data
final weeklyAverageData = WeeklyAverageData(
  duration: '6h 23m',
  percentageChange: 15,
  isIncrease: false,
);
//
// final tasksData = TasksData(
//   completedTasks: 1,
//   totalTasks: 1,
// );


