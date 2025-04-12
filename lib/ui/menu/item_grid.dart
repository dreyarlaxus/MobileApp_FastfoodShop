import 'package:flutter/material.dart';
import '../../models/item.dart';
import '../home/items_list.dart';
import 'item_detail_screen.dart';
import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String formatCurrency(num amount) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
}

class ItemGrid extends StatelessWidget {
  final List<Item> items;
  final Function(Item) onAddToCart;

  const ItemGrid({Key? key, required this.items, required this.onAddToCart})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ItemDetailScreen(item: item),
              ),
            );
          },
          child: Card(
            elevation: 8,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            shadowColor: Colors.grey.withOpacity(0.3),
            child: Stack(
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    item.imageUrl,
                    width: double.infinity,
                    height: 170,
                    fit: BoxFit.cover,
                  ),
                ),

                Positioned(
                  right: 15,
                  bottom: 18,
                  child: Material(
                    color: Colors.orange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            10)), // Square with rounded corners
                    elevation: 4,
                    child: Container(
                      width: 35,
                      height: 35,
                      child: IconButton(
                        icon: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text("${item.name} added to cart!")),
                          );
                          onAddToCart(item);
                        },
                        padding: EdgeInsets.all(6),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  bottom: 40,
                  left: 10,
                  child: Text(
                    item.name,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),

                Positioned(
                  bottom: 15,
                  left: 10,
                  child: Text(
                    '${CurrencyFormatter.formatCurrency(item.price)} VND',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
