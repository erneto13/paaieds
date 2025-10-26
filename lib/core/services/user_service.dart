import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:paaieds/core/models/test_results.dart';
import 'package:paaieds/core/models/user.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //obtener el usuario actual
  Future<UserModel?> getCurrentUser() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      final doc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!doc.exists) return null;

      return UserModel.fromFirestore(doc);
    } catch (e) {
      print('Error al obtener usuario: $e');
      return null;
    }
  }

  //actualizar perfil de usuario
  Future<UserModel?> updateUserProfile({
    required String uid,
    String? firstName,
    String? lastName,
    File? profileImage,
  }) async {
    try {
      final Map<String, dynamic> updates = {};

      if (firstName != null && firstName.isNotEmpty) {
        updates['firstName'] = firstName;
      }

      if (lastName != null && lastName.isNotEmpty) {
        updates['lastName'] = lastName;
      }

      if (firstName != null || lastName != null) {
        final userDoc = await _firestore.collection('users').doc(uid).get();
        final currentData = userDoc.data();

        final newFirstName = firstName ?? currentData?['firstName'] ?? '';
        final newLastName = lastName ?? currentData?['lastName'] ?? '';

        updates['displayName'] = '$newFirstName $newLastName'.trim();
      }

      if (profileImage != null) {
        final imageUrl = await _uploadProfileImage(uid, profileImage);
        if (imageUrl != null) {
          updates['photoURL'] = imageUrl;
        }
      }

      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(uid).update(updates);

        if (updates.containsKey('displayName')) {
          await _auth.currentUser?.updateDisplayName(updates['displayName']);
        }

        if (updates.containsKey('photoURL')) {
          await _auth.currentUser?.updatePhotoURL(updates['photoURL']);
        }
      }

      final updatedDoc = await _firestore.collection('users').doc(uid).get();
      return UserModel.fromFirestore(updatedDoc);
    } catch (e) {
      print('Error al actualizar perfil: $e');
      rethrow;
    }
  }

  //sube la imagen de perfil a Firebase Storage
  Future<String?> _uploadProfileImage(String uid, File imageFile) async {
    try {
      final ref = _storage.ref().child('profile_images').child('$uid.jpg');

      final uploadTask = await ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'uploadedBy': uid,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error al subir imagen: $e');
      return null;
    }
  }

  //elimina la imagen de perfil del usuario
  Future<bool> deleteProfileImage(String uid) async {
    try {
      final ref = _storage.ref().child('profile_images').child('$uid.jpg');
      await ref.delete();

      await _firestore.collection('users').doc(uid).update({
        'photoURL': FieldValue.delete(),
      });

      await _auth.currentUser?.updatePhotoURL(null);

      return true;
    } catch (e) {
      print('Error al eliminar imagen: $e');
      return false;
    }
  }

  //cambia la contraseña del usuario
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Reautenticar al usuario
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Cambiar contraseña
      await user.updatePassword(newPassword);

      return true;
    } catch (e) {
      print('Error al cambiar contraseña: $e');
      return false;
    }
  }

  //guarda un resultado de evaluación en el perfil del usuario
  Future<bool> saveAssessmentResult({
    required String uid,
    required String topicName,
    required Map<String, dynamic> evaluationResults,
  }) async {
    try {
      final assessment = {
        'topic': topicName,
        'level': evaluationResults['level'],
        'theta': evaluationResults['theta'],
        'percentage': evaluationResults['percentage'],
        'correctAnswers': evaluationResults['correctAnswers'],
        'totalQuestions': evaluationResults['totalQuestions'],
        'completedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('assessments')
          .add(assessment);

      return true;
    } catch (e) {
      print('Error al guardar evaluación: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getUserAssessments(String uid) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('assessments')
          .orderBy('completedAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error al obtener evaluaciones: $e');
      return [];
    }
  }

  Stream<List<TestResult>> userTestHistoryStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('assessments')
        .orderBy('completedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return TestResult.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  //guarda un roadmap generado en el perfil del usuario
  Future<bool> saveRoadmap({
    required String uid,
    required String topicName,
    required Map<String, dynamic> roadmapData,
  }) async {
    try {
      final roadmap = {
        'topic': topicName,
        'level': roadmapData['level'],
        'roadmapContent': roadmapData['content'],
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(uid).update({
        'roadmaps': FieldValue.arrayUnion([roadmap]),
      });

      return true;
    } catch (e) {
      print('Error al guardar roadmap: $e');
      return false;
    }
  }

  //stream para escuchar cambios en el perfil del usuario
  Stream<UserModel?> userStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return UserModel.fromFirestore(snapshot);
    });
  }
}
