// // lib/services/api_service.dart
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/user.dart';
// import '../models/question.dart';
// import '../models/answer.dart';
// import '../models/vote.dart';
// import '../models/api_response.dart';

// class ApiService {
//   static const String baseUrl = 'http://10.0.2.2:8001'; // Android emulator
//   // static const String baseUrl = 'http://localhost:8001'; // iOS simulator
//   // static const String baseUrl = 'http://YOUR_SERVER_IP:8001'; // Physical device
  
//   static String? _authToken;
  
//   static Map<String, String> get _headers => {
//     'Content-Type': 'application/json',
//     if (_authToken != null) 'Authorization': 'Bearer $_authToken',
//   };

//   // Authentication endpoints
//   static Future<ApiResponse<LoginResponse>> login(String email, String password) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/auth/login'),
//         headers: {'Content-Type': 'application/x-www-form-urlencoded'},
//         body: 'email=$email&password=$password',
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         _authToken = data['access_token'];
        
//         final loginResponse = LoginResponse.fromJson(data);
//         return ApiResponse.success(loginResponse);
//       } else {
//         final error = json.decode(response.body);
//         return ApiResponse.error(error['detail'] ?? 'Login failed');
//       }
//     } catch (e) {
//       return ApiResponse.error('Network error: $e');
//     }
//   }

//   static Future<ApiResponse<User>> register(String username, String email, String password) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/auth/register'),
//         headers: _headers,
//         body: json.encode({
//           'username': username,
//           'email': email,
//           'password': password,
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final user = User.fromJson(data);
//         return ApiResponse.success(user);
//       } else {
//         final error = json.decode(response.body);
//         return ApiResponse.error(error['detail'] ?? 'Registration failed');
//       }
//     } catch (e) {
//       return ApiResponse.error('Network error: $e');
//     }
//   }

//   // Question endpoints
//   static Future<ApiResponse<List<Question>>> getQuestions({
//     int skip = 0,
//     int limit = 20,
//     String sortBy = 'created_at',
//     String order = 'desc',
//   }) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/questions?skip=$skip&limit=$limit&sort_by=$sortBy&order=$order'),
//         headers: _headers,
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> data = json.decode(response.body);
//         final questions = data.map((json) => Question.fromJson(json)).toList();
//         return ApiResponse.success(questions);
//       } else {
//         final error = json.decode(response.body);
//         return ApiResponse.error(error['detail'] ?? 'Failed to fetch questions');
//       }
//     } catch (e) {
//       return ApiResponse.error('Network error: $e');
//     }
//   }

//   static Future<ApiResponse<Question>> getQuestion(int questionId) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/questions/$questionId'),
//         headers: _headers,
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final question = Question.fromJson(data);
//         return ApiResponse.success(question);
//       } else {
//         final error = json.decode(response.body);
//         return ApiResponse.error(error['detail'] ?? 'Question not found');
//       }
//     } catch (e) {
//       return ApiResponse.error('Network error: $e');
//     }
//   }

//   static Future<ApiResponse<Question>> createQuestion(String title, String content, List<String> tags) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/questions'),
//         headers: _headers,
//         body: json.encode({
//           'title': title,
//           'content': content,
//           'tags': tags,
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final question = Question.fromJson(data);
//         return ApiResponse.success(question);
//       } else {
//         final error = json.decode(response.body);
//         return ApiResponse.error(error['detail'] ?? 'Failed to create question');
//       }
//     } catch (e) {
//       return ApiResponse.error('Network error: $e');
//     }
//   }

//   // Answer endpoints
//   static Future<ApiResponse<List<Answer>>> getAnswers(int questionId, {
//     int skip = 0,
//     int limit = 20,
//     String sortBy = 'created_at',
//     String order = 'desc',
//   }) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/questions/$questionId/answers?skip=$skip&limit=$limit&sort_by=$sortBy&order=$order'),
//         headers: _headers,
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> data = json.decode(response.body);
//         final answers = data.map((json) => Answer.fromJson(json)).toList();
//         return ApiResponse.success(answers);
//       } else {
//         final error = json.decode(response.body);
//         return ApiResponse.error(error['detail'] ?? 'Failed to fetch answers');
//       }
//     } catch (e) {
//       return ApiResponse.error('Network error: $e');
//     }
//   }

