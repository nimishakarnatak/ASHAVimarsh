class User {
  final int id;
  final String username;
  final String email;
  final bool isActive;
  final bool isModerator;
  final int reputation;
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.isActive,
    required this.isModerator,
    required this.reputation,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      isActive: json['is_active'] ?? true,
      isModerator: json['is_moderator'] ?? false,
      reputation: json['reputation'] ?? 0,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'is_active': isActive,
      'is_moderator': isModerator,
      'reputation': reputation,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'User{id: $id, username: $username, email: $email}';
  }
}