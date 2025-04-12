import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/item.dart';
import 'cart_manager.dart';
import '../../services/cart_service.dart';
import '../../services/auth_service.dart';
import 'package:ct312h_project/ui/order/order_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();
  bool _isLoading = false;

  String formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  @override
  void initState() {
    super.initState();
    _refreshCart();
  }

  Future<void> _refreshCart() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final cartManager = Provider.of<CartManager>(context, listen: false);
      await cartManager.loadCart();
    } catch (e) {
      print('Error refreshing cart: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Can not load your cart'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartManager = context.watch<CartManager>();
    final cart = cartManager.cart;
    final totalPrice = cartManager.totalPrice;

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orangeAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshCart,
          ),
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.pushNamed(context, '/history');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshCart,
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.orange))
            : Column(
                children: [
                  if (cart.isEmpty)
                    Expanded(
                      child: SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 20),
                                  child: Text(
                                    "Your cart is empty. Start ordering now!",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[600]),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: Image.asset(
                                    'assets/images/buricon.png',
                                    height: 300,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (cart.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.all(10),
                        itemCount: cart.length,
                        itemBuilder: (context, index) {
                          final item = cart.keys.toList()[index];
                          final quantity = cart[item]!;

                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            margin: EdgeInsets.symmetric(vertical: 10),
                            elevation: 5,
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: item.imageUrl != null &&
                                            item.imageUrl.isNotEmpty
                                        ? Image.network(
                                            item.imageUrl,
                                            height: 80,
                                            width: 80,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Container(
                                                height: 80,
                                                width: 80,
                                                color: Colors.grey[300],
                                                child: Icon(
                                                    Icons.image_not_supported,
                                                    color: Colors.grey[600]),
                                              );
                                            },
                                          )
                                        : Container(
                                            height: 80,
                                            width: 80,
                                            color: Colors.grey[300],
                                            child: Icon(
                                                Icons.image_not_supported,
                                                color: Colors.grey[600]),
                                          ),
                                  ),
                                  SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          "${formatCurrency(item.price)} VND x $quantity",
                                          style: TextStyle(
                                              fontSize: 16, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.remove_circle_outline,
                                            color: Colors.red),
                                        onPressed: () async {
                                          final String itemId =
                                              item.cartRecordId ??
                                                  item.id ??
                                                  '';
                                          if (itemId.isEmpty) {
                                            print(
                                                'Error: Cannot decrease quantity - item ID is null');
                                            return;
                                          }

                                          if (quantity > 1) {
                                            cartManager.decrementQuantity(item);
                                            try {
                                              await _cartService
                                                  .updateItemQuantity(
                                                      itemId, quantity - 1);
                                            } catch (e) {
                                              print(
                                                  'Error decreasing quantity: $e');
                                            }
                                          } else {
                                            cartManager.removeItem(itemId);
                                            try {
                                              await _cartService
                                                  .updateItemQuantity(
                                                      itemId, 0);
                                            } catch (e) {
                                              print('Error removing item: $e');
                                            }
                                          }
                                        },
                                      ),
                                      Text('$quantity',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold)),
                                      IconButton(
                                        icon: Icon(Icons.add_circle_outline,
                                            color: Colors.green),
                                        onPressed: () async {
                                          final String cartRecordId =
                                              item.cartRecordId ??
                                                  item.id ??
                                                  '';
                                          cartManager.incrementQuantity(item);
                                          try {
                                            await _cartService
                                                .updateItemQuantity(
                                                    cartRecordId, quantity + 1);
                                          } catch (e) {
                                            print(
                                                'Error handling quantity update: $e');
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  if (cart.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "Total: ${formatCurrency(totalPrice)} VND",
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 20),
                    child: ElevatedButton(
                      onPressed: cart.isEmpty
                          ? () {
                              Navigator.pushNamed(context, '/main');
                            }
                          : () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (context, animation, secondaryAnimation) {
                                    return OrderScreen();
                                  },
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    const begin = Offset(1.0, 0.0);
                                    const end = Offset.zero;
                                    const curve = Curves.easeInOut;
                                    var tween = Tween(begin: begin, end: end)
                                        .chain(CurveTween(curve: curve));
                                    var offsetAnimation =
                                        animation.drive(tween);
                                    return SlideTransition(
                                        position: offsetAnimation,
                                        child: child);
                                  },
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            cart.isEmpty ? Colors.orange : Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 18),
                        elevation: 10,
                        shadowColor: Colors.black.withOpacity(0.3),
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text(
                        cart.isEmpty ? 'Start Ordering' : "Let's Order Now",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
