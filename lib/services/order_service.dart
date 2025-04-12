import 'package:pocketbase/pocketbase.dart';
import 'package:ct312h_project/models/order.dart';
import 'package:ct312h_project/services/pocketbase_client.dart';

class OrderService {
  final String _ordersCollection = 'Orders';

  Future<void> createOrder(Order order) async {
    try {
      final pb = await getPocketbaseInstance();
      await pb.collection(_ordersCollection).create(
            body: order.toJson(),
          );
    } catch (error) {
      throw Exception('Error creating order: $error');
    }
  }
}
