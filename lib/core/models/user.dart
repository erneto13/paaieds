import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final String displayName;
  final Timestamp? createdAt;
  final String authProvider;
  final List<dynamic> assessments;
  final List<dynamic> roadmaps;

  UserModel({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.displayName,
    this.createdAt,
    required this.authProvider,
    List<dynamic>? assessments,
    List<dynamic>? roadmaps,
  }) : assessments = assessments ?? [],
       roadmaps = roadmaps ?? [];

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      displayName: data['displayName'] ?? '',
      createdAt: data['createdAt'] as Timestamp?,
      authProvider: data['authProvider'] ?? 'email',
      assessments: List<dynamic>.from(data['assessments'] ?? []),
      roadmaps: List<dynamic>.from(data['roadmaps'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'displayName': displayName,
      'authProvider': authProvider,
      'assessments': assessments,
      'roadmaps': roadmaps,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? firstName,
    String? lastName,
    String? displayName,
    Timestamp? createdAt,
    String? authProvider,
    List<dynamic>? assessments,
    List<dynamic>? roadmaps,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      authProvider: authProvider ?? this.authProvider,
      assessments: assessments ?? this.assessments,
      roadmaps: roadmaps ?? this.roadmaps,
    );
  }
}
