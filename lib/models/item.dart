import 'dart:io';

class Item {
  final String? id;
  final String? itemId;
  final String? cartRecordId;
  final String name;
  final String description;
  final double price;
  final String category;
  final File? featuredImage;
  final String imageUrl;

  const Item({
    this.id,
    this.itemId,
    this.cartRecordId,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    this.featuredImage,
    this.imageUrl = '',
  });

  Item copyWith({
    String? id,
    String? itemId,
    String? cartRecordId,
    String? name,
    String? description,
    double? price,
    String? category,
    File? featuredImage,
    String? imageUrl,
  }) {
    return Item(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      cartRecordId: cartRecordId ?? this.cartRecordId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      featuredImage: featuredImage ?? this.featuredImage,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  bool hasFeaturedImage() {
    return featuredImage != null || imageUrl.isNotEmpty;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemId': itemId,
      'cartRecordId': cartRecordId,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
    };
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      itemId: json['itemId'],
      cartRecordId: json['cartRecordId'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,
      category: json['category'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Item &&
        ((other.itemId != null && itemId != null && other.itemId == itemId) ||
            (other.id != null && id != null && other.id == id));
  }

  @override
  int get hashCode {
    return itemId?.hashCode ?? id.hashCode;
  }
}