import 'dart:async';
import 'dart:math' as math;

import 'package:docs_appointment/models/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../service/app_state.dart';
import '../theme/app_theme.dart';

class VideoCallScreen extends StatefulWidget {
  final String appointmentId;
  final String roomName;
  final String partnerName;
  final String specialtyOrTitle;
  final AppointmentType type;

  const VideoCallScreen({
    Key? key,
  required this .appointmentId,
  required this.roomName,
  required this.partnerName,
  required this.specialtyOrTitle,
  this.type = AppointmentType.video,
  }) : super(key: key);

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  late Timer _timer;
  int _secondsElapsed = 0;
  bool _isMuted = false;
  bool _isVideoOff = false;
  bool _isScreenSharing = false;
  bool _showRecordSheet = false;
  bool _isSpeakerOn = true;

  Timer? _voiceVisualTimer;
  bool _pulse = false;
  List<double> _waveHeights = [20.0, 30.0, 25.0, 40.0, 20.0];

  @override
  void iniState() {
    super.initState();
    _startTimer();
    if (widget.type == AppointmentType.voice) {
      _voiceVisualTimer = Timer.periodic(const Duration(milliseconds: 200),(timer) {
        if (mounted) {
          final random = math.Random();
          setState(() {
            _pulse = !_pulse;
            _waveHeights = List.generate(5, (_) => 10.0 + random.nextDouble() * 35.0);
          });
        }
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer){
      if (mounted) {
        setState(() {
          _secondsElapsed++;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _voiceVisualTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final int minutes = seconds ~/60;
    final int remainingSeconds =seconds % 60;
    return "${minutes.toString().padLeft(2, "0")} :${remainingSeconds.toString().padLeft(2, "0")}";
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.currentUser;
    final bool isDoctor = user?.role == UserRole.doctor;
    final patient = appState.getPatientDetails("pat_demoo"); // Demo Patient Details
    final bool isDark = Theme.of(context).brightness == Brightness.dark;


    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main Video Feed (partner view)
          widget.type == AppointmentType.voice
          ? Container(
            color: const Color(0xff020712),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: _pulse ? 200.0 : 170.0,
                        height: _pulse ? 200.0 : 170.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.accent.withOpacity(0.04),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: _pulse ? 170.0 : 140.0,
                        height: _pulse ? 170.0 : 140.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.accent.withOpacity(0.08),
                        ),
                      ),

                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.accent, width: 2),
                          image: const DecorationImage(
                            image: NetworkImage(
                              "https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=500",
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),
                  const Text(
                    "Secure HIPPA Voice Line",
                    style: TextStyle(color: AppTheme.success, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: 6,
                        height: _waveHeights[index],
                        decoration: BoxDecoration(
                          color: AppTheme.accent,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          )
              : (_isVideoOff
              ? Container(
            color: Colors.black87,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 68,
                    backgroundColor: AppTheme.accent.withOpacity(0.2),
                    child: const Icon(Icons.videocam_off, color: AppTheme.accent, size: 48),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Camera is disbled",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
          )
          : AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  "https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=800&auto=format&fit=crop&q=60",
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.4), Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.8)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          )),

          // RIP WINDOW (self view)
          if (widget.type == AppointmentType.video)
            Positioned(
              top: 60,
              right: 20,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 110,
                  height: 160,
                  color: Colors.grey[900],
                  child: Stack(
                    children: [
                      // Mock local video feed
                      Container(
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(
                              "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500&auto=format&fit=crop&q=60",
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Container(
                        color: Colors.black26,
                      ),
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: const Text(
                          "You",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // CALL METADATA (top left)
          Positioned(
            top: 60,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "REC ${_formatDuration(_secondsElapsed)}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.signal_cellular_alt_rounded, color: AppTheme.success, size: 14),
                          SizedBox(width: 4),
                          Text(
                            "HD Link",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  widget.partnerName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Colors.black, blurRadius: 6)],
                  ),
                ),
                Text(
                  widget.specialtyOrTitle,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    shadows: [Shadow(color: Colors.black, blurRadius: 6)],
                  ),
                ),
              ],
            ),
          ),

          // CONTROL PANEL (Bottom Center)
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Mute Audio
                    _buildCirleButton(
                      icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                      isActive: _isMuted,
                      onTap: () => setState(() => _isMuted = !_isMuted),
                    ),
                    // Camera Toggle / Speaker Toggle
                    widget.type == AppointmentType.video
                    ? _buildCirleButton(
                      icon: _isVideoOff ? Icons.videocam_off_rounded : Icons.videocam_rounded,
                      isActive: _isVideoOff,
                      onTap: () => setState(() => _isVideoOff = !_isVideoOff),
                    )
                        :_buildCirleButton(
                      icon: _isSpeakerOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                      isActive: !_isSpeakerOn,
                      onTap: () => setState(() => _isSpeakerOn = !_isSpeakerOn),
                    ),
                    // Screen Share
                    _buildCirleButton(
                      icon: _isScreenSharing ? Icons.screen_share_rounded : Icons.mobile_screen_share_rounded,
                      isActive: _isScreenSharing,
                      onTap: () {
                        setState(() => _isScreenSharing = !_isScreenSharing);
                        appState.triggerPushNotification(
                          "Screen Sharing",
                          _isScreenSharing ? "You started sharing your screen" : "Screen share stopped",
                        );
                      },
                    ),
                    // View Records/info Button
                    _buildCirleButton(
                      icon: isDoctor ? Icons.assignment_rounded : Icons.contact_emergency_rounded,
                      isActive: _showRecordSheet,
                      onTap: () => setState(() => _showRecordSheet = !_showRecordSheet),
                    ),
                    // End Call
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: AppTheme.error,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: AppTheme.error, blurRadius: 15, spreadRadius: -2)],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.call_end_rounded, color: Colors.white),
                        onPressed: () {
                          appState.triggerPushNotification(
                            "call finished",
                            "the session with ${widget.partnerName} has ended. Summary notes are available",
                          );
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // RECORD SHEET SIDE DRAWER OVERLAY
          if (_showRecordSheet)
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              width: MediaQuery.of(context).size.width * 0.8,
              child: Container(
                color: isDark ? const Color(0xff0f172a) : Colors.white,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 16,
                  bottom: 16,
                  left: 20,
                  right: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isDoctor ? "patient Records" : "Physician info",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppTheme.primary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => setState(() => _showRecordSheet = false),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        child: isDoctor
                            ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow("Name", patient?.name ?? "john Doe", isDark),
                            _buildInfoRow("Age/Sex", "${patient?.age ?? "32"} yrs / ${patient?.gender ?? "male"}", isDark),
                            const SizedBox(height: 16),
                            Text(
                              "clinical background",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              patient?.medicalHistory ?? "No Prior history recorded",
                              style: TextStyle(
                                color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              "Shared Files",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...appState.cloudFiles.map((file) => Card(
                              color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02),
                              child: ListTile(
                                dense: true,
                                leading: const Icon(Icons.picture_as_pdf_outlined, color: AppTheme.error),
                                title: Text(file.name),
                                subtitle: Text(file.size),
                                trailing: const Icon(Icons.download_rounded, size: 16),
                              ),
                            )),
                          ],
                        )
                            : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: CircleAvatar(
                                radius: 40,
                                backgroundImage: const NetworkImage(
                                  "https://images.unsplash.com/photo-1612349317158-e413f6a5b16d?w=500",
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: Text(
                                widget.partnerName,
                                style: const TextStyle(color: AppTheme.accent),
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              "Consultation Purpose",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Telehealth evaluation. Doctor will give diagnostic queries outline care pathways and issues e-prescriptions if required.",
                              style: TextStyle(color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
        ],
      ),

    );
  }


  Widget _buildCirleButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
}) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.black54,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: isActive ? Colors.black : Colors.white,
          size: 22,
        ),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isDark ? Colors.white30 : Colors.black38)),
          Text(value, style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppTheme.primary)),
        ],
      ),
    );
  }
}
