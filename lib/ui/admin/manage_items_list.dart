import 'package:ct312h_project/ui/admin/add_item_screen.dart';
import 'package:ct312h_project/ui/home/items_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/item.dart';
import '../home/items_list.dart';
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

class ManageItemsList extends StatelessWidget {
  final List<Item> items;

  const ManageItemsList({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          title: Text(
            item.name,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('${CurrencyFormatter.formatCurrency(item.price)} VND'),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(item.imageUrl, fit: BoxFit.cover),
          ),
          trailing: SizedBox(
            width: 100,
            child: Row(
              children: <Widget>[
                EditItemButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      AddItemScreen.routeName,
                      arguments: item.id,
                    );
                  },
                ),
                DeleteItemButton(
                  onPressed: () {
                    // context.read<ItemsManager>().deleteItem(item.id!);
                    // ScaffoldMessenger.of(context)
                    //   ..hideCurrentSnackBar()
                    //   ..showSnackBar(
                    //     const SnackBar(
                    //       content: Text(
                    //         'Product deleted',
                    //         textAlign: TextAlign.center,
                    //       ),
                    //     ), );
                    deleteConfirmDialog(context, item);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class DeleteItemButton extends StatelessWidget {
  const DeleteItemButton({super.key, this.onPressed});

  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(
        Icons.delete_forever,
        size: 26,
      ),
      color: Colors.red,
    );
  }
}

class EditItemButton extends StatelessWidget {
  const EditItemButton({super.key, this.onPressed});

  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(
        Icons.edit_outlined,
        size: 26,
      ),
      color: Colors.blue, // Blue color for edit icon
    );
  }
}

Future<bool?> deleteConfirmDialog(BuildContext context, Item item) {
  return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
              icon: const Icon(Icons.warning),
              title: const Text('Do you want to delete this item?'),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ActionButton(
                        actionText: 'No',
                        onPressed: () {
                          Navigator.of(ctx).pop(false);
                        },
                      ),
                    ),
                    Expanded(
                        child: ActionButton(
                            actionText: 'Yes',
                            onPressed: () {
                              context.read<ItemsManager>().deleteItem(item.id!);
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Product deleted',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                );
                              Navigator.of(ctx).pop(false);
                            }))
                  ],
                )
              ]));
}

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    this.actionText,
    this.onPressed,
  });

  final String? actionText;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        actionText ?? 'okay',
        style: Theme.of(context).textTheme.titleMedium!.copyWith(
            color: Theme.of(context).colorScheme.primary, fontSize: 24),
      ),
    );
  }
}
