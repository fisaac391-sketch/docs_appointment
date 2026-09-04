import 'package:docs_appointment/login/login.dart';
import 'package:docs_appointment/models/models.dart';
import 'package:docs_appointment/patient/patient_dashboard.dart';
import 'package:docs_appointment/service/app_state.dart';
import 'package:docs_appointment/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import 'doctor/doctor_dashboard.dart';
import 'notification_overlay/notification_overlay.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediFred',
      theme: AppTheme.darkTheme(context),
      debugShowCheckedModeBanner: false,
      darkTheme: AppTheme.darkTheme(context),
      themeMode: ThemeMode.system,
      builder: (context, child){
        return NotificationOverlay(child: child!);
       },
      home: const RootNavigationGate(),
    );
  }
}

class RootNavigationGate extends StatelessWidget {
  const RootNavigationGate({super.key});

  @override
  Widget build(BuildContext context){
    final appState = Provider.of<AppState>(context);
    final user = appState.currentUser;

    if (user == null){
      return  const Login();

    }

    switch (user.role){
      case UserRole.patient:
        return const PatientDashboard();
      case UserRole.doctor:
        return DashBoard();
    }
  }
}


