class CreateQuestionRequest {
  final String title;
  final String content;
  final List<String> tags;

  CreateQuestionRequest({
    required this.title,
    required this.content,
    required this.tags,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'tags': tags,
    };
  }

  bool get isValid => title.trim().isNotEmpty && content.trim().isNotEmpty;

  @override
  String toString() {
    return 'CreateQuestionRequest{title: $title, tags: $tags}';
  }
}