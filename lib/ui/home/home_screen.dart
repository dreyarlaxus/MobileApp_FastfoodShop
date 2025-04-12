import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/item.dart';
import 'button_category.dart';
import 'search_bar.dart';
import 'items_list.dart';
import 'package:ct312h_project/ui/home/items_manager.dart';
import 'package:ct312h_project/ui/cart/cart_manager.dart';
import 'package:ct312h_project/ui/auth/auth_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = "All";
  String searchQuery = "";
  TextEditingController searchController = TextEditingController();

  void _onSearchChanged(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  void _showAuthDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Row(
          children: const [
            Icon(Icons.login, color: Colors.orange),
            SizedBox(width: 10),
            Text('Login Required'),
          ],
        ),
        content: const Text(
          'Please login to add items to your cart',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushNamed('/auth');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Login'),
          ),
        ],
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  void _onAddToCart(Item item) async {
    final authManager = context.read<AuthManager>();

    if (!authManager.isAuth) {
      _showAuthDialog();
      return;
    }

    Provider.of<CartManager>(context, listen: false).addItem(item);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '${item.name} đã được thêm vào giỏ hàng',
            textAlign: TextAlign.center,
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height - 100,
            left: 10,
            right: 10,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SearchBarWidget(
            searchController: searchController,
            searchQuery: searchQuery,
            onSearchChanged: _onSearchChanged,
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/images/fast_food.png',
                height: 190,
                width: 380,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CategoryButton(
                    label: "All",
                    icon: Icons.list,
                    isSelected: selectedCategory == "All",
                    onTap: () => _onCategorySelected("All"),
                  ),
                  CategoryButton(
                    label: "Chicken",
                    icon: Icons.fastfood,
                    isSelected: selectedCategory == "Chicken",
                    onTap: () => _onCategorySelected("Chicken"),
                  ),
                  CategoryButton(
                    label: "Burger",
                    icon: Icons.local_pizza,
                    isSelected: selectedCategory == "Burger",
                    onTap: () => _onCategorySelected("Burger"),
                  ),
                  CategoryButton(
                    label: "Rice & Spaghetti",
                    icon: Icons.emoji_food_beverage,
                    isSelected: selectedCategory == "Rice & Spaghetti",
                    onTap: () => _onCategorySelected("Rice & Spaghetti"),
                  ),
                  CategoryButton(
                    label: "Side",
                    icon: Icons.rice_bowl,
                    isSelected: selectedCategory == "Side",
                    onTap: () => _onCategorySelected("Side"),
                  ),
                  CategoryButton(
                    label: "Drinks",
                    icon: Icons.local_drink,
                    isSelected: selectedCategory == "Drinks",
                    onTap: () => _onCategorySelected("Drinks"),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: FutureBuilder<void>(
              future: context.read<ItemsManager>().fetchItems(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.done) {
                  final filteredItems = context
                      .read<ItemsManager>()
                      .getFilteredItems(selectedCategory, searchQuery);
                  if (filteredItems.isEmpty) {
                    return const Center(child: Text('No items found'));
                  }
                  return ItemList(
                    items: filteredItems,
                    onAddToCart: _onAddToCart,
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }

  void _onCategorySelected(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
