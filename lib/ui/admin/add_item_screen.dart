import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/item.dart';
import '../home/items_manager.dart';
import '../shared/dialog_utils.dart';

class AddItemScreen extends StatefulWidget {
  static const routeName = '/add_item';

  AddItemScreen(Item? item, {super.key}) {
    if (item == null) {
      this.item = Item(
        id: null,
        name: '',
        price: 0,
        description: '',
        imageUrl: '',
        category: '',
      );
    } else {
      this.item = item;
    }
  }

  late final Item item;

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _editForm = GlobalKey<FormState>();
  late Item _editedItem;

  @override
  void initState() {
    _editedItem = widget.item;
    super.initState();
  }

  Future<void> _saveForm() async {
    final isValid = _editForm.currentState!.validate() &&
        _editedItem.hasFeaturedImage();
    if (!isValid) {
      return;
    }
    _editForm.currentState!.save();

    try {
      final productsManager = context.read<ItemsManager>();
      if (_editedItem.id != null) {
        await productsManager.updateItem(_editedItem);
      } else {
        await productsManager.addItem(_editedItem);
      }
    } catch (error) {
      if (mounted) {
        await showErrorDialog(context, 'Something went wrong.');
      }
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> showErrorDialog(BuildContext context, String message) {
    return showDialog(
      context: context,
      builder: (ctx) =>
          AlertDialog(
            icon: const Icon(Icons.error),
            title: const Text('An Error Occurred!'),
            content: Text(message),
            actions: <Widget>[
              ActionButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.id == null ? 'Add Item' : 'Edit Item'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _editForm,
          child: ListView(
            children: <Widget>[
              _buildNameField(),
              SizedBox(height: 10),
              _buildPriceField(),
              SizedBox(height: 10),
              _buildCategoryField(),
              SizedBox(height: 10),
              _buildDescriptionField(),
              SizedBox(height: 20),
              _buildProductPreview(),
              SizedBox(height: 20),
              _buildImagePickerButton(),
              SizedBox(height: 20),
              _buildSaveButton()
            ],
          ),
        ),
      ),
    );
  }

  TextFormField _buildNameField() {
    return TextFormField(
      initialValue: _editedItem.name,
      decoration: const InputDecoration(labelText: 'Name'),
      textInputAction: TextInputAction.next,
      autofocus: true,
      style: TextStyle(fontSize: 18), // Increased font size
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please provide a value.';
        }
        return null;
      },
      onSaved: (value) {
        _editedItem = _editedItem.copyWith(name: value);
      },
    );
  }

  TextFormField _buildPriceField() {
    return TextFormField(
      initialValue: _editedItem.price.toString(),
      decoration: const InputDecoration(labelText: 'Price'),
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.number,
      style: TextStyle(fontSize: 18), // Increased font size
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please enter a price.';
        }
        if (double.tryParse(value) == null) {
          return 'Please enter a valid number.';
        }
        if (double.parse(value) <= 0) {
          return 'Please enter a number greater than zero.';
        }
        return null;
      },
      onSaved: (value) {
        _editedItem = _editedItem.copyWith(price: double.parse(value!));
      },
    );
  }

  DropdownButtonFormField<String> _buildCategoryField() {
    return DropdownButtonFormField<String>(
      value: _editedItem.category.isEmpty ? '' : _editedItem.category,
      decoration: const InputDecoration(labelText: 'Category'),
      items: [
        '',
        'Chicken',
        'Burger',
        'Rice & Spaghetti',
        'Side',
        'Drinks',
      ]
          .map((category) => DropdownMenuItem<String>(
        value: category,
        child: Text(category),
      ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _editedItem = _editedItem.copyWith(category: value ?? '');
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a category.';
        }
        return null;
      },
      style: TextStyle(fontSize: 18, color: Colors.black),
    );
  }


  TextFormField _buildDescriptionField() {
    return TextFormField(
      initialValue: _editedItem.description,
      decoration: const InputDecoration(labelText: 'Description'),
      maxLines: 2,
      keyboardType: TextInputType.multiline,
      style: TextStyle(fontSize: 18),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please enter a description.';
        }
        if (value.length < 10) {
          return 'Should be at least 10 characters long.';
        }
        return null;
      },
      onSaved: (value) {
        _editedItem = _editedItem.copyWith(description: value);
      },
    );
  }

  Widget _buildProductPreview() {
    return Column(
      children: <Widget>[
        Container(
          width: 300,
          height: 300,
          margin: const EdgeInsets.only(top: 8, right: 10),
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.grey),
          ),
          child: !_editedItem.hasFeaturedImage()
              ? const Center(child: Text('No Image'))
              : FittedBox(
            child: _editedItem.featuredImage == null
                ? Image.network(
              _editedItem.imageUrl,
              fit: BoxFit.cover,
            )
                : Image.file(
              _editedItem.featuredImage!,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }

  TextButton _buildImagePickerButton() {
    return TextButton.icon(
      icon: const Icon(Icons.image, size: 26),
      label: const Text('Pick Image'),
      onPressed: () async {
        final imagePicker = ImagePicker();
        try {
          final imageFile = await imagePicker.pickImage(source: ImageSource.gallery);
          if (imageFile == null) {
            return;
          }
          _editedItem = _editedItem.copyWith(
            featuredImage: File(imageFile.path),
          );

          setState(() {});
        } catch (error) {
          if (mounted) {
            showErrorDialog(context, 'Something went wrong.');
          }
        }
      },
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: () { _saveForm; },
      child: Text('Save'),
    );
  }
}
