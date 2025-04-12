import 'package:ct312h_project/models/item.dart';

class Order {
  final String? id;
  final String userId;
  final double amount;
  final String deliveryAddress;
  final String description;
  final Map<Item, int> items;
  final DateTime datetime;
  final String phoneNumber;

  Order({
    this.id,
    required this.userId,
    required this.amount,
    required this.deliveryAddress,
    required this.description,
    required this.items,
    required this.datetime,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    final Map<String, int> itemsMap = {};

    for (final entry in items.entries) {
      final Item item = entry.key;
      final String key = item.itemId ?? item.id ?? '';
      if (key.isNotEmpty) {
        itemsMap[key] = entry.value;
      }
    }

    return {
      'userId': userId,
      'amount': amount,
      'delivery_address': deliveryAddress,
      'description': description,
      'items': itemsMap,
      'datetime': datetime.toIso8601String(),
      'phoneNumber': phoneNumber,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    var itemsData = json['items'] as Map<String, dynamic>;

    Map<Item, int> itemsMap = {};
    itemsData.forEach((key, value) {
      itemsMap[Item.fromJson(json[key])] = value;
    });

    return Order(
      id: json['id'],
      userId: json['userId'],
      amount: json['amount'],
      deliveryAddress: json['delivery_address'] ?? '',
      description: json['description'],
      items: itemsMap,
      datetime: DateTime.parse(json['datetime']),
      phoneNumber: json['phoneNumber'] ?? '',
    );
  }
}
