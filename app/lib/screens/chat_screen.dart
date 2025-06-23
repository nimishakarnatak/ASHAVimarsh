import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/colors.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';
import 'dart:io';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Store conversation messages
  List<ChatMessage> messages = [];
  bool isLoading = false;
  List<File> selectedFiles = [];
  
  // API Configuration - Update these with your actual values
  static const String baseUrl = 'http://34.58.74.142:8000';
  static const String appName = 'rag';
  static const String userId = 'u_123';
  
  // Session management
  String? sessionId;
  bool sessionCreated = false;

  @override
  void initState() {
    super.initState();
    // Generate unique session ID
    sessionId = 's_${DateTime.now().millisecondsSinceEpoch}';
    
    // Add initial example message
    messages.add(ChatMessage(
      text: 'Hi! I am ASHA Vimarsh, your virtual assistant. How can I help you today?',
      isUser: false,
      timestamp: DateTime.now(),
    ));
    
    // // Add example response
    // _addExampleResponse();
  }

  void _addExampleResponse() {
    final response = ChatResponse(
      message: '''ASHA Vimarsh
Key signs of measles include:
• High fever (often >104 F/40C)
• Red, blotchy rash starting on face
• Koplik's spots (tiny white spots inside mouth)
• Red, watery eyes
• Cough, runny nose''',
      searchStats: '23 other ASHAs searched about measles this month',
      citations: [
        'ASHA Module 7, Page 43',
        'Ministry Guidelines (2023)'
      ],
      relatedQuestions: [
        'How is measles prevented?',
        'What is the incubation period for measles?',
        'When is a child no longer contagious?'
      ],
    );
    
    messages.add(ChatMessage(
      text: '',
      isUser: false,
      timestamp: DateTime.now(),
      response: response,
    ));
  }

  void _handleFilesSelected(List<File> files) {
    setState(() {
      selectedFiles = files;
    });
  }


  Future<void> _handleSend() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();
    _messageController.clear();

    // Add user message
    setState(() {
      messages.add(ChatMessage(
        text: userMessage,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      isLoading = true;
    });

    // Scroll to bottom
    _scrollToBottom();

    try {
      // Create session if not already created
      if (!sessionCreated) {
        await _createSession();
      }
      
      // Send query to API
      final response = await _sendQuery(userMessage);
      
      // Add bot response
      setState(() {
        messages.add(ChatMessage(
          text: '',
          isUser: false,
          timestamp: DateTime.now(),
          response: response,
        ));
        isLoading = false;
      });
    } catch (e) {
      // Handle error
      setState(() {
        messages.add(ChatMessage(
          text: 'Sorry, I encountered an error: ${e.toString()}',
          isUser: false,
          timestamp: DateTime.now(),
          isError: true,
        ));
        isLoading = false;
      });
      print('Error in _handleSend: $e');
    }

    _scrollToBottom();
  }

  Future<void> _createSession() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/apps/$appName/users/$userId/sessions/$sessionId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'state': {
            'user_type': 'ASHA',
            'session_start': DateTime.now().toIso8601String(),
          }
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        sessionCreated = true;
        print('Session created successfully: $sessionId');
      } else {
        throw Exception('Failed to create session. Status: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      print('Error creating session: $e');
      throw Exception('Failed to create session: $e');
    }
  }

  Future<ChatResponse> _sendQuery(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/run'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'appName': appName,
          'userId': userId,
          'sessionId': sessionId,
          'newMessage': {
            'role': 'user',
            'parts': [
              {
                'text': message,
              }
            ]
          }
        }),
      );

      print(response);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Extract the response text from the API response
        String responseText = '';

        print(data);

        int content_idx = data.length - 1;

        responseText = data[content_idx]['content']['parts'][0]['text'];
        
        return _parseAPIResponse(responseText);
      } else {
        throw Exception('API call failed. Status: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      print('Error in _sendQuery: $e');
      throw Exception('Failed to send query: $e');
    }
  }

  ChatResponse _parseAPIResponse(String responseText) {
    // Parse the response text to extract different components
    String mainMessage = '';
    String searchStats = '';
    List<String> citations = [];
    List<String> relatedQuestions = [];

    // Split response by sections
    final lines = responseText.split('\n');
    String currentSection = '';
    
    for (String line in lines) {
      line = line.trim();
      print(line.toLowerCase());
      if (line.isEmpty) continue;
      
      if (line.toLowerCase().contains('citations:') || 
          line.toLowerCase().contains('references:')) {
        currentSection = 'citations';
        continue;
      } else if (line.toLowerCase().contains('related questions:')) {
        currentSection = 'related';
        continue;
      } else if (line.toLowerCase().contains('other ashas searched')) {
        searchStats = line;
        continue;
      }
      
      switch (currentSection) {
        case 'citations':
          // if (line.startsWith(RegExp(r'\d+\)'))) {
            // Remove the number prefix
            citations.add(line.replaceFirst(RegExp(r'^\d+\)\s*'), ''));
          // }
          break;
        case 'related':
          // if (line.startsWith(RegExp(r'\d+\)'))) {
            // Remove the number prefix
            relatedQuestions.add(line.replaceFirst(RegExp(r'^\d+\)\s*'), ''));
          // }
          break;
        default:
          if (!line.toLowerCase().contains('citations:') && 
              !line.toLowerCase().contains('related questions:')) {
            mainMessage += '$line\n';
          }
      }
    }

    // Clean up main message
    mainMessage = mainMessage.trim();
    if (mainMessage.startsWith('[ask_rag_agent]:')) {
      mainMessage = mainMessage.replaceFirst('[ask_rag_agent]:', '').trim();
    }

    return ChatResponse(
      message: mainMessage.isNotEmpty ? mainMessage : 'ASHA Vimarsh\n\nI understand your question. Let me provide you with relevant information.',
      searchStats: searchStats.isNotEmpty ? searchStats : null,
      citations: citations,
      relatedQuestions: relatedQuestions,
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: AppColors.lightGrey,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(14),
              itemCount: messages.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length && isLoading) {
                  return _buildLoadingIndicator();
                }
                
                final message = messages[index];
                
                if (message.isUser) {
                  return ChatBubble(
                    message: message.text,
                    isUser: true,
                  );
                } else {
                  return Column(
                    children: [
                      if (message.response?.searchStats != null)
                        _buildSearchStatistics(message.response!.searchStats!),
                      if (message.response != null)
                        _buildBotResponse(message.response!)
                      else if (message.isError)
                        ChatBubble(
                          message: message.text,
                          isUser: false,
                        )
                      else
                        ChatBubble(
                          message: message.text,
                          isUser: false,
                        ),
                      if (message.response?.relatedQuestions.isNotEmpty == true)
                        _buildRelatedQuestions(message.response!.relatedQuestions),
                    ],
                  );
                }
              },
            ),
          ),
        ),
        ChatInput(
          controller: _messageController,
          onSend: _handleSend,
          onFilesSelected: _handleFilesSelected,
          // enabled: !isLoading,
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      child: const Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text('ASHA Vimarsh is thinking...'),
        ],
      ),
    );
  }

  Widget _buildSearchStatistics(String stats) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 52),
      decoration: BoxDecoration(
        color: AppColors.greenLight,
        border: Border.all(color: AppColors.green),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        stats,
        style: const TextStyle(
          fontSize: 10,
          color: AppColors.green,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildBotResponse(ChatResponse response) {
    return ChatBubble(
      message: response.message,
      extraContent: response.citations.isNotEmpty ? _buildSourceInfo(response.citations) : null,
    );
  }

  Widget _buildSourceInfo(List<String> citations) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.blueLight,
        border: Border.all(color: AppColors.blue),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/info_icon.png',
                width: 16,
                height: 16,
              ),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  'Sources: \n ${citations.join('\n')}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.blue,
                  ),
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 7),
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF9FCFFF),
              border: Border.all(color: AppColors.blue),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Text(
              'View Source',
              style: TextStyle(fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedQuestions(List<String> questions) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 20),
          padding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 70,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFD9D9D9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            'Related Questions',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        ...questions.map((question) => _buildQuestionItem(question)).toList(),
      ],
    );
  }

  Widget _buildQuestionItem(String question) {
    return GestureDetector(
      onTap: () {
        _messageController.text = question;
        _handleSend();
      },
      child: Container(
        margin: const EdgeInsets.only(top: 7),
        padding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 12,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(question),
      ),
    );
  }
}

// Data models
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final ChatResponse? response;
  final bool isError;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.response,
    this.isError = false,
  });
}

class ChatResponse {
  final String message;
  final String? searchStats;
  final List<String> citations;
  final List<String> relatedQuestions;

  ChatResponse({
    required this.message,
    this.searchStats,
    required this.citations,
    required this.relatedQuestions,
  });
}