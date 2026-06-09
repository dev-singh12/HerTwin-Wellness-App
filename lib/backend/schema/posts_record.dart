import 'package:cloud_firestore/cloud_firestore.dart';

/// A cross-user community story/post stored in the top-level `posts`
/// collection. Likes and comments live in subcollections; [likeCount] and
/// [commentCount] are denormalized counters kept in sync via transactions.
class PostsRecord {
  const PostsRecord({
    this.id = '',
    this.authorUid = '',
    this.authorName = '',
    this.authorInitials = '',
    this.authorPhotoUrl = '',
    this.avatarBgValue,
    this.category = '',
    this.content = '',
    this.likeCount = 0,
    this.commentCount = 0,
    this.createdAt,
  });

  final String id;
  final String authorUid;
  final String authorName;
  final String authorInitials;
  final String authorPhotoUrl;

  /// Stored avatar background color as an ARGB int (nullable).
  final int? avatarBgValue;
  final String category;
  final String content;
  final int likeCount;
  final int commentCount;
  final DateTime? createdAt;

  factory PostsRecord.fromMap(Map<String, dynamic> data, String id) =>
      PostsRecord(
        id: (data['id'] as String?) ?? id,
        authorUid: (data['authorUid'] as String?) ?? '',
        authorName: (data['authorName'] as String?) ?? '',
        authorInitials: (data['authorInitials'] as String?) ?? '',
        authorPhotoUrl: (data['authorPhotoUrl'] as String?) ?? '',
        avatarBgValue: (data['avatarBgValue'] as num?)?.toInt(),
        category: (data['category'] as String?) ?? '',
        content: (data['content'] as String?) ?? '',
        likeCount: (data['likeCount'] as num?)?.toInt() ?? 0,
        commentCount: (data['commentCount'] as num?)?.toInt() ?? 0,
        createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      );

  factory PostsRecord.fromSnapshot(DocumentSnapshot snapshot) =>
      PostsRecord.fromMap(
        (snapshot.data() as Map<String, dynamic>?) ?? <String, dynamic>{},
        snapshot.id,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'authorUid': authorUid,
        'authorName': authorName,
        'authorInitials': authorInitials,
        'authorPhotoUrl': authorPhotoUrl,
        'avatarBgValue': avatarBgValue,
        'category': category,
        'content': content,
        'likeCount': likeCount,
        'commentCount': commentCount,
        'createdAt': createdAt == null ? null : Timestamp.fromDate(createdAt!),
      };

  PostsRecord copyWith({
    String? id,
    String? authorUid,
    String? authorName,
    String? authorInitials,
    String? authorPhotoUrl,
    int? avatarBgValue,
    String? category,
    String? content,
    int? likeCount,
    int? commentCount,
    DateTime? createdAt,
  }) =>
      PostsRecord(
        id: id ?? this.id,
        authorUid: authorUid ?? this.authorUid,
        authorName: authorName ?? this.authorName,
        authorInitials: authorInitials ?? this.authorInitials,
        authorPhotoUrl: authorPhotoUrl ?? this.authorPhotoUrl,
        avatarBgValue: avatarBgValue ?? this.avatarBgValue,
        category: category ?? this.category,
        content: content ?? this.content,
        likeCount: likeCount ?? this.likeCount,
        commentCount: commentCount ?? this.commentCount,
        createdAt: createdAt ?? this.createdAt,
      );
}
