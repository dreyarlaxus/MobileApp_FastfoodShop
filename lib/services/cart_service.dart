
import 'package:pocketbase/pocketbase.dart';
import 'package:ct312h_project/services/pocketbase_client.dart';
import 'auth_service.dart';
import 'package:ct312h_project/models/order_history.dart';

class CartService {
  final String _cartCollection = 'CartItems';
  final String _orderCollection = 'Orders';
  // Add a set to track items being processed
  final Set<String> _processingItems = {};

  // Fetch CartItems from PocketBase
  Future<List<Map<String, dynamic>>> fetchCartItems(String userId) async {
    try {
      final pb = await getPocketbaseInstance();
      final records = await pb.collection(_cartCollection).getFullList(
        filter: 'userId = "$userId"',
      );

      // transfer records to JSON
      final result = records.map((record) {
        final Map<String, dynamic> json = record.toJson();

        json['cartRecordId'] = json['id'];

        if (json.containsKey('itemId')) {
          print(
              'Processing cart item: ${json['name']} with itemId: ${json['itemId']}');
        } else {
          print('Warning: Cart item ${json['id']} does not have itemId field');
        }

        return json;
      }).toList();

      return result;
    } catch (error) {
      print('Error fetching cart items from PocketBase: $error');
      return [];
    }
  }

  // Fetch Order History from PocketBase (User order history)
  Future<List<OrderHistory>> fetchOrderHistory(String userId) async {
    try {
      final pb = await getPocketbaseInstance();
      final records = await pb.collection('Orders').getFullList(
        filter: 'userId = "$userId"',
        sort: '-datetime',
      );

      // Thêm log chi tiết để debug
      if (records.isNotEmpty) {
        print('===== RAW ORDER DATA FROM POCKETBASE =====');
        print(records[0].data);
        print('========================================');
      }

      return records.map((record) {
        final data = record.data;
        data['id'] = record.id; // Ensure id is included

        return OrderHistory.fromJson(data);
      }).toList();
    } catch (error) {
      print('Error fetching order history: $error');
      return [];
    }
  }

  // Add item to cart
  Future<bool> addItemToCart(Map<String, dynamic> itemData) async {
    final String itemId = itemData['itemId'];

    // Check if this item is already being processed
    if (_processingItems.contains(itemId)) {
      print(
          'Item $itemId is already being processed, skipping duplicate request');
      return true; // Return success to avoid UI errors
    }

    try {
      // Mark this item as being processed
      _processingItems.add(itemId);

      final pb = await getPocketbaseInstance();
      final user = await AuthService().getUserFromStore();
      if (user == null) {
        throw Exception("User not authenticated");
      }

      print('Checking for existing item: $itemId for user: ${user.id}');
      final existingItems = await pb.collection(_cartCollection).getFullList(
        filter: 'userId = "${user.id}" && itemId = "$itemId"',
      );

      print('Found ${existingItems.length} existing items');

      if (existingItems.isNotEmpty) {
        // If item exists, update quantity
        final cartItemId = existingItems.first.id;
        final currentQuantity = existingItems.first.data['quantity'] ?? 0;
        final updatedQuantity = currentQuantity + itemData['quantity'];

        print(
            'Updating item $cartItemId: quantity from $currentQuantity to $updatedQuantity');

        await pb.collection(_cartCollection).update(
          cartItemId,
          body: {'quantity': updatedQuantity},
        );
      } else {
        // If item does not exist, add it to the cart
        print('Creating new cart item: ${itemData['name']}');
        await pb.collection(_cartCollection).create(body: {
          'userId': user.id,
          'itemId': itemId,
          'quantity': itemData['quantity'],
          'price': itemData['price'],
          'imageUrl': itemData['imageUrl'],
          'category': itemData['category'],
          'name': itemData['name'],
          'description': itemData['description'],
        });
      }

      return true;
    } catch (error) {
      print('Error adding item to cart: $error');
      return false;
    } finally {
      // Always remove the item from processing set when done
      _processingItems.remove(itemId);
    }
  }


