import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final Color borderGradientColor1;
  final Color borderGradientColor2;
  final Color fillGradientColor1;
  final Color fillGradientColor2;
  final EdgeInsetsGeometry padding;

  const GlassCard({
    Key? key,
  required this.child,
  this.borderRadius = 24,
  this.blur = 15,
  this.borderGradientColor1 = Colors.white24,
  this.borderGradientColor2 = const Color(0x0dffffff),
  this.fillGradientColor1 = Colors.white10,
  this.fillGradientColor2 = const Color(0x05ffffff),
  this.padding = const EdgeInsets.all(20),

  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              colors: [fillGradientColor1, fillGradientColor2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
