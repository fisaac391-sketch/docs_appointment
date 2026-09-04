enum UserRole {patient,doctor}

class UserSession{
  final String id;
  final String name;
  final String email;
  final String ? specialty;
  final UserRole role;

  UserSession({
    required this.id,
    required this.name,
    required this.email,
    this.specialty,
    required this.role,
  });
}
class Doctor{
  final String id;
  final String name;
  final String email;
  final String  specialty;
  final String bio;
  final double rating;
  final String imageUrl;
  final String fred;
  final int experienceYears;
  final int reviewsCount;
  final List<String> availableTimeslots;

  Doctor({
    required this.id,
    required this.name,
    required this.email,
    required this.specialty,
    required this.bio,
    required this.rating,
    required this.imageUrl,
    required this.fred,
    required this.experienceYears,
    required this.reviewsCount,
    required this.availableTimeslots,
  });


}

class Patient{
  final String id;
  final String name;
  final String email;
  final String age;
  final String gender;
  final String medicalHistory;
  final List<MedicalFile> files;

  Patient({
    required this.id,
    required this.name,
    required this.email,
    required this.age,
    required this.gender,
    required this.medicalHistory,
    required this.files,
  });


}

class MedicalFile{
  final String id;
  final String name;
  final String size;
  final String uploadDate;
  final String fileType;

  MedicalFile({
    required this.id,
    required this.name,
    required this.size,
    required this.uploadDate,
    required this.fileType,

  });
}


class AppNotification{
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead=false,

  });
}

enum AppointmentStatus { upcoming , completed , cancelled}

enum AppointmentType {video , voice , inPeson}

class Appointment{
  final String id;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final String patientName;
  final String patientId;
  final DateTime date;
  final String timeSlot;
  final AppointmentStatus status;
  final AppointmentType type;
  final String? videoRoomId;
  final String encryptionKey;

  Appointment({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.patientName,
    required this.patientId,
    required this.date,
    required this.timeSlot,
    required this.status,
    required this.type,
    required this.videoRoomId,
    this.encryptionKey = "E2EE-256-GCM-SECURE",
  });

  Appointment copyWith({
    AppointmentStatus? status,
    DateTime? date,
    String? timeSlot,

  }) {
    return Appointment(
      id: id,
      doctorId: doctorId,
      doctorName: doctorName,
      doctorSpecialty: doctorSpecialty,
      patientName: patientName,
      patientId: patientId,
      date: date?? this.date,
      timeSlot: timeSlot?? this.timeSlot,
      status: status?? this.status,
      type: type,
      videoRoomId: videoRoomId,
      encryptionKey: encryptionKey,
    );

  }



}