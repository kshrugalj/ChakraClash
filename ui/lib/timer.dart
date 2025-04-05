import 'package:flutter/material.dart';
import 'dart:async';

class LinearTimer extends StatefulWidget {
  final double width;
  final double height;
  final int durationInSeconds;
  final Color progressColor;
  final Color backgroundColor;
  final VoidCallback onTimerComplete;
  double progress = 0.0;

  LinearTimer({
    Key? key,
    required this.width,
    required this.height,
    required this.durationInSeconds,
    this.progressColor = Colors.blue,
    this.backgroundColor = Colors.grey,
    required this.onTimerComplete,

    progress = 0.0
  }) : super(key: key);

  @override
  _LinearTimerState createState() => _LinearTimerState();
}

class _LinearTimerState extends State<LinearTimer> {
  late double progress;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    progress = 0.0;
    startTimer(); // Start the timer when the widget is created
  }

  void startTimer() {
    const updateInterval = Duration(milliseconds: 20); // Update every 20ms for smoother progress
    timer = Timer.periodic(updateInterval, (Timer t) {
      if (widget.progress >= 1.0) {
        widget.onTimerComplete(); // Notify parent when the timer completes
      } else {
        setState(() {
          widget.progress += 1 / (widget.durationInSeconds * 50); // 50 updates per second (20ms interval)
        });
      }
    });
  }

  void resetProgress() {
    setState(() {
      progress = 0.0; // Reset the progress when duration changes
    });
    startTimer(); // Start the timer again with the new duration
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: widget.backgroundColor,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: widget.width * widget.progress, // Updates based on progress
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: widget.progressColor,
          ),
        ),
      ),
    );
  }
}
