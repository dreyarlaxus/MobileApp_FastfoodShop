
import 'package:flutter/material.dart';
import 'package:ct312h_project/services/cart_service.dart';
import 'package:ct312h_project/models/item.dart';
import 'package:ct312h_project/services/auth_service.dart';

class CartManager with ChangeNotifier {
  final CartService _cartService = CartService();
  final AuthService _authService = AuthService();
  Map<Item, int> _cart = {};
  double _totalPrice = 0.0;

  Map<Item, int> get cart => _cart;
  double get totalPrice => _totalPrice;

  // Phương thức loadCart mới - sẽ tự lấy userId từ AuthService
  Future<void> loadCart() async {
    try {
      // Lấy thông tin user hiện tại
      final user = await _authService.getUserFromStore();
      if (user == null) {
        print('Cannot load cart: User not authenticated');
        return;
      }

      // Gọi phương thức fetchCartItems với userId
      await fetchCartItems(user.id);
    } catch (e) {
      print('Error in loadCart: $e');
    }
  }

  // Fetch CartItems from PocketBase
  Future<void> fetchCartItems(String userId) async {
    final cartItems = await _cartService.fetchCartItems(userId);
    print('Fetched ${cartItems.length} cart items');

    _cart = {}; // Clear existing cart
    _totalPrice = 0.0;

    // Map để lưu trữ tạm thời các mục theo itemId
    final Map<String, Item> itemsMap = {};
    final Map<String, int> quantityMap = {};

    if (cartItems.isNotEmpty) {
      for (var itemData in cartItems) {
        final item = Item.fromJson(itemData);
        final itemId = item.itemId ?? item.id!;

        // Chuyển đổi quantity từ num sang int
        final int itemQuantity = itemData['quantity'] is int
            ? itemData['quantity']
            : (itemData['quantity'] as num).toInt();

        // Nếu itemId đã tồn tại, cộng dồn số lượng
        if (itemsMap.containsKey(itemId)) {
          quantityMap[itemId] = (quantityMap[itemId] ?? 0) + itemQuantity;
        } else {
          // Nếu chưa có, thêm mới
          itemsMap[itemId] = item;
          quantityMap[itemId] = itemQuantity;
        }
      }

      // Tạo giỏ hàng từ các mục đã nhóm
      for (final entry in itemsMap.entries) {
        final itemId = entry.key;
        final item = entry.value;
        final quantity = quantityMap[itemId] ?? 0;

        _cart[item] = quantity;
        _totalPrice += item.price * quantity;
      }
    }
    notifyListeners();
  }

  void addItem(Item item) async {
    print("Adding item: ${item.name} with ID: ${item.id}");

    final itemData = {
      'itemId': item.id,
      'name': item.name,
      'price': item.price,
      'quantity': 1,
      'imageUrl': item.imageUrl,
      'category': item.category,
      'description': item.description,
    };

    await _cartService.addItemToCart(itemData);

    // Cập nhật giỏ hàng local
    final existingItem = _cart.keys.firstWhere(
          (cartItem) => cartItem.id == item.id,
      orElse: () => item,
    );

    if (_cart.containsKey(existingItem)) {
      _cart[existingItem] = _cart[existingItem]! + 1;
    } else {
      _cart[item] = 1;
    }

    _totalPrice += item.price;
    notifyListeners();
  }

  void removeItem(String itemId) {
    if (itemId.isEmpty) {
      print('Cannot remove item with empty ID');
      return;
    }

    final item = _cart.keys.firstWhere(
          (cartItem) => (cartItem.id == itemId) || (cartItem.cartRecordId == itemId) || (cartItem.itemId == itemId),
      orElse: () => Item(id: '', name: '', price: 0, imageUrl: '', category: '', description: ''),
    );

    if (item.id != null && item.id!.isNotEmpty) {
      _totalPrice -= item.price * (_cart[item] ?? 0);
      _cart.remove(item);
      notifyListeners();
    }
  }

  void decrementQuantity(Item item) async {
    if (_cart.containsKey(item) && _cart[item]! > 1) {
      _cart[item] = _cart[item]! - 1;
      _totalPrice -= item.price;

      // Lấy ID phù hợp và kiểm tra null
      final String itemId = item.cartRecordId ?? item.itemId ?? item.id ?? '';
      if (itemId.isEmpty) {
        print('Error: Cannot update quantity - item ID is null');
        notifyListeners();
        return;
      }

      try {
        await _cartService.updateItemQuantity(itemId, _cart[item]!);
      } catch (e) {
        print('Error updating quantity: $e');
      }

      notifyListeners();
    }
  }

  void incrementQuantity(Item item) {
    if (_cart.containsKey(item)) {
      _cart[item] = _cart[item]! + 1;
      _totalPrice += item.price;
      notifyListeners();
    }
  }

  // Method to clear cart after an order
  Future<void> clearCart(String userId) async {
    try {
      await _cartService.clearCart(userId);
      _cart.clear();
      _totalPrice = 0.0;
      notifyListeners();
    } catch (error) {
      print('Error clearing cart: $error');
    }
  }
}