//   static Future<ApiResponse<Answer>> createAnswer(int questionId, String content) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/questions/$questionId/answers'),
//         headers: _headers,
//         body: json.encode({
//           'content': content,
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final answer = Answer.fromJson(data);
//         return ApiResponse.success(answer);
//       } else {
//         final error = json.decode(response.body);
//         return ApiResponse.error(error['detail'] ?? 'Failed to create answer');
//       }
//     } catch (e) {
//       return ApiResponse.error('Network error: $e');
//     }
//   }

//   // Voting endpoints
//   static Future<ApiResponse<Vote>> vote(int? questionId, int? answerId, int voteType) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/vote'),
//         headers: _headers,
//         body: json.encode({
//           'question_id': questionId,
//           'answer_id': answerId,
//           'vote_type': voteType,
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final vote = Vote.fromJson(data);
//         return ApiResponse.success(vote);
//       } else {
//         final error = json.decode(response.body);
//         return ApiResponse.error(error['detail'] ?? 'Failed to vote');
//       }
//     } catch (e) {
//       return ApiResponse.error('Network error: $e');
//     }
//   }

//   // Search endpoint
//   static Future<ApiResponse<SearchResponse>> search(String query, {
//     int skip = 0,
//     int limit = 20,
//   }) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/search?q=$query&skip=$skip&limit=$limit'),
//         headers: _headers,
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final searchResponse = SearchResponse.fromJson(data);
//         return ApiResponse.success(searchResponse);
//       } else {
//         final error = json.decode(response.body);
//         return ApiResponse.error(error['detail'] ?? 'Search failed');
//       }
//     } catch (e) {
//       return ApiResponse.error('Network error: $e');
//     }
//   }

//   // Health check
//   static Future<bool> checkHealth() async {
//     try {
//       final response = await http.get(Uri.parse('$baseUrl/health'));
//       return response.statusCode == 200;
//     } catch (e) {
//       return false;
//     }
//   }

//   // Clear auth token (logout)
//   static void clearAuthToken() {
//     _authToken = null;
//   }
// }

// // lib/models/user.dart
// class User {
//   final int id;
//   final String username;
//   final String email;
//   final bool isActive;
//   final bool isModerator;
//   final int reputation;
//   final DateTime createdAt;

//   User({
//     required this.id,
//     required this.username,
//     required this.email,
//     required this.isActive,
//     required this.isModerator,
//     required this.reputation,
//     required this.createdAt,
//   });

//   factory User.fromJson(Map<String, dynamic> json) {
//     return User(
//       id: json['id'],
//       username: json['username'],
//       email: json['email'],
//       isActive: json['is_active'],
//       isModerator: json['is_moderator'],
//       reputation: json['reputation'],
//       createdAt: DateTime.parse(json['created_at']),
//     );
//   }
// }

// class LoginResponse {
//   final String accessToken;
//   final String tokenType;
//   final User user;

//   LoginResponse({
//     required this.accessToken,
//     required this.tokenType,
//     required this.user,
//   });

//   factory LoginResponse.fromJson(Map<String, dynamic> json) {
//     return LoginResponse(
//       accessToken: json['access_token'],
//       tokenType: json['token_type'],
//       user: User.fromJson(json['user']),
//     );
//   }
// }

// // lib/models/question.dart
// class Question {
//   final int id;
//   final String title;
//   final String content;
//   final List<String> tags;
//   final int authorId;
//   final int upvotes;
//   final int downvotes;
//   final int answerCount;
//   final int viewCount;
//   final bool isClosed;
//   final DateTime createdAt;
//   final DateTime? updatedAt;
//   final User author;

