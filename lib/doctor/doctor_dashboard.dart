import 'package:docs_appointment/doctor/patient_list_screen.dart';
import 'package:docs_appointment/models/models.dart';
import 'package:docs_appointment/service/app_state.dart';
import 'package:docs_appointment/shared/video_call_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  late final appState = Provider.of<AppState>(context);
  late final user = appState.currentUser;
  late final bool isDark = Theme.of(context).brightness == Brightness.dark;

  // Filter appointment for this doctor
  late final upcomingApts = appState.appointments
      .where((a) => a.doctorId == user?.id && a.status == AppointmentStatus.upcoming)
      .toList();




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Header Background Gradient
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 220,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppTheme.darkGradient,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
            ),
          ),

          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Top Greeting
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Welcome Doctor",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                            Text(
                              "Dr. Adrian John",
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              user?.specialty ?? "Cardiology Specialist",
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.accent.withOpacity(0.9),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        // Profile Avatar
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.white10,
                          child: const Icon(Icons.medical_services_outlined, color: Colors.white, size: 28),
                        ),
                      ],
                    ),
                  ),
                ),
                // Clinical stats card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatItem("Appointments", "${upcomingApts.length}", isDark),
                            Container(width: 1, height: 40, color: isDark ? Colors.white10 : Colors.black12),
                            _buildStatItem("Rating", "4.9", isDark),
                            Container(width: 1, height: 40, color: isDark ? Colors.white10 : Colors.black12),
                            _buildStatItem("Patients", "1", isDark), // Currently demo patient
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Clinical Schedule Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Today's Consultation Schedule",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "${upcomingApts.length} upcoming",
                          style: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 10)),

                // Schedule List
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  sliver: upcomingApts.isEmpty
                      ? SliverToBoxAdapter(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Icon(Icons.calendar_month_outlined, color: Colors.grey[400], size: 40),
                            const SizedBox(height: 10),
                            const Text("No appointments today", style: TextStyle(fontWeight: FontWeight.bold)),
                            const Text("Enjoy your free time!", style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  )
                      :SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final apt = upcomingApts[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: AppTheme.accentLight,
                                      child: Icon(Icons.person, color: AppTheme.accent),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            apt.patientName,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                          Text(
                                            "Slot: ${apt.timeSlot}",
                                            style: TextStyle(
                                              color: isDark ? Colors.white60 : Colors.black54,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: apt.type == AppointmentType.video
                                            ? AppTheme.accent.withOpacity(0.1)
                                            : (apt.type == AppointmentType.voice
                                            ? Colors.indigo.withOpacity(0.1)
                                            : Colors.green.withOpacity(0.1)),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        apt.type == AppointmentType.video
                                            ? "Video Telehealth"
                                            : (apt.type == AppointmentType.voice ? "Voice Telehealth" : "In-Person"),
                                        style: TextStyle(
                                          color: apt.type == AppointmentType.video
                                              ? AppTheme.accent
                                              : (apt.type == AppointmentType.voice ? Colors.indigo : Colors.green),
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => PatientListScreen(initialSearch: apt.patientName),
                                            ),
                                          );
                                        },
                                        child: const Text("View Patient Record"),
                                      ),
                                    ),
                                    if (apt.type == AppointmentType.video || apt.type == AppointmentType.voice) ...[
                                      const SizedBox(width: 12),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => VideoCallScreen(
                                                appointmentId: apt.id,
                                                roomName: apt.videoRoomId ?? "Room",
                                                partnerName: apt.patientName,
                                                specialtyOrTitle: "Consulting Patient",
                                                type: apt.type,
                                              ),
                                            ),
                                          );
                                        },
                                        icon: Icon(
                                          apt.type == AppointmentType.video
                                              ? Icons.videocam_rounded
                                              : Icons.phone_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        label: Text(
                                          apt.type == AppointmentType.video ? "Start Video" : "Start Voice",
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: apt.type == AppointmentType.video
                                              ? AppTheme.accent
                                              : Colors.indigo,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: upcomingApts.length,
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Shortcut grid
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Physician Controls",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _buildControlCard(
                                icon: Icons.folder_shared_rounded,
                                title: "Patient Records",
                                subtitle: "Clinical notes & files",
                                color: AppTheme.accent,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const PatientListScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),

                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 60)),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          appState.logout();
        },
        backgroundColor: Colors.redAccent,
        tooltip: "Logout",
        child: const Icon(Icons.logout_rounded, color: Colors.white),
      ),
    );
  }


  Widget _buildStatItem(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppTheme.accent),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54),
        ),
      ],
    );
  }

  Widget _buildControlCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(subtitle, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16)
            ],
          ),
        ),
      ),
    );
  }
}




























