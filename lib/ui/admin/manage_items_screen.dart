import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/item.dart';
import '../home/app_bar_widget.dart';
import '../home/items_manager.dart';
import '../shared/app_drawer.dart';
import 'add_item_screen.dart';
import 'manage_items_list.dart';

class ManageItemsScreen extends StatefulWidget {
  static const routeName = '/manage_items';

  const ManageItemsScreen({
    super.key,
    required this.changeThemeMode
  });
  final Function(bool) changeThemeMode;
  @override
  State<ManageItemsScreen> createState() => _ManageItemsScreenState();
}

class _ManageItemsScreenState extends State<ManageItemsScreen> {
  String selectedCategory = "All";
  List<Item> cart = [];
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Fast Food App",
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          backgroundColor: isDarkMode ? Colors.black : Colors.orange,
          actions: [
            ThemeButton(
              changeThemeMode: widget.changeThemeMode,
            ),
          ],
        ),
        drawer: AppDrawerAdmin(),
      body: Column(
        children: [
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
                  final filteredItems = context.read<ItemsManager>().getFilteredItems(selectedCategory, "");

                  if (filteredItems.isEmpty) {
                    return const Center(child: Text('No items found'));
                  }

                  return ManageItemsList(
                    items: filteredItems,
                  );
                }

                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 150,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(AddItemScreen.routeName);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode ? Colors.white : Colors.orange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    minimumSize: Size(150, 40),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add,
                        color: isDarkMode ? Colors.black : Colors.white,
                        size: 24,
                      ),
                      Text(
                        "Add Item",
                        style: TextStyle(
                            color: isDarkMode ? Colors.black : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 40)
            ],
          ),
          SizedBox(height: 30),
        ],
      )
    );
  }
}


