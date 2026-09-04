import 'dart:async';

import 'package:docs_appointment/models/models.dart';
import 'package:flutter/cupertino.dart';

class AppState extends ChangeNotifier{
  UserSession? _currentUser;
  UserSession? get currentUser => _currentUser;
  bool _isLoading =false;
  bool get isLoading => _isLoading;

  bool _isCalendarSynced = false;
  bool get isCalendarSynced => _isCalendarSynced;
  DateTime? _lastSyncedTime;
  DateTime? get lastSyncedTime => _lastSyncedTime;
  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  SelectionChangedCallback? onNewNotificationTriggered;
  void Function (String title , String body)? onPushNotification;

  final List<Timer> _activeReminderTimers = [];

  // Mock Database
  final List<Doctor> _doctors = [
    Doctor(
      id: "doc1",
      name: "Dr. Adrian Vance",
      email: "adrian.vance@medilink.com",
      specialty: "Cardiology",
      imageUrl: "https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3",
      bio: "Board-certified cardiologist with over 12 years of experience specializing in cardiovascular health, preventative medicine, and heart failure management. Graduated from Johns Hopkins Medicine.",
      rating: 4.9,
      fred: "Fred",
      reviewsCount: 312,
      experienceYears: 12,
      availableTimeslots: ["09:00 AM", "10:30 AM", "11:00 AM", "02:00 PM", "03:30 PM", "04:00 PM"],
    ),
    Doctor(
      id: "doc2",
      name: "Dr. Sarah Jenkins",
      email: "sarah.jenkins@medilink.com",
      specialty: "Pediatrics",
      imageUrl: "https://images.unsplash.com/photo-1594824813573-246434de83fb?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3",
      bio: "Dedicated pediatrician passionate about providing comprehensive, compassionate pediatric care from infancy through adolescence. Focuses on developmental milestones and nutritional health.",
      rating: 4.8,
      fred: "Fred",
      reviewsCount: 184,
      experienceYears: 8,
      availableTimeslots: ["08:30 AM", "10:00 AM", "11:30 AM", "01:30 PM", "03:00 PM", "04:30 PM"],
    ),
    Doctor(
      id: "doc3",
      name: "Dr. Marcus Chen",
      email: "marcus.chen@medilink.com",
      specialty: "Dermatology",
      imageUrl: "https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3",
      bio: "Expert dermatologist specializing in medical, surgical, and cosmetic dermatology. Renowned researcher in melanoma screening and advanced laser treatments.",
      rating: 4.7,
      fred: "Fred",
      reviewsCount: 245,
      experienceYears: 10,
      availableTimeslots: ["09:30 AM", "11:00 AM", "02:30 PM", "04:00 PM", "05:00 PM"],
    ),
    Doctor(
      id: "doc4",
      name: "Dr. Elena Rostova",
      email: "elena.rostova@medilink.com",
      specialty: "Neurology",
      imageUrl: "https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3",
      bio: "Clinical neurologist focused on sleep disorders, neuromuscular conditions, and chronic migraine therapies. Holds a fellowship in Neurophysiology.",
      rating: 4.9,
      fred: "Fred",
      reviewsCount: 156,
      experienceYears: 15,
      availableTimeslots: ["10:00 AM", "11:30 AM", "01:00 PM", "03:30 PM", "04:30 PM"],
    ),
  ];

  final List<Appointment> _appointments = [];
  final List<MedicalFile> _cloudFiles = [
    MedicalFile(
      id: "f1",
      name: "Blood_Panel_Results.pdf",
      size: "2.4 MB",
      uploadDate: "June 24, 2026",
      fileType: "pdf",
    ),
    MedicalFile(
      id: "f2",
      name: "Chest_XRay_Report.jpg",
      size: "4.8 MB",
      uploadDate: "July 02, 2026",
      fileType: "image",
    ),
    MedicalFile(
      id: "f3",
      name: "Vaccination_Card.pdf",
      size: "1.1 MB",
      uploadDate: "July 10, 2026",
      fileType: "pdf",
    ),
  ];

