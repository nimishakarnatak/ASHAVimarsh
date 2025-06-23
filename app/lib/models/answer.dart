import 'user.dart';

class Answer {
  final int id;
  final String content;
  final int questionId;
  final int authorId;
  final int upvotes;
  final int downvotes;
  final bool isVerified;
  final bool isAiGenerated;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final User author;

  Answer({
    required this.id,
    required this.content,
    required this.questionId,
    required this.authorId,
    required this.upvotes,
    required this.downvotes,
    required this.isVerified,
    required this.isAiGenerated,
    required this.createdAt,
    this.updatedAt,
    required this.author,
  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      id: json['id'] ?? 0,
      content: json['content'] ?? '',
      questionId: json['question_id'] ?? 0,
      authorId: json['author_id'] ?? 0,
      upvotes: json['upvotes'] ?? 0,
      downvotes: json['downvotes'] ?? 0,
      isVerified: json['is_verified'] ?? false,
      isAiGenerated: json['is_ai_generated'] ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'])
          : null,
      author: User.fromJson(json['author'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'question_id': questionId,
      'author_id': authorId,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'is_verified': isVerified,
      'is_ai_generated': isAiGenerated,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'author': author.toJson(),
    };
  }

  int get netVotes => upvotes - downvotes;

  String get statusText {
    if (isVerified) return 'Verified';
    if (isAiGenerated) return 'AI Generated';
    return 'Community Answer';
  }

  @override
  String toString() {
    return 'Answer{id: $id, questionId: $questionId, author: ${author.username}}';
  }
}