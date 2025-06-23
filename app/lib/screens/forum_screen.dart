// lib/screens/forum_screen.dart
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../services/api_service.dart';
import '../models/question.dart';
import '../models/answer.dart';
import '../widgets/forum_post_widget.dart';
import '../widgets/answer_widget.dart';
import '../services/api_service.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({Key? key}) : super(key: key);

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  List<Question> _questions = [];
  bool _isLoading = true;
  String _error = '';
  int _currentPage = 0;
  final int _pageSize = 10;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _loadMoreQuestions();
    }
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    final response = await ApiService.getQuestions(
      skip: 0,
      limit: _pageSize,
      sortBy: 'created_at',
      order: 'desc',
    );

    if (response.success && response.data != null) {
      setState(() {
        _questions = response.data!;
        _isLoading = false;
        _currentPage = 1;
      });
    } else {
      setState(() {
        _error = response.error ?? 'Failed to load questions';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreQuestions() async {
    final response = await ApiService.getQuestions(
      skip: _currentPage * _pageSize,
      limit: _pageSize,
      sortBy: 'created_at',
      order: 'desc',
    );

    if (response.success && response.data != null) {
      setState(() {
        _questions.addAll(response.data!);
        _currentPage++;
      });
    }
  }

  Future<void> _refreshQuestions() async {
    await _loadQuestions();
  }

  void _showCreateQuestionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => CreateQuestionDialog(
        onQuestionCreated: _refreshQuestions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshQuestions,
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateQuestionDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _questions.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error.isNotEmpty && _questions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _error,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadQuestions,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_questions.isEmpty) {
      return const Center(
        child: Text(
          'No questions yet. Be the first to ask!',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 20),
      itemCount: _questions.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _questions.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final question = _questions[index];
        return Column(
          children: [
            ForumPostWidget(
              question: question,
              onTap: () => _navigateToQuestionDetail(question),
              onVote: (voteType) => _handleVote(question.id, null, voteType),
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  void _navigateToQuestionDetail(Question question) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionDetailScreen(question: question),
      ),
    );
  }

  Future<void> _handleVote(int? questionId, int? answerId, int voteType) async {
    final response = await ApiService.vote(questionId, answerId, voteType);
    
    if (response.success) {
      // Refresh to get updated vote counts
      _refreshQuestions();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(voteType == 1 ? 'Upvoted!' : 'Downvoted!'),
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.error ?? 'Failed to vote'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// Create Question Dialog
class CreateQuestionDialog extends StatefulWidget {
  final VoidCallback onQuestionCreated;

  const CreateQuestionDialog({
    Key? key,
    required this.onQuestionCreated,
  }) : super(key: key);

  @override
  State<CreateQuestionDialog> createState() => _CreateQuestionDialogState();
}

class _CreateQuestionDialogState extends State<CreateQuestionDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _createQuestion() async {
    if (_titleController.text.trim().isEmpty || _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in title and content'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    final response = await ApiService.createQuestion(
      _titleController.text.trim(),
      _contentController.text.trim(),
      tags,
    );

    if (response.success) {
      Navigator.of(context).pop();
      widget.onQuestionCreated();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Question created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.error ?? 'Failed to create question'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ask a Question',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags (comma separated)',
                border: OutlineInputBorder(),
                hintText: 'e.g., nutrition, child-care, emergency',
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _createQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Post Question'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Question Detail Screen
class QuestionDetailScreen extends StatefulWidget {
  final Question question;

  const QuestionDetailScreen({
    Key? key,
    required this.question,
  }) : super(key: key);

  @override
  State<QuestionDetailScreen> createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends State<QuestionDetailScreen> {
  List<Answer> _answers = [];
  bool _isLoading = true;
  final TextEditingController _answerController = TextEditingController();
  bool _isSubmittingAnswer = false;

  @override
  void initState() {
    super.initState();
    _loadAnswers();
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _loadAnswers() async {
    setState(() {
      _isLoading = true;
    });

    final response = await ApiService.getAnswers(
      widget.question.id,
      sortBy: 'votes',
      order: 'desc',
    );

    if (response.success && response.data != null) {
      setState(() {
        _answers = response.data!;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitAnswer() async {
    if (_answerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your answer'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmittingAnswer = true;
    });

    final response = await ApiService.createAnswer(
      widget.question.id,
      _answerController.text.trim(),
    );

    if (response.success) {
      _answerController.clear();
      _loadAnswers(); // Refresh answers
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Answer posted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.error ?? 'Failed to post answer'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      _isSubmittingAnswer = false;
    });
  }

  Future<void> _handleVote(int? questionId, int? answerId, int voteType) async {
    final response = await ApiService.vote(questionId, answerId, voteType);
    
    if (response.success) {
      // Refresh to get updated vote counts
      _loadAnswers();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(voteType == 1 ? 'Upvoted!' : 'Downvoted!'),
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.error ?? 'Failed to vote'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Question Details'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Question details
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question
                  ForumPostWidget(
                    question: widget.question,
                    showFullContent: true,
                    onVote: (voteType) => _handleVote(widget.question.id, null, voteType),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Answer section header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Answers (${_answers.length})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_answers.isNotEmpty)
                          const Icon(Icons.sort, color: Colors.grey),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Answers list
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_answers.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'No answers yet. Be the first to answer!',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _answers.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final answer = _answers[index];
                        return AnswerWidget(
                          answer: answer,
                          onVote: (voteType) => _handleVote(null, answer.id, voteType),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
          
          // Answer input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _answerController,
                  decoration: const InputDecoration(
                    hintText: 'Write your answer...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _isSubmittingAnswer ? null : _submitAnswer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: _isSubmittingAnswer
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Post Answer'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}