  final List<AppNotification> _notifications = [];

  // Patient detail database (hardcoded for simulation)
  final Map<String, Patient> _patients = {
    "pat_demo": Patient(
      id: "pat_demo",
      name: "John Doe",
      email: "john.doe@gmail.com",
      age: "32",
      gender: "Male",
      medicalHistory: "Diagnosed with mild seasonal asthma in 2022. No active medication. High tolerance to penicillin. Family history of hypertension.",
      files: [
        MedicalFile(id: "f1", name: "Blood_Panel_Results.pdf", size: "2.4 MB", uploadDate: "June 24, 2026", fileType: "pdf"),
        MedicalFile(id: "f2", name: "Chest_XRay_Report.jpg", size: "4.8 MB", uploadDate: "July 02, 2026", fileType: "image"),
      ],
    ),
  };

  // Getters
  List<Doctor> get doctors => _doctors;
  List<Appointment> get appointments => _appointments;
  List<MedicalFile> get cloudFiles => _cloudFiles;
  List<AppNotification> get notifications => _notifications;
  int get unreadNotificationsCount => _notifications.where((n) => !n.isRead).length;

  AppState() {
    // Generate default appointments for the demo
    _appointments.addAll([
      Appointment(
        id: "apt_1",
        doctorId: "doc1",
        doctorName: "Dr. Adrian Vance",
        doctorSpecialty: "Cardiology",
        patientId: "pat_demo",
        patientName: "John Doe",
        date: DateTime.now().add(const Duration(days: 1)),
        timeSlot: "10:30 AM",
        status: AppointmentStatus.upcoming,
        type: AppointmentType.video,
        videoRoomId: "room_cardio_vance",
      ),
      Appointment(
        id: "apt_2",
        doctorId: "doc2",
        doctorName: "Dr. Sarah Jenkins",
        doctorSpecialty: "Pediatrics",
        patientId: "pat_demo",
        patientName: "John Doe",
        date: DateTime.now().subtract(const Duration(days: 4)),
        timeSlot: "03:00 PM",
        status: AppointmentStatus.completed,
        type: AppointmentType.inPeson,
        videoRoomId: '2',
      ),
    ]);
  }

  @override
  void dispose() {
    for (var timer in _activeReminderTimers) {
      timer.cancel();
    }
    super.dispose();
  }

  // --- Auth Handlers ---
  Future<bool> login(String email, String password, UserRole role) async {
    _isLoading = true;
    notifyListeners();

    // Simulate network latency
    await Future.delayed(const Duration(milliseconds: 800));

    if (role == UserRole.doctor) {
      final matchingDoc = _doctors.firstWhere(
            (doc) => doc.email.toLowerCase() == email.trim().toLowerCase(),
        orElse: () => _doctors[0],
      );
      _currentUser = UserSession(
        id: matchingDoc.id,
        name: matchingDoc.name,
        email: matchingDoc.email,
        role: UserRole.doctor,
        specialty: matchingDoc.specialty,
      );
    } else {
      _currentUser = UserSession(
        id: "pat_demo",
        name: "John Doe",
        email: email.isEmpty ? "john.doe@gmail.com" : email,
        role: UserRole.patient,
      );
    }

    _isLoading = false;
    notifyListeners();
    triggerPushNotification(
      "Login Successful",
      "Welcome back, ${_currentUser!.name}! You are logged in as a ${role.name}.",
    );
    return true;
  }

