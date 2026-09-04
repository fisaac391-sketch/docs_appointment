import 'package:docs_appointment/models/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../service/app_state.dart';
import '../shared/video_call_screen.dart';
import '../theme/app_theme.dart';
import 'cloud_storage_screen.dart';
import 'doctor_list_screen.dart';

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.currentUser;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final patient = appState.getPatientDetails(user?.id ?? "pat_demo");

    // Filter appointments
    final upcomingApts = appState.appointments
        .where((a) => a.status == AppointmentStatus.upcoming)
        .toList();

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
                gradient: AppTheme.primaryGradient,
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
                // Top Custom Bar
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
                              "Welcome back",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                            Text(
                              "Abassy John",
                              style:  const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),

                          ],
                        ),

                        // Notification Ball
                        Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white10,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white24),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.notifications_outlined, color: Colors.white,),
                                onPressed: () {
                                  _showNotificationDialog(context, appState);
                                },
                              ),
                            ),
                            if (appState.unreadNotificationsCount > 0)
                              Positioned(
                                right: 4,
                                top: 4,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration:  const BoxDecoration(
                                    color: AppTheme.error,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minHeight: 16,
                                    minWidth: 16,
                                  ),
                                  child: Text(
                                    '${appState.unreadNotificationsCount}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),

                      ],
                    ),
                  ),
                ),

                // Calendar Synchronization Status Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Card(
                      elevation: 4,
                      shadowColor: Colors.black12,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: appState.isCalendarSynced
                                    ? AppTheme.success.withOpacity(0.1)
                                    : AppTheme.warning.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                appState.isCalendarSynced
                                    ? Icons.sync_lock_rounded
                                    : Icons.sync_problem_rounded,
                                color: appState.isCalendarSynced
                                    ? AppTheme.success
                                    : AppTheme.warning,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Calendar Synchronization",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: isDark ? Colors.white : AppTheme.primary,
                                    ),
                                  ),
                                  Text(
                                    appState.isCalendarSynced
                                        ? "Synced (Last: ${appState.lastSyncedTime != null ? DateFormat('HH:mm').format(appState.lastSyncedTime!): 'Just now'})"
                                        : "Not Linked to Calendar",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: appState.isSyncing
                                  ? null
                                  : () => appState.syncCalendar(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: appState.isCalendarSynced
                                    ? Colors.transparent
                                    : AppTheme.accent,
                                elevation: appState.isCalendarSynced ? 0 : 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(
                                    color: appState.isCalendarSynced
                                        ? (isDark ? Colors.white24 : Colors.black12)
                                        : Colors.transparent,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              child: appState.isSyncing
                                  ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                              )
                                  : Text(
                                appState.isCalendarSynced ? "Sync" : "Link",
                                style: TextStyle(
                                  color: appState.isCalendarSynced
                                      ? (isDark ? Colors.white70 : AppTheme.primary)
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),

                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Upcoming Consultation Bnner
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Next Consultation",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (upcomingApts.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xff0f172a) : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
                            ),
                            child: const Center(
                              child: Column(
                                children: [
                                  Icon(Icons.calendar_today_outlined, color: AppTheme.accent, size: 36),
                                  SizedBox(height: 8),
                                  Text(
                                    "No upcoming appointments.",
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  Text("Book a new session below", style: TextStyle(fontSize: 12)),
                                ],
                              ),
                            ),
                          )
                        else
                          ...upcomingApts.take(1).map((apt) {
                            return Card(
                              elevation: 0,
                              color: isDark ? const Color(0xff0f172a) : const Color(0xfff1f5f9),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 24,
                                          backgroundColor: AppTheme.accent.withOpacity(0.1),
                                          child: const Icon(Icons.person_rounded, color: AppTheme.accent),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                apt.doctorName,
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                                                ? "Video call"
                                                : (apt.type == AppointmentType.voice? "Voice call" : "In-Clinic"),
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
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_month, size: 16, color: isDark ? Colors.white30 : Colors.black38),
                                        const SizedBox(width: 8),
                                        Text(
                                          DateFormat('EEE, MMM d, y').format(apt.date),
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                        const Spacer(),
                                        Icon(Icons.access_time, size: 16, color: isDark ? Colors.white30 : Colors.black38),
                                        const SizedBox(width: 8),
                                        Text(
                                          apt.timeSlot,
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    if (apt.type == AppointmentType.video || apt.type == AppointmentType.voice)
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => VideoCallScreen(
                                                appointmentId: apt.id,
                                                roomName: apt.videoRoomId ?? "Room",
                                                partnerName: apt.doctorName,
                                                specialtyOrTitle: apt.doctorSpecialty,
                                                type: apt.type,
                                              ),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: apt.type == AppointmentType.video
                                              ? AppTheme.accent
                                              : Colors.indigo,
                                          minimumSize: const Size(double.infinity, 44),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              apt.type == AppointmentType.video
                                                  ? Icons.videocam_rounded
                                                  : Icons.phone_rounded,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              apt.type == AppointmentType.video
                                                  ? "Join Video Consultation"
                                                  : "Join Voice Consultation",
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      )
                                  ],
                                ),
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Action grid
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  sliver: SliverGrid.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      _builderGridAction(
                        icon: Icons.person_search_rounded,
                        title: "Find & Book Doctor",
                        desc: "Browse doctors and slots",
                        color: Colors.blue,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DoctorListScreen(),
                            ),
                          );
                        },
                        isDark: isDark,

                      ),
                      _builderGridAction(
                        icon: Icons.cloud_upload_rounded,
                        title: "Cloud Material Filer",
                        desc: "Secure storage for records",
                        color: Colors.purple,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CloudStorageScreen(),
                            ),
                          );
                        },
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Patient Details and File (self Record Preview)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Your Patient Profile & History",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const CircleAvatar(
                                      radius: 20,
                                      backgroundColor: AppTheme.accent,
                                      child: Icon(Icons.person, color: Colors.white),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(user?.name?? "John Doe", style: const TextStyle(fontWeight: FontWeight.bold)),
                                        Text(user?.email?? "Jonh.doe@gmail.com", style: const TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text("ID: pat_demo", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                                const Divider(height: 24),
                                Text(
                                  "Clinical Notes / Medical History",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: isDark ? Colors.white70 : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  patient?.medicalHistory ?? "No Medical History",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark? AppTheme.textMutedDark : AppTheme.textMutedLight,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Icon(Icons.file_present_rounded, size: 16, color: AppTheme.accent),
                                    const SizedBox(width: 6),
                                    Text(
                                      "${patient?.files.length ?? 0} upload documents in patient file",
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.accent),

                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 40)),
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
}

