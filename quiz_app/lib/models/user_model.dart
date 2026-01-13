import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String username;
  final String role;
  final int age;
  final String dateOfBirth;
  final String subjectArea;
  final String experienceLevel;
  final List<String> interests;
  final String? photoUrl;

  UserModel({
    required this.uid,
    required this.name,
    required this.username,
    required this.role,
    required this.age,
    required this.dateOfBirth,
    required this.subjectArea,
    required this.experienceLevel,
    required this.interests,
    this.photoUrl,
  });

  // Convert UserModel to a Map for storing in Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'username': username,
      'role': role,
      'age': age,
      'dateOfBirth': dateOfBirth,
      'subjectArea': subjectArea,
      'experienceLevel': experienceLevel,
      'interests': interests,
      'photoUrl': photoUrl,
    };
  }

  // Create a UserModel from a Firestore document
  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      username: data['username'] ?? '',
      role: data['role'] ?? '',
      age: data['age'] ?? 0,
      dateOfBirth: data['dateOfBirth'] ?? '',
      subjectArea: data['subjectArea'] ?? '',
      experienceLevel: data['experienceLevel'] ?? '',
      interests: List<String>.from(data['interests'] ?? []),
      photoUrl: data['photoUrl'],
    );
  }

  // Create a copy of UserModel with some fields updated
  UserModel copyWith({
    String? uid,
    String? name,
    String? username,
    String? role,
    int? age,
    String? dateOfBirth,
    String? subjectArea,
    String? experienceLevel,
    List<String>? interests,
    String? photoUrl,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      username: username ?? this.username,
      role: role ?? this.role,
      age: age ?? this.age,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      subjectArea: subjectArea ?? this.subjectArea,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      interests: interests ?? this.interests,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
