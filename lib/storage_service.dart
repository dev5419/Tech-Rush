import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vaxtrack/models.dart';

class StorageService {
  static const String _profilesKey = 'user_profiles';
  static const String _recordsKey = 'vaccination_records';
  static const String _appointmentsKey = 'appointments';
  static const String _currentUserKey = 'current_user_phone';

  static Future<void> saveProfiles(List<UserProfile> profiles) async {
    final prefs = await SharedPreferences.getInstance();
    final profilesJson = profiles.map((p) => p.toJson()).toList();
    await prefs.setString(_profilesKey, jsonEncode(profilesJson));
  }

  static Future<List<UserProfile>> getProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final profilesString = prefs.getString(_profilesKey);
    if (profilesString == null) return [];
    
    final profilesList = jsonDecode(profilesString) as List;
    return profilesList.map((json) => UserProfile.fromJson(json)).toList();
  }

  static Future<void> saveRecords(List<VaccinationRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    final recordsJson = records.map((r) => r.toJson()).toList();
    await prefs.setString(_recordsKey, jsonEncode(recordsJson));
  }

  static Future<List<VaccinationRecord>> getRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final recordsString = prefs.getString(_recordsKey);
    if (recordsString == null) return [];
    
    final recordsList = jsonDecode(recordsString) as List;
    return recordsList.map((json) => VaccinationRecord.fromJson(json)).toList();
  }

  static Future<void> saveAppointments(List<Appointment> appointments) async {
    final prefs = await SharedPreferences.getInstance();
    final appointmentsJson = appointments.map((a) => a.toJson()).toList();
    await prefs.setString(_appointmentsKey, jsonEncode(appointmentsJson));
  }

  static Future<List<Appointment>> getAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final appointmentsString = prefs.getString(_appointmentsKey);
    if (appointmentsString == null) return [];
    
    final appointmentsList = jsonDecode(appointmentsString) as List;
    return appointmentsList.map((json) => Appointment.fromJson(json)).toList();
  }

  static Future<void> saveAppointment(Appointment appointment) async {
    final appointments = await getAppointments();
    appointments.add(appointment);
    await saveAppointments(appointments);
  }

  static Future<void> setCurrentUserPhone(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, phone);
  }

  static Future<String?> getCurrentUserPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserKey);
  }

  static Future<void> initializeSampleData() async {
    // Initialize with empty data - no prefilled profiles
    // Always clear existing data to ensure clean start
    await clearAllData();
  }

  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profilesKey);
    await prefs.remove(_recordsKey);
    await prefs.remove(_appointmentsKey);
    await prefs.remove(_currentUserKey);
  }

  static Future<List<Clinic>> getClinics() async {
    // In a real app, this would fetch from a database or API
    return getSampleClinics();
  }

  static List<Clinic> getSampleClinics() => [
    Clinic(
      id: 'clinic1',
      name: 'City Health Center',
      address: '123 Main Street, Downtown',
      phone: '+1-555-0123',
      latitude: 40.7128,
      longitude: -74.0060,
      image: 'https://pixabay.com/get/g1a59db03db1e60eaa87abf2a3e8d57c393469bbd38b48c1f0e67891d455283188769e66e14b3a26fc8eeaa3c7e68af5f21f3993d033b1a166932c2ff6c4f7168_1280.jpg',
      services: ['COVID-19 Vaccines', 'Flu Shots', 'Travel Vaccines'],
      rating: '4.8',
      openHours: 'Mon-Fri: 8AM-6PM, Sat: 9AM-3PM',
    ),
    Clinic(
      id: 'clinic2',
      name: 'Regional Medical Center',
      address: '456 Oak Avenue, Midtown',
      phone: '+1-555-0456',
      latitude: 40.7589,
      longitude: -73.9851,
      image: 'https://pixabay.com/get/ge0b4babc70787b50f2f236ecf3b963666d58061d47c8e2085fd2fa34d0abbf0eed10f3013543b88368363d7a517ced8fc845e6bbbd918330cd36cc8f4099eba3_1280.jpg',
      services: ['All Routine Vaccines', 'Pediatric Care', 'Adult Immunizations'],
      rating: '4.6',
      openHours: 'Mon-Sun: 7AM-8PM',
    ),
    Clinic(
      id: 'clinic3',
      name: 'Pediatric Care Center',
      address: '789 Pine Street, Riverside',
      phone: '+1-555-0789',
      latitude: 40.7505,
      longitude: -73.9934,
      image: 'https://pixabay.com/get/g085c21ae84831df2bad923132994fe987d49a450d896b623b7a4879d02da699db5fdb6c4aec340f653ad858181998d8d26bfa3b2c345c56c175e033f89fc6a9e_1280.jpg',
      services: ['Child Vaccines', 'School Immunizations', 'Baby Wellness'],
      rating: '4.9',
      openHours: 'Mon-Fri: 8AM-5PM, Sat: 9AM-1PM',
    ),
  ];

  static List<VaccineInfo> getVaccineInfo() => [
    VaccineInfo(
      name: 'COVID-19 mRNA',
      description: 'Protects against COVID-19 infection and severe illness',
      ageGroup: '6 months and older',
      dosage: '2-dose primary series + boosters as recommended',
      sideEffects: 'Mild pain at injection site, fatigue, headache',
      schedule: 'Primary series with boosters every 6-12 months',
    ),
    VaccineInfo(
      name: 'Influenza (Flu)',
      description: 'Annual protection against seasonal flu strains',
      ageGroup: '6 months and older',
      dosage: 'Single annual dose',
      sideEffects: 'Soreness at injection site, low-grade fever',
      schedule: 'Once yearly, preferably before flu season',
    ),
    VaccineInfo(
      name: 'MMR',
      description: 'Protects against Measles, Mumps, and Rubella',
      ageGroup: '12 months and older',
      dosage: '2-dose series',
      sideEffects: 'Fever, mild rash, swollen glands',
      schedule: 'First dose at 12-15 months, second at 4-6 years',
    ),
  ];
}