Widget _builderGridAction({
  required IconData icon,
  required String title,
  required String desc,
  required Color color,
  required VoidCallback onTap,
  required bool isDark,


}) {
  return Card(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                    overflow: TextOverflow.ellipsis

                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

void _showNotificationDialog(BuildContext context, AppState appState) {
  showDialog(
    context: context,
    builder: (context) {
      final bool isDark = Theme.of(context).brightness == Brightness.dark;
      return AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text ("Push Notifications"),
            IconButton(
              icon: const Icon(Icons.clear_all, size: 20),
              tooltip: "Clear all",
              onPressed: () {
                appState.clearNotifications();
                Navigator.pop(context);
              },
            )
          ],
        ),
        content: Container(
          width: double.maxFinite,
          height: 350,
          child: appState.notifications.isEmpty
              ? const Center(
            child: Text("No Notifications yet"),
          )
              :  ListView.separated(
              itemCount: appState.notifications.length,
              separatorBuilder: (_, _) => const Divider(),
              itemBuilder: (context, i) {
                final n = appState.notifications[i];
                return ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppTheme.accentLight,
                    child: Icon(Icons.message, color: AppTheme.accent, size: 18),
                  ),
                  title: Text(n.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(n.body, style: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('HH:mm - d MMM').format(n.timestamp),
                        style: TextStyle(fontSize: 10, color: isDark ? Colors.white30 : Colors.black38),
                      ),
                    ],
                  ),
                );
              }
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              appState.markAllNotificationsAsRead();
              Navigator.pop(context);
            },
            child: const Text("Close"),
          )
        ],
      );
    },
  );
}