//   Question({
//     required this.id,
//     required this.title,
//     required this.content,
//     required this.tags,
//     required this.authorId,
//     required this.upvotes,
//     required this.downvotes,
//     required this.answerCount,
//     required this.viewCount,
//     required this.isClosed,
//     required this.createdAt,
//     this.updatedAt,
//     required this.author,
//   });

//   factory Question.fromJson(Map<String, dynamic> json) {
//     return Question(
//       id: json['id'],
//       title: json['title'],
//       content: json['content'],
//       tags: List<String>.from(json['tags']),
//       authorId: json['author_id'],
//       upvotes: json['upvotes'],
//       downvotes: json['downvotes'],
//       answerCount: json['answer_count'],
//       viewCount: json['view_count'],
//       isClosed: json['is_closed'],
//       createdAt: DateTime.parse(json['created_at']),
//       updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
//       author: User.fromJson(json['author']),
//     );
//   }

//   int get netVotes => upvotes - downvotes;
// }

// // lib/models/answer.dart
// class Answer {
//   final int id;
//   final String content;
//   final int questionId;
//   final int authorId;
//   final int upvotes;
//   final int downvotes;
//   final bool isVerified;
//   final bool isAiGenerated;
//   final DateTime createdAt;
//   final DateTime? updatedAt;
//   final User author;

//   Answer({
//     required this.id,
//     required this.content,
//     required this.questionId,
//     required this.authorId,
//     required this.upvotes,
//     required this.downvotes,
//     required this.isVerified,
//     required this.isAiGenerated,
//     required this.createdAt,
//     this.updatedAt,
//     required this.author,
//   });

//   factory Answer.fromJson(Map<String, dynamic> json) {
//     return Answer(
//       id: json['id'],
//       content: json['content'],
//       questionId: json['question_id'],
//       authorId: json['author_id'],
//       upvotes: json['upvotes'],
//       downvotes: json['downvotes'],
//       isVerified: json['is_verified'],
//       isAiGenerated: json['is_ai_generated'],
//       createdAt: DateTime.parse(json['created_at']),
//       updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
//       author: User.fromJson(json['author']),
//     );
//   }

//   int get netVotes => upvotes - downvotes;
// }

// // lib/models/vote.dart
// class Vote {
//   final int id;
//   final int userId;
//   final int? questionId;
//   final int? answerId;
//   final int voteType;
//   final DateTime createdAt;

//   Vote({
//     required this.id,
//     required this.userId,
//     this.questionId,
//     this.answerId,
//     required this.voteType,
//     required this.createdAt,
//   });

//   factory Vote.fromJson(Map<String, dynamic> json) {
//     return Vote(
//       id: json['id'],
//       userId: json['user_id'],
//       questionId: json['question_id'],
//       answerId: json['answer_id'],
//       voteType: json['vote_type'],
//       createdAt: DateTime.parse(json['created_at']),
//     );
//   }
// }

// // lib/models/api_response.dart
// class ApiResponse<T> {
//   final bool success;
//   final T? data;
//   final String? error;

//   ApiResponse._(this.success, this.data, this.error);

//   factory ApiResponse.success(T data) => ApiResponse._(true, data, null);
//   factory ApiResponse.error(String error) => ApiResponse._(false, null, error);
// }

// class SearchResponse {
//   final String query;
//   final List<Question> questions;
//   final List<Answer> answers;
//   final int totalResults;

//   SearchResponse({
//     required this.query,
//     required this.questions,
//     required this.answers,
//     required this.totalResults,
//   });

//   factory SearchResponse.fromJson(Map<String, dynamic> json) {
//     return SearchResponse(
//       query: json['query'],
//       questions: (json['questions'] as List).map((q) => Question.fromJson(q)).toList(),
//       answers: (json['answers'] as List).map((a) => Answer.fromJson(a)).toList(),
//       totalResults: json['total_results'],
//     );
//   }
// }