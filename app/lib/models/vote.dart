class Vote {
  final int id;
  final int userId;
  final int? questionId;
  final int? answerId;
  final int voteType;
  final DateTime createdAt;

  Vote({
    required this.id,
    required this.userId,
    this.questionId,
    this.answerId,
    required this.voteType,
    required this.createdAt,
  });

  factory Vote.fromJson(Map<String, dynamic> json) {
    return Vote(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      questionId: json['question_id'],
      answerId: json['answer_id'],
      voteType: json['vote_type'] ?? 0,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'question_id': questionId,
      'answer_id': answerId,
      'vote_type': voteType,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isUpvote => voteType == 1;
  bool get isDownvote => voteType == -1;

  String get voteTypeString {
    switch (voteType) {
      case 1:
        return 'Upvote';
      case -1:
        return 'Downvote';
      default:
        return 'Unknown';
    }
  }

  @override
  String toString() {
    return 'Vote{id: $id, userId: $userId, voteType: $voteType}';
  }
}
