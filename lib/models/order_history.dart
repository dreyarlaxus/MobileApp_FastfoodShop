
class OrderHistory {
  final String orderId;
  final DateTime orderDate;
  final double totalAmount;
  final String deliveryAddress;
  final String description;
  final Map<String, dynamic> items;

  OrderHistory({
    required this.orderId,
    required this.orderDate,
    required this.totalAmount,
    required this.deliveryAddress,
    required this.description,
    required this.items,
  });

  factory OrderHistory.fromJson(Map<String, dynamic> json) {
    // In ra toàn bộ dữ liệu JSON để debug
    print('==== OrderHistory.fromJson RAW DATA ====');
    json.forEach((key, value) {
      print('$key: $value (${value.runtimeType})');
    });
    print('=======================================');

    // Xử lý đa dạng tên trường địa chỉ
    String address = 'N/A';
    if (json.containsKey('deliveryAddress') && json['deliveryAddress'] != null && json['deliveryAddress'].toString().trim().isNotEmpty) {
      address = json['deliveryAddress'].toString();
      print('Found address in deliveryAddress: "$address"');
    } else if (json.containsKey('delivery_address') && json['delivery_address'] != null && json['delivery_address'].toString().trim().isNotEmpty) {
      address = json['delivery_address'].toString();
      print('Found address in delivery_address: "$address"');
    } else if (json.containsKey('address') && json['address'] != null && json['address'].toString().trim().isNotEmpty) {
      address = json['address'].toString();
      print('Found address in address: "$address"');
    } else {
      print('No valid address found in the JSON data');
    }

    // Xử lý items dạng Map
    Map<String, dynamic> itemsMap = {};
    if (json.containsKey('items') && json['items'] != null) {
      if (json['items'] is Map) {
        itemsMap = Map<String, dynamic>.from(json['items']);
      } else if (json['items'] is String) {
        try {
          // Có thể items được lưu dưới dạng chuỗi JSON
          final String itemsString = json['items'] as String;
          print('Items stored as string: $itemsString');
        } catch (e) {
          print('Error parsing items string: $e');
        }
      }
    }

    return OrderHistory(
      orderId: json['id'] ?? '',
      orderDate: json['datetime'] != null
          ? DateTime.parse(json['datetime'].toString())
          : DateTime.now(),
      totalAmount: json['amount'] != null
          ? (json['amount'] is num ? (json['amount'] as num).toDouble() : 0.0)
          : 0.0,
      deliveryAddress: address,
      description: json['description']?.toString() ?? '',
      items: itemsMap,
    );
  }

  static int compareByDate(OrderHistory a, OrderHistory b) {
    return b.orderDate.compareTo(a.orderDate);
  }
}
