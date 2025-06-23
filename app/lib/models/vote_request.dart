class VoteRequest {
  final int? questionId;
  final int? answerId;
  final int voteType;

  VoteRequest({
    this.questionId,
    this.answerId,
    required this.voteType,
  });

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'answer_id': answerId,
      'vote_type': voteType,
    };
  }

  bool get isValid => (questionId != null || answerId != null) && 
                     (voteType == 1 || voteType == -1);

  bool get isQuestionVote => questionId != null;
  bool get isAnswerVote => answerId != null;

  @override
  String toString() {
    return 'VoteRequest{questionId: $questionId, answerId: $answerId, voteType: $voteType}';
  }
}