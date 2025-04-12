import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';

import '../models/item.dart';
import 'pocketbase_client.dart';

class ItemsService {
  String _getFeaturedImageUrl(PocketBase pb, RecordModel itemModel) {
    final featuredImageName = itemModel.getStringValue('featuredImage');
    return pb.files.getUrl(itemModel, featuredImageName).toString();
  }

  Future<Item?> addItem(Item item) async {
    try {
      final pb = await getPocketbaseInstance();
      final itemModel = await pb.collection('Items').create(
        body: {
          ...item.toJson(),
        },
        files: item.featuredImage != null
            ? [
          http.MultipartFile.fromBytes(
            'featuredImage',
            await item.featuredImage!.readAsBytes(),
            filename: item.featuredImage!.uri.pathSegments.last,
          ),
        ]
            : [],
      );

      return item.copyWith(
        id: itemModel.id,
        imageUrl: _getFeaturedImageUrl(pb, itemModel),
      );
    } catch (error) {
      print('Error while adding product: $error');
      return null;
    }
  }

  Future<List<Item>> fetchItems() async {
    final List<Item> items = [];

    try {
      final pb = await getPocketbaseInstance();
      final itemModels = await pb.collection('Items').getFullList();

      for (final itemModel in itemModels) {
        items.add(
          Item.fromJson(
            itemModel.toJson()
              ..addAll({'imageUrl': _getFeaturedImageUrl(pb, itemModel)}),
          ),
        );
      }
      return items;
    } catch (error) {
      print('Error fetching products: $error');
      return items;
    }
  }
  // Future<List<Item>> fetchItems() async {
  //   List<Item> items = [];
  //   try {
  //     final pb = await getPocketbaseInstance(); // Ensure this is defined in your app
  //     final itemModels = await pb.collection('Items').getFullList();  // Assuming 'Items' is the collection name
  //
  //     for (var itemModel in itemModels) {
  //       items.add(Item.fromJson(itemModel.toJson())); // Map the fetched data into Item objects
  //     }
  //     return items;
  //   } catch (error) {
  //     print('Error fetching items: $error');
  //     return items;
  //   }
  // }

  Future<Item?> updateItem(Item item) async {
    try {
      final pb = await getPocketbaseInstance();

      final itemModel = await pb.collection('Items').update(
        item.id!,
        body: item.toJson(),
        files: item.featuredImage != null
            ? [
          http.MultipartFile.fromBytes(
            'featuredImage',
            await item.featuredImage!.readAsBytes(),
            filename: item.featuredImage!.uri.pathSegments.last,
          ),
        ]
            : [],
      );

      return item.copyWith(
        imageUrl: item.featuredImage != null
            ? _getFeaturedImageUrl(pb, itemModel)
            : item.imageUrl,
      );
    } catch (error) {
      return null;
    }
  }

  Future<bool> deleteItem(String id) async {
    try {
      final pb = await getPocketbaseInstance();
      await pb.collection('Items').delete(id);

      return true;
    } catch (error) {
      return false;
    }
  }

}