  // Update item quantity in cart
  Future<bool> updateItemQuantity(String itemId, int quantity) async {
    print('Updating item quantity for itemId: $itemId to $quantity');

    try {
      final pb = await getPocketbaseInstance();
      final user = await AuthService().getUserFromStore();
      if (user == null) {
        throw Exception("User not authenticated");
      }

      // Kiểm tra xem itemId có phải là cartRecordId không
      try {
        // Thử truy vấn bằng ID bản ghi trực tiếp trước
        final cartItem = await pb.collection(_cartCollection).getOne(itemId);
        print('Found cart item directly by ID: ${cartItem.id}');

        if (quantity == 0) {
          await pb.collection(_cartCollection).delete(cartItem.id);
        } else {
          await pb.collection(_cartCollection).update(
            cartItem.id,
            body: {'quantity': quantity},
          );
        }
        return true;
      } catch (e) {
        print(
            'Not a direct cart record ID, trying filter by userId and itemId');

        // Nếu không tìm thấy bằng ID trực tiếp, thử tìm theo filter
        final existingItems = await pb.collection(_cartCollection).getFullList(
          filter: 'userId = "${user.id}" && itemId = "$itemId"',
        );

        print('Found ${existingItems.length} items matching filter');

        if (existingItems.isNotEmpty) {
          final cartItemId = existingItems.first.id;

          if (quantity == 0) {
            await pb.collection(_cartCollection).delete(cartItemId);
          } else {
            await pb.collection(_cartCollection).update(
              cartItemId,
              body: {'quantity': quantity},
            );
          }
          return true;
        } else {
          print('Item not found in cart. Need to create a new cart entry.');
          return false;
        }
      }
    } catch (error) {
      print('Error updating item quantity: $error');
      return false;
    }
  }

  // Clear cart after order is placed
  Future<void> clearCart(String userId) async {
    try {
      final pb = await getPocketbaseInstance();
      final cartItems = await pb.collection(_cartCollection).getFullList(
        filter: 'userId = "$userId"',
      );

      // Delete each item in the cart
      for (var item in cartItems) {
        await pb.collection(_cartCollection).delete(item.id!);
      }

      print('Cart cleared for user $userId');
    } catch (error) {
      print('Error clearing cart: $error');
    }
  }

  // Fetch item details (name, description, price, etc.) based on itemId
  Future<Map<String, dynamic>> getItemDetails(String itemId) async {
    print('Getting itemId: $itemId');

    try {
      final pb = await getPocketbaseInstance();

      // Thử tìm trong collection 'CartItems'
      try {
        final cartItems = await pb.collection('CartItems').getFullList(
          filter: 'itemId = "$itemId" || id = "$itemId"',
        );

        if (cartItems.isNotEmpty) {
          final cartItem = cartItems.first;
          return {
            'id': cartItem.data['itemId'] ?? itemId,
            'name': cartItem.data['name'] ?? 'Mặt hàng không xác định',
            'price': cartItem.data['price'] ?? 0.0,
            'imageUrl': cartItem.data['imageUrl'] ?? '',
            'category': cartItem.data['category'] ?? '',
            'description': cartItem.data['description'] ?? '',
          };
        }
      } catch (e) {
        print('Thử tìm trong CartItems: $e');
      }

      // Thử tìm trong collection 'items'
      try {
        final items = await pb.collection('items').getFullList(
          filter: 'id = "$itemId"',
        );

        if (items.isNotEmpty) {
          final item = items.first;
          return {
            'id': itemId,
            'name': item.data['name'] ?? 'Mặt hàng không xác định',
            'price': item.data['price'] ?? 0.0,
            'imageUrl': item.data['imageUrl'] ?? '',
            'category': item.data['category'] ?? '',
            'description': item.data['description'] ?? '',
          };
        }
      } catch (e) {
        print('Thử tìm trong items: $e');
      }

      // Thử tìm trong collection 'carts'
      try {
        final carts = await pb.collection('carts').getFullList(
          filter: 'itemId = "$itemId" || id = "$itemId"',
        );

        if (carts.isNotEmpty) {
          final cart = carts.first;
          return {
            'id': itemId,
            'name': cart.data['name'] ?? 'Mặt hàng không xác định',
            'price': cart.data['price'] ?? 0.0,
            'imageUrl': cart.data['imageUrl'] ?? '',
            'category': cart.data['category'] ?? '',
            'description': cart.data['description'] ?? '',
          };
        }
      } catch (e) {
        print('Thử tìm trong carts: $e');
      }

      print('Không tìm thấy thông tin sản phẩm cho ID: $itemId');
      return {
        'id': itemId,
        'name': 'Mặt hàng không xác định',
        'price': 0.0,
        'imageUrl': '',
        'category': '',
        'description': '',
      };
    } catch (error) {
      print('Lỗi khi lấy thông tin chi tiết: $error');
      return {
        'id': itemId,
        'name': 'Mặt hàng không xác định (Lỗi)',
        'price': 0.0,
        'imageUrl': '',
        'category': '',
        'description': '',
      };
    }
  }
  int min(int a, int b) => a < b ? a : b;
}
