import 'package:cloud_firestore/cloud_firestore.dart';

enum PostAttachmentType { roadmap, test, exercise, none }

class PostAttachment {
  final PostAttachmentType type;
  final String id;
  final String title;
  final Map<String, dynamic>? metadata;

  PostAttachment({
    required this.type,
    required this.id,
    required this.title,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type.toString().split('.').last,
      'id': id,
      'title': title,
      if (metadata != null) 'metadata': metadata,
    };
  }

  factory PostAttachment.fromMap(Map<String, dynamic> map) {
    PostAttachmentType type;
    switch (map['type']) {
      case 'roadmap':
        type = PostAttachmentType.roadmap;
        break;
      case 'test':
        type = PostAttachmentType.test;
        break;
      case 'exercise':
        type = PostAttachmentType.exercise;
        break;
      default:
        type = PostAttachmentType.none;
    }

    return PostAttachment(
      type: type,
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }
}

class ForumPost {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorPhotoUrl;
  final String title;
  final String description;
  final PostAttachment? attachment;
  final int replyCount;
  final Timestamp createdAt;
  final Timestamp? updatedAt;

  ForumPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorPhotoUrl,
    required this.title,
    required this.description,
    this.attachment,
    this.replyCount = 0,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      if (authorPhotoUrl != null) 'authorPhotoUrl': authorPhotoUrl,
      'title': title,
      'description': description,
      if (attachment != null) 'attachment': attachment!.toMap(),
      'replyCount': replyCount,
      'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
  }

  factory ForumPost.fromMap(Map<String, dynamic> map, String id) {
    return ForumPost(
      id: id,
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      authorPhotoUrl: map['authorPhotoUrl'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      attachment: map['attachment'] != null
          ? PostAttachment.fromMap(map['attachment'] as Map<String, dynamic>)
          : null,
      replyCount: map['replyCount'] ?? 0,
      createdAt: map['createdAt'] ?? Timestamp.now(),
      updatedAt: map['updatedAt'],
    );
  }

  ForumPost copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorPhotoUrl,
    String? title,
    String? description,
    PostAttachment? attachment,
    int? replyCount,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return ForumPost(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorPhotoUrl: authorPhotoUrl ?? this.authorPhotoUrl,
      title: title ?? this.title,
      description: description ?? this.description,
      attachment: attachment ?? this.attachment,
      replyCount: replyCount ?? this.replyCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
