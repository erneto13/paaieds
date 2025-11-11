import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:paaieds/core/models/forum_post.dart';
import 'package:paaieds/core/models/forum_reply.dart';
import 'package:paaieds/core/services/forum_service.dart';

class ForumProvider extends ChangeNotifier {
  final ForumService _forumService = ForumService();

  List<ForumPost> _posts = [];
  List<ForumReply> _currentPostReplies = [];
  ForumPost? _currentPost;

  bool _isLoading = false;
  String? _errorMessage;

  StreamSubscription<List<ForumPost>>? _postsSubscription;
  StreamSubscription<List<ForumReply>>? _repliesSubscription;

  List<ForumPost> get posts => _posts;
  List<ForumReply> get currentPostReplies => _currentPostReplies;
  ForumPost? get currentPost => _currentPost;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  //cargar posts
  void loadPosts() {
    _isLoading = true;
    notifyListeners();

    _postsSubscription?.cancel();

    _postsSubscription = _forumService.getPostsStream().listen(
      (posts) {
        _posts = posts;
        _isLoading = false;
        _errorMessage = null;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      },
      onError: (error) {
        _errorMessage = 'Error al cargar posts: $error';
        _posts = [];
        _isLoading = false;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      },
    );
  }

  //crear post
  Future<bool> createPost({
    required String authorId,
    required String authorName,
    String? authorPhotoUrl,
    required String title,
    required String description,
    PostAttachment? attachment,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final post = ForumPost(
        id: '',
        authorId: authorId,
        authorName: authorName,
        authorPhotoUrl: authorPhotoUrl,
        title: title,
        description: description,
        attachment: attachment,
        createdAt: Timestamp.now(),
      );

      final postId = await _forumService.createPost(post);

      _isLoading = false;
      notifyListeners();

      return postId != null;
    } catch (e) {
      _errorMessage = 'Error al crear post: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  //cargar un post especifico y sus respuestas
  Future<bool> loadPost(String postId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final post = await _forumService.getPost(postId);

      if (post == null) {
        _errorMessage = 'Post no encontrado';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _currentPost = post;

      //cancel previous subscription if exists
      await _repliesSubscription?.cancel();

      //load replies with stream
      _repliesSubscription = _forumService
          .getRepliesStream(postId)
          .listen(
            (replies) {
              _currentPostReplies = replies;
              //use post frame callback to avoid setState during build
              WidgetsBinding.instance.addPostFrameCallback((_) {
                notifyListeners();
              });
            },
            onError: (error) {
              _errorMessage = 'Error al cargar respuestas: $error';
              WidgetsBinding.instance.addPostFrameCallback((_) {
                notifyListeners();
              });
            },
          );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al cargar post: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  //crear respuesta
  Future<bool> createReply({
    required String postId,
    required String authorId,
    required String authorName,
    String? authorPhotoUrl,
    required String content,
  }) async {
    try {
      final reply = ForumReply(
        id: '',
        postId: postId,
        authorId: authorId,
        authorName: authorName,
        authorPhotoUrl: authorPhotoUrl,
        content: content,
        createdAt: Timestamp.now(),
      );

      final replyId = await _forumService.createReply(reply);
      return replyId != null;
    } catch (e) {
      _errorMessage = 'Error al crear respuesta: $e';
      notifyListeners();
      return false;
    }
  }

  //eliminar post
  Future<bool> deletePost(String postId) async {
    try {
      final success = await _forumService.deletePost(postId);

      if (success) {
        //use post frame callback to avoid setState during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _posts.removeWhere((p) => p.id == postId);
          notifyListeners();
        });
      }

      return success;
    } catch (e) {
      _errorMessage = 'Error al eliminar post: $e';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return false;
    }
  }

  //eliminar respuesta
  Future<bool> deleteReply(String replyId, String postId) async {
    try {
      final success = await _forumService.deleteReply(replyId, postId);

      if (success) {
        //use post frame callback to avoid setState during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _currentPostReplies.removeWhere((r) => r.id == replyId);
          notifyListeners();
        });
      }

      return success;
    } catch (e) {
      _errorMessage = 'Error al eliminar respuesta: $e';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return false;
    }
  }

  void clearCurrentPost() {
    _currentPost = null;
    _currentPostReplies = [];
    _repliesSubscription?.cancel();
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _postsSubscription?.cancel();
    _repliesSubscription?.cancel();
    super.dispose();
  }
}
