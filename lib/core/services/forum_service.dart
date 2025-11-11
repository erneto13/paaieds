import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paaieds/core/models/forum_post.dart';
import 'package:paaieds/core/models/forum_reply.dart';

class ForumService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //crear un nuevo post
  Future<String?> createPost(ForumPost post) async {
    try {
      final docRef = await _firestore
          .collection('forum_posts')
          .add(post.toMap());
      return docRef.id;
    } catch (e) {
      return null;
    }
  }

  //obtener todos los posts
  Stream<List<ForumPost>> getPostsStream() {
    return _firestore
        .collection('forum_posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ForumPost.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  //obtener un post especifico
  Future<ForumPost?> getPost(String postId) async {
    try {
      final doc = await _firestore.collection('forum_posts').doc(postId).get();

      if (!doc.exists) return null;

      return ForumPost.fromMap(doc.data()!, doc.id);
    } catch (e) {
      return null;
    }
  }

  //actualizar un post
  Future<bool> updatePost(String postId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('forum_posts').doc(postId).update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  //eliminar un post
  Future<bool> deletePost(String postId) async {
    try {
      //eliminar todas las respuestas primero
      final repliesSnapshot = await _firestore
          .collection('forum_replies')
          .where('postId', isEqualTo: postId)
          .get();

      for (final doc in repliesSnapshot.docs) {
        await doc.reference.delete();
      }

      //eliminar el post
      await _firestore.collection('forum_posts').doc(postId).delete();

      return true;
    } catch (e) {
      return false;
    }
  }

  //crear una respuesta
  Future<String?> createReply(ForumReply reply) async {
    try {
      final docRef = await _firestore
          .collection('forum_replies')
          .add(reply.toMap());

      //incrementar el contador de respuestas
      await _firestore.collection('forum_posts').doc(reply.postId).update({
        'replyCount': FieldValue.increment(1),
      });

      return docRef.id;
    } catch (e) {
      print(e);
      return null;
    }
  }

  //obtener respuestas de un post
  Stream<List<ForumReply>> getRepliesStream(String postId) {
    return _firestore
        .collection('forum_replies')
        .where('postId', isEqualTo: postId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ForumReply.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  //eliminar una respuesta
  Future<bool> deleteReply(String replyId, String postId) async {
    try {
      await _firestore.collection('forum_replies').doc(replyId).delete();

      //decrementar el contador de respuestas
      await _firestore.collection('forum_posts').doc(postId).update({
        'replyCount': FieldValue.increment(-1),
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  //obtener posts del usuario
  Stream<List<ForumPost>> getUserPostsStream(String userId) {
    return _firestore
        .collection('forum_posts')
        .where('authorId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ForumPost.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }
}
