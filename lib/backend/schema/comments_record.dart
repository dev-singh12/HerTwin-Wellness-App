import 'package:cloud_firestore/cloud_firestore.dart';

/// A comment on a community post, stored under `posts/{postId}/comments`.
class CommentsRecord {
  const CommentsRecord({
    this.id = '',
    this.authorUid = '',
    this.authorName = '',
    this.authorInitials = '',
    this.content = '',
    this.createdAt,
  });

  final String id;
  final String authorUid;
  final String authorName;
  final String authorInitials;
  final String content;
  final DateTime? createdAt;

  factory CommentsRecord.fromMap(Map<String, dynamic> data, String id) =>
      CommentsRecord(
        id: (data['id'] as String?) ?? id,
        authorUid: (data['authorUid'] as String?) ?? '',
        authorName: (data['authorName'] as String?) ?? '',
        authorInitials: (data['authorInitials'] as String?) ?? '',
        content: (data['content'] as String?) ?? '',
        createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      );

  factory CommentsRecord.fromSnapshot(DocumentSnapshot snapshot) =>
      CommentsRecord.fromMap(
        (snapshot.data() as Map<String, dynamic>?) ?? <String, dynamic>{},
        snapshot.id,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'authorUid': authorUid,
        'authorName': authorName,
        'authorInitials': authorInitials,
        'content': content,
        'createdAt': createdAt == null ? null : Timestamp.fromDate(createdAt!),
      };

  CommentsRecord copyWith({
    String? id,
    String? authorUid,
    String? authorName,
    String? authorInitials,
    String? content,
    DateTime? createdAt,
  }) =>
      CommentsRecord(
        id: id ?? this.id,
        authorUid: authorUid ?? this.authorUid,
        authorName: authorName ?? this.authorName,
        authorInitials: authorInitials ?? this.authorInitials,
        content: content ?? this.content,
        createdAt: createdAt ?? this.createdAt,
      );
}
