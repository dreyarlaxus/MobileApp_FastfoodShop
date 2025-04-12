import 'dart:io';

class User {
  final String id;
  final String phoneNumber;
  final String email;
  final String? name;
  final String? address;
  final String? gender;
  final DateTime? birth;
  final String role;
  final File? featuredImage;
  final String imageUrl;

  User({
    required this.id,
    required this.phoneNumber,
    required this.email,
    this.name,
    this.address,
    this.gender,
    this.birth,
    required this.role,
    this.featuredImage,
    this.imageUrl = '',
  });

  User copyWith({
    String? id,
    String? phoneNumber,
    String? email,
    String? name,
    String? address,
    String? gender,
    DateTime? birth,
    String? role,
    File? featuredImage,
    String? imageUrl,
  }) {
    return User(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      name: name ?? this.name,
      address: address ?? this.address,
      gender: gender ?? this.gender,
      birth: birth ?? this.birth,
      role: role ?? this.role,
      featuredImage: featuredImage ?? this.featuredImage,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  bool hasFeaturedImage() {
    return featuredImage != null || imageUrl.isNotEmpty;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      email: json['email'] ?? '',
      name: json['name'],
      address: json['address'],
      gender: json['gender'] ?? '',
      birth: json['birth'] != null ? DateTime.tryParse(json['birth']) : null,
      role: json['role'] ?? 'customer',
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'email': email,
      'name': name,
      'address': address,
      'gender': gender,
      'birth': birth?.toIso8601String(),
      'role': role,
    };
  }
}
