import 'package:flutter/material.dart';

class VerticalProgressBar extends StatefulWidget {
  final double width;
  final double height;
  final double initialValue;
  final Color progressColor;
  final Color backgroundColor;

  double progress;

  VerticalProgressBar({
    Key? key,
    required this.width,
    required this.height,
    this.initialValue = 0.0,
    this.progressColor = Colors.blue,
    this.backgroundColor = Colors.grey,
    this.progress = 0.0
  }) : super(key: key);

  @override
  _VerticalProgressBarState createState() => _VerticalProgressBarState();
}

class _VerticalProgressBarState extends State<VerticalProgressBar> {
  double progress = 0;

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
        alignment: Alignment.bottomCenter,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 400),
          width: widget.width,
          height: widget.height * widget.progress/100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: widget.progressColor,
          ),
        ),
      ),
    );
  }
}
