import 'dart:async';

import 'package:docs_appointment/service/app_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';

class NotificationOverlay extends StatefulWidget {
  final Widget child;

  const NotificationOverlay({super.key, required this.child});

  @override
  State<NotificationOverlay> createState() => _NotificationOverlayState();
}

class _NotificationOverlayState extends State<NotificationOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  String _currentTittle = "";
  String _cureentBody = "";
  bool _isVisible = false ;
  Timer? _dismissTimer;


  @override
  void initState() {
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    // Register notification callback on next frame
    WidgetsBinding.instance.addPostFrameCallback((_){
      final appState = Provider.of<AppState>(context,listen:false);
      appState.onPushNotification = (tittle, body){
        _showNotification(tittle,body);
      };
    });
    super.initState();
  }



  void _showNotification(String titlle, String body ){
    _dismissTimer?.cancel();

    setState(() {
      _currentTittle = titlle;
      _cureentBody = body;
      _isVisible = true;
    });

    _slideController.forward();

    _dismissTimer = Timer(const Duration(milliseconds: 4),(){
      if (mounted){
        _slideController.reverse().then((_){
          if (mounted){
            setState(() {
              _isVisible = false;
            });
          }
        });
      }
    });
  }

  @override
  void dispose(){
    _dismissTimer?.cancel();
    _slideController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        widget.child,
        if (_isVisible)
          Positioned(
            top: MediaQuery.of(context).padding.top+12,
            left: 16,
              right: 16,
            child: Material(
              color: Colors.transparent,
              child: SlideTransition(
                position: _slideAnimation,
                child: Dismissible(
                  key: UniqueKey(),
                  direction: DismissDirection.up,
                  onDismissed: (_) {
                    _dismissTimer?.cancel();
                    _slideController.reverse().then ((_) {
                      setState(() {
                        _isVisible = false;
                      });
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xff0f172a) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],

                      border: Border.all(
                        color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                        width: 1,
                      ),
                    ),

                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: AppTheme.accentGradient,
                            shape: BoxShape.circle,

                          ),

                          child: const Icon(
                            Icons.notifications_active,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),

                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _currentTittle,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: isDark ? Colors.white : AppTheme.primary,
                                ),
                              ),

                              const SizedBox(height: 2),
                              Text(
                                _cureentBody,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                                ),
                              ),
                            ],
                          ),
                        ),

                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          color: isDark ? Colors.white54 : Colors.black45,
                          onPressed: () {
                            _dismissTimer?.cancel();
                            _slideController.reverse().then((_) {
                              setState(() {
                                _isVisible = false;
                              });
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
      ],
    );
  }
}

