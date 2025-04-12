import 'package:flutter/material.dart';
import '../../models/item.dart';

class ItemList extends StatelessWidget {
  final List<Item> items;
  final Function(Item) onAddToCart;

  const ItemList({Key? key, required this.items, required this.onAddToCart})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            title: Text(
              item.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${item.price} VND'),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                item.imageUrl,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 56,
                  height: 56,
                  color: Colors.grey[300],
                  child: const Icon(Icons.error),
                ),
              ),
            ),
            trailing: IconButton(
              icon: const Icon(
                Icons.add_shopping_cart,
                color: Colors.orange,
              ),
              onPressed: () => onAddToCart(item),
            ),
          ),
        );
      },
    );
  }
}
