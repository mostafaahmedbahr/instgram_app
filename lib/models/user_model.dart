class UserModel {
  final String name;
  final String email;
  final String password;
  final String uid;
  final String image;
  final List<dynamic> followers;
  final List<dynamic> following;
  final List<dynamic> stories;

  UserModel({
    required this.name,
    required this.email,
    required this.password,
    required this.uid,
    required this.image,
    required this.followers,
    required this.following,
    required this.stories,
  });

  // Convert UserModel to a map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'uid': uid,
      'image': image,
      'followers': followers,
      'following': following,
      'stories': stories,
    };
  }

  // Create UserModel from a map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      uid: map['uid'] ?? '',
      image: map['image'] ?? '',
      followers: List<dynamic>.from(map['followers'] ?? []),
      following: List<dynamic>.from(map['following'] ?? []),
      stories: List<dynamic>.from(map['stories'] ?? []),
    );
  }
}
