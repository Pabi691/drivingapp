import 'package:flutter/material.dart';

class Event {
  final String id;
  final String title;
  final DateTime startTime;
  final Duration duration;
  final Color color;
  final String status;

  const Event({
    required this.id,
    required this.title,
    required this.startTime,
    required this.duration,
    required this.color,
    required this.status,
  });
}

List<Event> events = [];
