class UserProfile {
  final String id;
  final String name;
  final String phone;
  final DateTime dateOfBirth;
  final String gender;
  final String relation;
  final String? profileImage;

  UserProfile({
    required this.id,
    required this.name,
    required this.phone,
    required this.dateOfBirth,
    required this.gender,
    required this.relation,
    this.profileImage,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'dateOfBirth': dateOfBirth.toIso8601String(),
    'gender': gender,
    'relation': relation,
    'profileImage': profileImage,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'],
    name: json['name'],
    phone: json['phone'],
    dateOfBirth: DateTime.parse(json['dateOfBirth']),
    gender: json['gender'],
    relation: json['relation'],
    profileImage: json['profileImage'],
  );
}

class VaccinationRecord {
  final String id;
  final String profileId;
  final String vaccineName;
  final String vaccineType;
  final DateTime dateAdministered;
  final String clinicName;
  final String batchNumber;
  final DateTime? nextDueDate;
  final String status;

  VaccinationRecord({
    required this.id,
    required this.profileId,
    required this.vaccineName,
    required this.vaccineType,
    required this.dateAdministered,
    required this.clinicName,
    required this.batchNumber,
    this.nextDueDate,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'profileId': profileId,
    'vaccineName': vaccineName,
    'vaccineType': vaccineType,
    'dateAdministered': dateAdministered.toIso8601String(),
    'clinicName': clinicName,
    'batchNumber': batchNumber,
    'nextDueDate': nextDueDate?.toIso8601String(),
    'status': status,
  };

  factory VaccinationRecord.fromJson(Map<String, dynamic> json) => VaccinationRecord(
    id: json['id'],
    profileId: json['profileId'],
    vaccineName: json['vaccineName'],
    vaccineType: json['vaccineType'],
    dateAdministered: DateTime.parse(json['dateAdministered']),
    clinicName: json['clinicName'],
    batchNumber: json['batchNumber'],
    nextDueDate: json['nextDueDate'] != null ? DateTime.parse(json['nextDueDate']) : null,
    status: json['status'],
  );
}

class Clinic {
  final String id;
  final String name;
  final String address;
  final String phone;
  final double latitude;
  final double longitude;
  final String image;
  final List<String> services;
  final String rating;
  final String openHours;

  Clinic({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.latitude,
    required this.longitude,
    required this.image,
    required this.services,
    required this.rating,
    required this.openHours,
  });
}

class Appointment {
  final String id;
  final String profileId;
  final String clinicId;
  final String clinicName;
  final String vaccineName;
  final DateTime appointmentDate;
  final String timeSlot;
  final String status;
  final DateTime createdAt;

  Appointment({
    required this.id,
    required this.profileId,
    required this.clinicId,
    required this.clinicName,
    required this.vaccineName,
    required this.appointmentDate,
    required this.timeSlot,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'profileId': profileId,
    'clinicId': clinicId,
    'clinicName': clinicName,
    'vaccineName': vaccineName,
    'appointmentDate': appointmentDate.toIso8601String(),
    'timeSlot': timeSlot,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
    id: json['id'],
    profileId: json['profileId'],
    clinicId: json['clinicId'],
    clinicName: json['clinicName'],
    vaccineName: json['vaccineName'],
    appointmentDate: DateTime.parse(json['appointmentDate']),
    timeSlot: json['timeSlot'],
    status: json['status'],
    createdAt: DateTime.parse(json['createdAt']),
  );
}

class VaccineInfo {
  final String name;
  final String description;
  final String ageGroup;
  final String dosage;
  final String sideEffects;
  final String schedule;

  VaccineInfo({
    required this.name,
    required this.description,
    required this.ageGroup,
    required this.dosage,
    required this.sideEffects,
    required this.schedule,
  });
}