import 'question.dart';
import 'answer.dart';

class SearchResponse {
  final String query;
  final List<Question> questions;
  final List<Answer> answers;
  final int totalResults;

  SearchResponse({
    required this.query,
    required this.questions,
    required this.answers,
    required this.totalResults,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    return SearchResponse(
      query: json['query'] ?? '',
      questions: json['questions'] != null
          ? (json['questions'] as List).map((q) => Question.fromJson(q)).toList()
          : [],
      answers: json['answers'] != null
          ? (json['answers'] as List).map((a) => Answer.fromJson(a)).toList()
          : [],
      totalResults: json['total_results'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'questions': questions.map((q) => q.toJson()).toList(),
      'answers': answers.map((a) => a.toJson()).toList(),
      'total_results': totalResults,
    };
  }

  bool get hasResults => totalResults > 0;
  bool get hasQuestions => questions.isNotEmpty;
  bool get hasAnswers => answers.isNotEmpty;

  @override
  String toString() {
    return 'SearchResponse{query: $query, totalResults: $totalResults}';
  }
}