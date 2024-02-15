import 'package:flutter/material.dart';

class ElevatedContainer extends StatelessWidget {
  final Widget child;
  final double elevation;
  final double borderRadius;
  final Color color;

  const ElevatedContainer({
    Key? key,
    required this.child,
    this.elevation = 8.0,
    this.borderRadius = 8.0,
    this.color = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: elevation,
      shadowColor: color,
      color: color,
      surfaceTintColor: color,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          // color: Colors.black12,
          borderRadius: BorderRadius.circular(30.0),
        ),
        padding: EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }
}