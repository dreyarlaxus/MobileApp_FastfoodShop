import 'package:ct312h_project/services/item_service.dart';
import 'package:flutter/foundation.dart';
import '../../models/item.dart';

class ItemsManager with ChangeNotifier {
  final ItemsService _itemsService = ItemsService();
  List<Item> _items = [];


  int get itemCount {
    return _items.length;
  }

  List<Item> get items {
    return [..._items];
  }

  Item? findById(String id){
    try{
      return  _items.firstWhere((item)=> item.id==id);
    }catch(error){
      return null;
    }
  }

  Future<void> addItem(Item item) async{
    final newItem = await _itemsService.addItem(item);
    if (newItem != null) {
      _items.add(newItem);
      notifyListeners();
    }
  }

  Future<void> updateItem(Item item) async{
    final index = _items.indexWhere((item) => item.id == item.id );
    if (index >= 0) {
      final updatedItem = await _itemsService.updateItem(item);
      if (updatedItem != null) {
        _items[index] = updatedItem;
        notifyListeners();
      }
    }
  }

  Future<void> deleteItem(String id) async{
    final index = _items.indexWhere((item) => item.id == id);
    if (index>=0 && !await _itemsService.deleteItem(id)) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  Future<void> fetchItems() async {
    _items = await _itemsService.fetchItems();
    print('Items fetched: ${_items.length}');
    notifyListeners();
  }

  List<Item> getFilteredItems(String category, String query) {
    return _items.where((item) {
      bool matchesCategory = category == "All" || item.category == category;
      bool matchesQuery = item.name.toLowerCase().contains(query.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();
  }

}