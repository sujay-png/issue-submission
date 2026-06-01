import 'package:cloud_firestore/cloud_firestore.dart';

class TechnicianModel {
  final String id; // Unique ID for Firestore document
  final String fullname;
  final String department;
  final String techstatus;
  final String speciality;
  final dynamic createdAt;

  TechnicianModel({
    required this.id,
    required this.fullname,
    required this.department,
    required this.techstatus,
    required this.speciality,
    this.createdAt,
  });

  // Converts the TechnicianModel object into a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullname': fullname,
      'department': department,
      'techstatus': techstatus,
      'speciality': speciality,
      // Uses the passed timestamp or falls back to server time
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  // Creates a TechnicianModel object from a Firestore document
  factory TechnicianModel.fromMap(Map<String, dynamic> map, String documentId) {
    return TechnicianModel(
      id: documentId,
      fullname: map['fullname'] ?? '',
      department: map['department'] ?? '',
      speciality: map['speciality'] ?? '',
      techstatus: map['techstatus'] ?? 'AVAILABLE',
      createdAt: map['createdAt'],
    );
  }
}