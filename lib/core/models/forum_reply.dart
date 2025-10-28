import 'package:cloud_firestore/cloud_firestore.dart';

class ForumReply {
  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String? authorPhotoUrl;
  final String content;
  final Timestamp createdAt;
  final Timestamp? updatedAt;

  ForumReply({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    this.authorPhotoUrl,
    required this.content,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'authorId': authorId,
      'authorName': authorName,
      if (authorPhotoUrl != null) 'authorPhotoUrl': authorPhotoUrl,
      'content': content,
      'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
  }

  factory ForumReply.fromMap(Map<String, dynamic> map, String id) {
    return ForumReply(
      id: id,
      postId: map['postId'] ?? '',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      authorPhotoUrl: map['authorPhotoUrl'],
      content: map['content'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
      updatedAt: map['updatedAt'],
    );
  }

  ForumReply copyWith({
    String? id,
    String? postId,
    String? authorId,
    String? authorName,
    String? authorPhotoUrl,
    String? content,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return ForumReply(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorPhotoUrl: authorPhotoUrl ?? this.authorPhotoUrl,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
