import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final IconData prefixIcon;
  final bool isPassword;
  final TextInputType keyboardTypes;
  final String ? Function(String?)? validator;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.prefixIcon,
    this.isPassword=false,
    this.keyboardTypes=TextInputType.text,
    this.validator,
  }):super(key: key);


  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class IconsData {
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText=true;
  bool _isFocused=false;
  @override
  Widget build(BuildContext context) {
    final bool isDark=Theme.of(context).brightness==Brightness.dark;

    return Focus(
      onFocusChange: (hasFocus){
        setState(() {
          _isFocused=hasFocus;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isFocused
            ?[
            BoxShadow(
              color: AppTheme.accent.withOpacity(0.1),
              blurRadius: 12,
              spreadRadius: 2,
            )
          ]
        : [],
        ),
        child: TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword?_obscureText:false,
          keyboardType: widget.keyboardTypes,
          validator: widget.validator,
          style: TextStyle(
            color: isDark? Colors.white38: Colors.black38,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            hintStyle: TextStyle(
              color: isDark? Colors.white30:Colors.black38,
              fontSize: 14,
            ),

              labelStyle: TextStyle(
                color: _isFocused
                    ?AppTheme.accent
                    :(isDark? Colors.white.withOpacity(0.58): Colors.black54),
                fontSize: 14,
          ),
            prefixIcon: Icon(
              widget.prefixIcon,
              color: _isFocused
                ? AppTheme.accent
                  :(isDark ? Colors.white38: Colors.black38),
            ),
            suffixIcon: widget.isPassword
              ?IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility_off_outlined: Icons.visibility_outlined,
                color: isDark ? Colors.white38: Colors.black38,
              ),
              onPressed: (){
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            )
                : null,
            filled: true,
            fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xfff1f5f9),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark ? Colors.white10 : Colors.black12,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppTheme.accent,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppTheme.error,
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppTheme.error,
                width: 2,
              ),
            ),
            errorStyle: const TextStyle(
              color: AppTheme.error,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