  Future<bool> register(String name, String email, String password, UserRole role, {String? specialty}) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1000));

    if (role == UserRole.doctor) {
      final newDoc = Doctor(
        id: "doc_${DateTime.now().millisecondsSinceEpoch}",
        name: name,
        email: email,
        specialty: specialty ?? "General Medicine",
        imageUrl: "https://images.unsplash.com/photo-1537368910025-700350fe46c7?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3",
        bio: "Dedicated medical practitioner committed to clinical excellence and patient care.",
        rating: 5.0,
        fred: "Fred",
        reviewsCount: 0,
        availableTimeslots: ["09:00 AM", "11:00 AM", "02:00 PM", "04:00 PM"],
        experienceYears: 2,
      );
      _doctors.add(newDoc);
      _currentUser = UserSession(
        id: newDoc.id,
        name: newDoc.name,
        email: newDoc.email,
        role: UserRole.doctor,
        specialty: newDoc.specialty,
      );
    } else {
      _currentUser = UserSession(
        id: "pat_${DateTime.now().millisecondsSinceEpoch}",
        name: name,
        email: email,
        role: UserRole.patient,
      );
      // Initialize Patient Details
      _patients[_currentUser!.id] = Patient(
        id: _currentUser!.id,
        name: name,
        email: email,
        age: "25",
        gender: "Not specified",
        medicalHistory: "No prior medical history submitted.",
        files: [],
      );
    }

    _isLoading = false;
    notifyListeners();
    triggerPushNotification(
      "Registration Successful",
      "Account created. Welcome to MediLink, $name!",
    );
    return true;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  // --- Booking / Scheduling Handlers ---
  Future<bool> bookAppointment(Doctor doctor, DateTime date, String timeSlot, AppointmentType type) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1200));

    final isTelehealth = type == AppointmentType.video || type == AppointmentType.voice;

    final newAppointment = Appointment(
      id: "apt_${DateTime.now().millisecondsSinceEpoch}",
      doctorId: doctor.id,
      doctorName: doctor.name,
      doctorSpecialty: doctor.specialty,
      patientId: _currentUser?.id ?? "pat_demo",
      patientName: _currentUser?.name ?? "John Doe",
      date: date,
      timeSlot: timeSlot,
      status: AppointmentStatus.upcoming,
      type: type,
      videoRoomId: isTelehealth ? "room_${doctor.id}_${DateTime.now().millisecondsSinceEpoch}" : null,
    );

    _appointments.insert(0, newAppointment);

    if (_isCalendarSynced) {
      triggerPushNotification(
        "Calendar Synchronized",
        "Your appointment with ${doctor.name} was automatically synced to your Calendar.",
      );
    }

    _isLoading = false;
    notifyListeners();

    String formatText = "";
    if (type == AppointmentType.video) {
      formatText = "Video Call";
    } else if (type == AppointmentType.voice) {
      formatText = "Voice Call";
    } else {
      formatText = "In-Clinic Visit";
    }

    triggerPushNotification(
      "Appointment Confirmed",
      "Successfully scheduled $formatText with ${doctor.name} for ${date.year}-${date.month}-${date.day} at $timeSlot.",
    );

    // --- OBJECTIVE #5: Schedule Automated Push Reminder ---
    // Simulates an automated scheduler running in the background. It will push a notification 15 seconds after booking.
    final timer = Timer(const Duration(seconds: 15), () {
      triggerPushNotification(
        "Upcoming Appointment Reminder",
        "Your scheduled $formatText with ${doctor.name} starts in 10 minutes. Click to join securely.",
      );
    });
    _activeReminderTimers.add(timer);

    return true;
  }

  Future<void> rescheduleAppointment(String appointmentId, DateTime newDate, String newTimeSlot) async {
    final index = _appointments.indexWhere((a) => a.id == appointmentId);
    if (index != -1) {
      final apt = _appointments[index];
      _appointments[index] = apt.copyWith(date: newDate, timeSlot: newTimeSlot);
      notifyListeners();

      triggerPushNotification(
        "Appointment Rescheduled",
        "Your consultation with ${apt.doctorName} was moved to ${newDate.year}-${newDate.month}-${newDate.day} at $newTimeSlot.",
      );
    }
  }

  Future<void> cancelAppointment(String appointmentId) async {
    final index = _appointments.indexWhere((a) => a.id == appointmentId);
    if (index != -1) {
      final apt = _appointments[index];
      _appointments[index] = apt.copyWith(status: AppointmentStatus.cancelled);
      notifyListeners();

      triggerPushNotification(
        "Appointment Cancelled",
        "Your appointment with ${apt.doctorName} on ${apt.date.year}-${apt.date.month}-${apt.date.day} has been cancelled.",
      );
    }
  }

  Future<void> completeAppointment(String appointmentId) async {
    final index = _appointments.indexWhere((a) => a.id == appointmentId);
    if (index != -1) {
      final apt = _appointments[index];
      _appointments[index] = apt.copyWith(status: AppointmentStatus.completed);
      notifyListeners();

      triggerPushNotification(
        "Consultation Completed",
        "The consultation file with ${apt.doctorName} is now finalized. Notes are in your patient folder.",
      );
    }
  }

  // --- Calendar Synchronization ---
  Future<void> syncCalendar() async {
    if (_isSyncing) return;
    _isSyncing = true;
    notifyListeners();

    // Simulate synchronization delay
    await Future.delayed(const Duration(seconds: 2));

    _isCalendarSynced = true;
    _lastSyncedTime = DateTime.now();
    _isSyncing = false;
    notifyListeners();

    triggerPushNotification(
      "Calendar Synchronized",
      "Successfully synced ${_appointments.where((a) => a.status == AppointmentStatus.upcoming).length} upcoming appointments with your local calendar.",
    );
  }

  // --- Cloud Storage / File Uploads ---
  Future<void> uploadMedicalFile(String name, String size, String type) async {
    _isLoading = true;
    notifyListeners();

    // Simulate network upload
    await Future.delayed(const Duration(milliseconds: 1500));

    final newFile = MedicalFile(
      id: "f_${DateTime.now().millisecondsSinceEpoch}",
      name: name,
      size: size,
      uploadDate: "Today",
      fileType: type.toLowerCase(),
    );

    _cloudFiles.insert(0, newFile);

    // Also update patient's files if present
    final patientId = _currentUser?.id ?? "pat_demo";
    if (_patients.containsKey(patientId)) {
      final patient = _patients[patientId]!;
      _patients[patientId] = Patient(
        id: patient.id,
        name: patient.name,
        email: patient.email,
        age: patient.age,
        gender: patient.gender,
        medicalHistory: patient.medicalHistory,
        files: [newFile, ...patient.files],
      );
    }

    _isLoading = false;
    notifyListeners();

    triggerPushNotification(
      "File Uploaded",
      "\"$name\" has been securely uploaded to cloud storage.",
    );
  }

  Future<void> deleteMedicalFile(String fileId) async {
    _cloudFiles.removeWhere((f) => f.id == fileId);

    final patientId = _currentUser?.id ?? "pat_demo";
    if (_patients.containsKey(patientId)) {
      final patient = _patients[patientId]!;
      patient.files.removeWhere((f) => f.id == fileId);
    }

    notifyListeners();
    triggerPushNotification(
      "File Deleted",
      "File was removed from cloud storage.",
    );
  }

  // --- Doctor specific Patient details lookup ---
  Patient? getPatientDetails(String patientId) {
    return _patients[patientId];
  }

  void updatePatientHistory(String patientId, String newHistory) {
    if (_patients.containsKey(patientId)) {
      final old = _patients[patientId]!;
      _patients[patientId] = Patient(
        id: old.id,
        name: old.name,
        email: old.email,
        age: old.age,
        gender: old.gender,
        medicalHistory: newHistory,
        files: old.files,
      );
      notifyListeners();

      triggerPushNotification(
        "Patient File Updated",
        "Medical record updated for ${old.name}.",
      );
    }
  }

  // --- Push Notifications simulated framework ---
  void triggerPushNotification(String title, String body) {
    final notification = AppNotification(
      id: "notif_${DateTime.now().millisecondsSinceEpoch}",
      title: title,
      body: body,
      timestamp: DateTime.now(),
    );
    _notifications.insert(0, notification);
    notifyListeners();

    // Call global hook to show banner overlay if registered
    if (onPushNotification != null) {
      onPushNotification!(title, body);
    }
  }

  void markAllNotificationsAsRead() {
    for (var n in _notifications) {
      n.isRead = true;
    }
    notifyListeners();
  }

  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }



}