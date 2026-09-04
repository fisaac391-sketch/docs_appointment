import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Gradient? gradient;
  final IconData? icon;
  final bool isSecondary;

  const CustomButton({super.key, required this.text, required this.onPressed,  this.isLoading = false, this.gradient, this.icon,  this.isSecondary = false});

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;


  @override
  void initState() {
    super.initState();
    _controller= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.95,
      upperBound: 1.0,
    );
    _scaleAnimation = _controller.drive(CurveTween(curve: Curves.easeOut));
  }



  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness==Brightness.dark;

    return MouseRegion(
      cursor: widget.onPressed != null && !widget.isLoading
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTapDown: widget.onPressed != null && !widget.isLoading
            ?(_) =>_controller.reverse()
            : null,
        onTapUp: widget.onPressed != null && !widget.isLoading
          ?(_) =>_controller.forward()
            :null,
        onTapCancel: widget.onPressed !=null && ! widget.isLoading
          ?() =>_controller.forward()
            :null,
        onTap: widget.onPressed != null && !widget.isLoading
          ? widget.onPressed
            : null,
        child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context,child){
          return Transform.scale(
          scale: _scaleAnimation.value,
            child: child,
          );
      },

          child: Container(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: widget.onPressed == null
                ? null
                  :(widget.isSecondary
                  ? null
              : (widget.gradient ?? AppTheme.accentGradient)),
              color: widget.onPressed == null
                ? (isDark ? Colors.white10 : Colors.black12)
                  :(widget.isSecondary
                  ?(isDark ? Colors.white.withOpacity(0.05): Colors.black.withOpacity(0.05))
              : null),
              boxShadow: widget.onPressed == null || widget.isSecondary
                ? null
                  : AppTheme.accentShadow,
                  border: widget.isSecondary
                ? Border.all(
                    color: isDark ? Colors.white12 : Colors.black12,
                    width: 1.5,
                  )
                      : null,
              ),
            child: Center(
              child: widget.isLoading
                  ?const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
             : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null)...[
                    Icon(
                      widget.icon,
                      color: widget.isSecondary
                      ?(isDark ? Colors.white : AppTheme.primary)
                          : Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 10),

                  ],
                  Text(
                    widget.text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: widget.onPressed == null
                        ? (isDark ? Colors.white30 : Colors.black38)
                          : (widget.isSecondary
                          ? (isDark ? Colors.white : AppTheme.primary)
                      : Colors.white),

                    ),
                  )
                ],
              )
            ),


            ),
          ),

      ),
    );

  }
}
