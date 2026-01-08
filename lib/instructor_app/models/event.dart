
import 'package:flutter/material.dart';

class Event {
  final String title;
  final DateTime startTime;
  final Duration duration;
  final Color color;

  Event({
    required this.title,
    required this.startTime,
    required this.duration,
    required this.color,
  });
}

List<Event> events = [];
