import 'user.dart';

class Question {
  final int id;
  final String title;
  final String content;
  final List<String> tags;
  final int authorId;
  final int upvotes;
  final int downvotes;
  final int answerCount;
  final int viewCount;
  final bool isClosed;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final User author;

  Question({
    required this.id,
    required this.title,
    required this.content,
    required this.tags,
    required this.authorId,
    required this.upvotes,
    required this.downvotes,
    required this.answerCount,
    required this.viewCount,
    required this.isClosed,
    required this.createdAt,
    this.updatedAt,
    required this.author,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      tags: json['tags'] != null 
          ? List<String>.from(json['tags'])
          : [],
      authorId: json['author_id'] ?? 0,
      upvotes: json['upvotes'] ?? 0,
      downvotes: json['downvotes'] ?? 0,
      answerCount: json['answer_count'] ?? 0,
      viewCount: json['view_count'] ?? 0,
      isClosed: json['is_closed'] ?? false,
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
      'title': title,
      'content': content,
      'tags': tags,
      'author_id': authorId,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'answer_count': answerCount,
      'view_count': viewCount,
      'is_closed': isClosed,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'author': author.toJson(),
    };
  }

  int get netVotes => upvotes - downvotes;

  bool get hasAnswers => answerCount > 0;

  String get tagsString => tags.join(', ');

  @override
  String toString() {
    return 'Question{id: $id, title: $title, author: ${author.username}}';
  }
}