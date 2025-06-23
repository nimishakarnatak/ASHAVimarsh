class CreateAnswerRequest {
  final String content;

  CreateAnswerRequest({
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'content': content,
    };
  }

  bool get isValid => content.trim().isNotEmpty;

  @override
  String toString() {
    return 'CreateAnswerRequest{content: ${content.substring(0, content.length > 50 ? 50 : content.length)}...}';
  }
}
