import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'order_manager.dart';
import 'package:ct312h_project/ui/cart/cart_manager.dart';
import 'package:ct312h_project/services/auth_service.dart';
import 'package:ct312h_project/services/cart_service.dart';
import 'package:ct312h_project/ui/auth/auth_manager.dart';
import 'package:ct312h_project/ui/shared/confirm_dialog.dart';

class OrderScreen extends StatefulWidget {
  static const routeName = '/order';

  const OrderScreen({super.key});

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  final CartService _cartService = CartService();
  final AuthService _authService = AuthService();

  String formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      print('=== Start loading user data ===');

      final userFromService = await _authService.getUserFromStore();
      print('User data from PocketBase: ${userFromService?.toJson()}');

      if (userFromService != null) {
        if (mounted) {
          setState(() {
            if (userFromService.address != null &&
                userFromService.address!.isNotEmpty) {
              _addressController.text = userFromService.address!;
              print('Address set from PocketBase: ${userFromService.address}');
            }
            if (userFromService.phoneNumber.isNotEmpty) {
              _phoneNumberController.text = userFromService.phoneNumber;
              print(
                  'Phone number set from PocketBase: ${userFromService.phoneNumber}');
            }
          });
        }
      } else {
        final authManager = Provider.of<AuthManager>(context, listen: false);
        final currentUser = authManager.user;
        print('User from AuthManager: ${currentUser?.toJson()}');

        if (currentUser != null && mounted) {
          setState(() {
            if (currentUser.address != null &&
                currentUser.address!.isNotEmpty) {
              _addressController.text = currentUser.address!;
              print('Address set from AuthManager: ${currentUser.address}');
            }
            if (currentUser.phoneNumber.isNotEmpty) {
              _phoneNumberController.text = currentUser.phoneNumber;
              print(
                  'Phone number set from AuthManager: ${currentUser.phoneNumber}');
            }
          });
        }
      }

      print('=== End loading user data ===');
    } catch (error) {
      print('Error in _loadUserData: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not load user data')),
        );
      }
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _descriptionController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartManager = Provider.of<CartManager>(context);
    final cart = cartManager.cart;
    final totalPrice = cartManager.totalPrice;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Order", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.orange,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: cart.length,
              itemBuilder: (context, index) {
                final item = cart.keys.toList()[index];
                final quantity = cart[item]!;
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            item.imageUrl,
                            height: 80,
                            width: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "${formatCurrency(item.price)} VND x $quantity",
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
            child: TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                hintText: 'Enter your phone number',
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
            child: TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Delivery Address',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                hintText: 'Enter your delivery address',
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
            child: TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Note',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Total: ${formatCurrency(totalPrice)} VND",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            child: ElevatedButton(
              onPressed: () async {
                final orderManager =
                    Provider.of<OrderManager>(context, listen: false);
                final address = _addressController.text;
                final description = _descriptionController.text;
                final phoneNumber = _phoneNumberController.text;

                if (address.isEmpty ||
                    description.isEmpty ||
                    phoneNumber.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in all fields'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                // Show confirmation dialog
                final confirmOrder = await showConfirmDialog(
                  context,
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      children: [
                        const TextSpan(
                          text: 'Order Details',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const TextSpan(text: '\n\n'),
                        const TextSpan(
                          text: 'Delivery Address: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: '$address\n'),
                        const TextSpan(
                          text: 'Phone Number: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: '$phoneNumber\n'),
                        const TextSpan(
                          text: 'Note: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: '$description\n\n'),
                        const TextSpan(
                          text: 'Total Amount: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: '${formatCurrency(totalPrice)} VND\n\n',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const TextSpan(
                          text: 'Do you want to place this order?',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                );

                if (confirmOrder ?? false) {
                  final user = await AuthService().getUserFromStore();

                  await orderManager.createOrder(
                    userId: user!.id,
                    totalAmount: totalPrice,
                    address: address,
                    description: description,
                    cart: cart,
                    phoneNumber: phoneNumber,
                  );

                  await cartManager.clearCart(user.id);
                  await _cartService.clearCart(user.id);

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Order placed successfully!'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    Navigator.pushNamed(context, '/main');
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 18),
                elevation: 10,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                "Place Order",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
