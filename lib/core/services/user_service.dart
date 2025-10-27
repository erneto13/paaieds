import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:paaieds/core/models/exercise.dart';
import 'package:paaieds/core/models/roadmap_section.dart';
import 'package:paaieds/core/models/test_results.dart';
import 'package:paaieds/core/models/user.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /*
  USUARIO
  */

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

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      await user.updatePassword(newPassword);

      return true;
    } catch (e) {
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

  /*
  PRUEBAS DE CONOCIMIENTO
  */

  //guarda un resultado de evaluación en el perfil del usuario
  Future<bool> saveAssessmentResult({
    required String uid,
    required String topicName,
    required Map<String, dynamic> evaluationResults,
    List<Map<String, dynamic>>? questionsData,
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

      // Agregar las preguntas si están disponibles
      if (questionsData != null && questionsData.isNotEmpty) {
        assessment['questions'] = questionsData.map((q) {
          return {
            'question': q['question'],
            'options': q['options'],
            'correctAnswer': q['correctAnswer'],
            'userAnswer': q['userAnswer'],
            'isCorrect': q['isCorrect'],
          };
        }).toList();
      }

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('assessments')
          .add(assessment);

      return true;
    } catch (e) {
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

  //eliminar un resultado de evaluación específico
  Future<bool> deleteAssessmentResult({
    required String uid,
    required String assessmentId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('assessments')
          .doc(assessmentId)
          .delete();

      return true;
    } catch (e) {
      return false;
    }
  }

  /*
  ROADMAPS
  */

  //guarda un roadmap para el usuario
  Future<String?> saveRoadmap({
    required String uid,
    required Roadmap roadmap,
  }) async {
    try {
      final roadmapData = {
        'topic': roadmap.topic,
        'level': roadmap.level,
        'initialTheta': roadmap.initialTheta,
        'sections': roadmap.sections.map((s) => s.toJson()).toList(),
        'totalSections': roadmap.totalSections,
        'completedSections': roadmap.completedSections,
        'progressPercentage': roadmap.progressPercentage,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore
          .collection('users')
          .doc(uid)
          .collection('roadmaps')
          .add(roadmapData);

      return docRef.id;
    } catch (e) {
      return null;
    }
  }

  //actualiza un roadmap existente
  Future<bool> updateRoadmap({
    required String uid,
    required String roadmapId,
    required Roadmap roadmap,
  }) async {
    try {
      final roadmapData = {
        'sections': roadmap.sections.map((s) => s.toJson()).toList(),
        'completedSections': roadmap.completedSections,
        'progressPercentage': roadmap.progressPercentage,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('roadmaps')
          .doc(roadmapId)
          .update(roadmapData);

      return true;
    } catch (e) {
      return false;
    }
  }

  //obtiene todos los roadmaps de un usuario
  Future<List<Roadmap>> getUserRoadmaps(String uid) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('roadmaps')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;

        // Convert Timestamp to DateTime string
        if (data['createdAt'] != null) {
          data['createdAt'] = (data['createdAt'] as Timestamp)
              .toDate()
              .toIso8601String();
        }

        return Roadmap.fromJson(data);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  //stream que escucha cambios en los roadmaps del usuario
  Stream<List<Roadmap>> userRoadmapsStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('roadmaps')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;

            // Convert Timestamp to DateTime string
            if (data['createdAt'] != null) {
              data['createdAt'] = (data['createdAt'] as Timestamp)
                  .toDate()
                  .toIso8601String();
            }

            return Roadmap.fromJson(data);
          }).toList();
        });
  }

  //obtiene un roadmap especifico por id
  Future<Roadmap?> getRoadmap({
    required String uid,
    required String roadmapId,
  }) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('roadmaps')
          .doc(roadmapId)
          .get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      data['id'] = doc.id;

      // Convert Timestamp to DateTime string
      if (data['createdAt'] != null) {
        data['createdAt'] = (data['createdAt'] as Timestamp)
            .toDate()
            .toIso8601String();
      }

      return Roadmap.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  //elimina un roadmap especifico
  Future<bool> deleteRoadmap({
    required String uid,
    required String roadmapId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('roadmaps')
          .doc(roadmapId)
          .delete();

      return true;
    } catch (e) {
      return false;
    }
  }

  //guarda el progreso de una seccion en un roadmap
  Future<bool> saveSectionProgress({
    required String uid,
    required String roadmapId,
    required String sectionId,
    required SectionProgress progress,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('roadmaps')
          .doc(roadmapId)
          .collection('sectionProgress')
          .doc(sectionId)
          .set(progress.toJson());

      return true;
    } catch (e) {
      return false;
    }
  }

  //obtiene el progreso de una seccion en un roadmap
  Future<SectionProgress?> getSectionProgress({
    required String uid,
    required String roadmapId,
    required String sectionId,
  }) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('roadmaps')
          .doc(roadmapId)
          .collection('sectionProgress')
          .doc(sectionId)
          .get();

      if (!doc.exists || doc.data() == null) {
        print('No se encontró progreso guardado para sección: $sectionId');
        return null;
      }

      final data = doc.data()!;

      if (!data.containsKey('sectionId') || !data.containsKey('attempts')) {
        print('Datos de progreso incompletos');
        return null;
      }

      final attemptsData = data['attempts'] as List<dynamic>? ?? [];
      final attempts = attemptsData.map((a) {
        final attemptMap = a as Map<String, dynamic>;
        return ExerciseAttempt(
          exerciseId: attemptMap['exerciseId'] ?? '',
          userAnswer: attemptMap['userAnswer'] ?? '',
          isCorrect: attemptMap['isCorrect'] ?? false,
          timestamp: DateTime.parse(attemptMap['timestamp']),
        );
      }).toList();

      return SectionProgress(
        sectionId: data['sectionId'] ?? sectionId,
        currentTheta: (data['currentTheta'] ?? 0.0).toDouble(),
        attempts: attempts,
        correctCount: data['correctCount'] ?? 0,
        totalAttempts: data['totalAttempts'] ?? 0,
        isCompleted: data['isCompleted'] ?? false,
      );
    } catch (e) {
      print('No se pudo obtener progreso (probablemente primera vez): $e');
      return null;
    }
  }

  //obtiene los ejercicios de una seccion especifica en un roadmap
  Future<List<Exercise>?> getSectionExercises({
    required String uid,
    required String roadmapId,
    required String sectionId,
  }) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('roadmaps')
          .doc(roadmapId)
          .collection('exercises')
          .doc(sectionId)
          .get();

      if (!doc.exists || doc.data() == null) {
        print(
          'No se encontraron ejercicios guardados para sección: $sectionId',
        );
        return null;
      }

      final data = doc.data()!;

      if (!data.containsKey('exercises')) {
        print('Documento existe pero no contiene ejercicios');
        return null;
      }

      final exercisesData = data['exercises'] as List<dynamic>? ?? [];

      if (exercisesData.isEmpty) {
        print('La lista de ejercicios está vacía');
        return null;
      }

      return exercisesData
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print(
        'No se pudieron obtener ejercicios (probablemente primera vez): $e',
      );
      return null;
    }
  }

  //guarda los ejercicios de una seccion especifica en un roadmap
  Future<bool> saveSectionExercises({
    required String uid,
    required String roadmapId,
    required String sectionId,
    required List<Exercise> exercises,
  }) async {
    try {
      final exercisesData = exercises.map((e) => e.toJson()).toList();

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('roadmaps')
          .doc(roadmapId)
          .collection('exercises')
          .doc(sectionId)
          .set({
            'sectionId': sectionId,
            'exercises': exercisesData,
            'createdAt': FieldValue.serverTimestamp(),
          });

      return true;
    } catch (e) {
      print('ERROR :: $e');
      return false;
    }
  }

  //actualiza una seccion especifica en un roadmap
  Future<bool> updateRoadmapSection({
    required String uid,
    required String roadmapId,
    required String sectionId,
    required bool completed,
    double? finalTheta,
  }) async {
    try {
      final roadmapDoc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('roadmaps')
          .doc(roadmapId)
          .get();

      if (!roadmapDoc.exists) return false;

      final roadmapData = roadmapDoc.data()!;
      final sections = List<Map<String, dynamic>>.from(
        roadmapData['sections'] ?? [],
      );

      bool sectionFound = false;
      for (var i = 0; i < sections.length; i++) {
        if (sections[i]['id'] == sectionId) {
          sections[i]['completed'] = completed;
          if (finalTheta != null) {
            sections[i]['finalTheta'] = finalTheta;
          }
          sectionFound = true;
          break;
        }
      }

      if (!sectionFound) return false;

      final completedCount = sections
          .where((s) => s['completed'] == true)
          .length;
      final totalSections = sections.length;
      final progressPercentage = (completedCount / totalSections) * 100;

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('roadmaps')
          .doc(roadmapId)
          .update({
            'sections': sections,
            'completedSections': completedCount,
            'progressPercentage': progressPercentage,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      return true;
    } catch (e) {
      return false;
    }
  }
}
