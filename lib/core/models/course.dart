import 'package:flutter/material.dart';

class Course {
  final String title;
  final String chapter;
  final String lessonsInfo;
  final String author;
  final double progress;
  final Color color;

  Course({
    required this.title,
    required this.chapter,
    required this.lessonsInfo,
    required this.author,
    required this.progress,
    required this.color,
  });
}