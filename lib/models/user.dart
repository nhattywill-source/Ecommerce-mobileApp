class AppUser {
  final int? id;
  final String email;
  final String username;
  final String? name;
  final String? token;

  AppUser({
    this.id,
    required this.email,
    required this.username,
    this.name,
    this.token,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] != null ? (json['id'] as num).toInt() : null,
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      name: json['name'] is Map
          ? '${json['name']['firstname'] ?? ''} ${json['name']['lastname'] ?? ''}'
              .trim()
          : json['name'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'username': username,
        'name': name,
        'token': token,
      };

  AppUser copyWith({String? token}) {
    return AppUser(
      id: id,
      email: email,
      username: username,
      name: name,
      token: token ?? this.token,
    );
  }
}
