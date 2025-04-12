import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../auth/auth_manager.dart';
import '../shared/dialog_utils.dart';
import 'package:image_picker/image_picker.dart';

class UserScreen extends StatefulWidget {
  final User user;

  const UserScreen({required this.user, Key? key}) : super(key: key);

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final _editForm = GlobalKey<FormState>();
  late User _editedUser;

  Future<void> _saveForm() async {
    final isValid = _editForm.currentState!.validate() && _editedUser.hasFeaturedImage();
    if (!isValid) {
      return;
    }
    _editForm.currentState!.save();

    try {
      final authManager = context.read<AuthManager>();
      print("Saving user...");
      await authManager.updateUser(_editedUser);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User data saved successfully!')),
      );
    } catch (error) {
      if (mounted) {
        await showErrorDialog(context, 'Something went wrong: $error');
      }
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
  void initState() {
    super.initState();
    _editedUser = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _editForm,
        child: ListView(
          children: <Widget>[
            _buildAvatarSelect(),
            _buildNameField(),
            SizedBox(height: 10),
            _buildPhoneField(),
            SizedBox(height: 10),
            _buildAddressField(),
            SizedBox(height: 10),
            _buildGenderField(),
            SizedBox(height: 10),
            _buildBirthField(),
            SizedBox(height: 20),  // Adding some space before the button
            _buildSaveButton(),  // Save button added here
          ],
        ),
      ),
    );
  }

  TextFormField _buildNameField() {
    return TextFormField(
      initialValue: _editedUser.name,
      decoration: const InputDecoration(labelText: 'Name'),
      textInputAction: TextInputAction.next,
      autofocus: true,
      style: TextStyle(fontSize: 18),
      onSaved: (value) {
        if (value != null) {
          _editedUser = _editedUser.copyWith(name: value);
        }
      },
    );
  }

  TextFormField _buildPhoneField() {
    return TextFormField(
      initialValue: _editedUser.phoneNumber,
      decoration: const InputDecoration(labelText: 'Phone Number'),
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.number,
      style: TextStyle(fontSize: 18),
      validator: (value) {
        if (value == null || value.isEmpty || int.tryParse(value) == null) {
          return 'Please enter a valid phone number.';
        }
        return null;
      },
      onSaved: (value) {
        if (value != null && value.isNotEmpty) {
          _editedUser = _editedUser.copyWith(phoneNumber: value);
        }
      },
    );
  }

  TextFormField _buildAddressField() {
    return TextFormField(
      initialValue: _editedUser.address,
      decoration: const InputDecoration(labelText: 'Address'),
      keyboardType: TextInputType.multiline,
      style: TextStyle(fontSize: 18),
      onSaved: (value) {
        if (value != null) {
          _editedUser = _editedUser.copyWith(address: value);
        }
      },
    );
  }

  DropdownButtonFormField<String> _buildGenderField() {
    return DropdownButtonFormField<String>(
      value: _editedUser.gender?.isEmpty ?? true ? null : _editedUser.gender,
      decoration: const InputDecoration(labelText: 'Gender'),
      items: [
        DropdownMenuItem<String>(
          value: '',
          child: Text('Select Gender'),
        ),
        DropdownMenuItem<String>(
          value: 'Male',
          child: Text('Male'),
        ),
        DropdownMenuItem<String>(
          value: 'Female',
          child: Text('Female'),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _editedUser = _editedUser.copyWith(gender: value ?? '');
        });
      },
    );
  }





  TextFormField _buildBirthField() {
    return TextFormField(
      initialValue: _editedUser.birth != null ? _editedUser.birth!.toIso8601String().substring(0, 10) : '',
      decoration: const InputDecoration(labelText: 'Birth Date (YYYY-MM-DD)'),
      textInputAction: TextInputAction.done,
      style: TextStyle(fontSize: 18),
      onSaved: (value) {
        if (value != null && value.isNotEmpty) {
          _editedUser = _editedUser.copyWith(birth: DateTime.tryParse(value));
        }
      },
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: () {
        _saveForm();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User data saved successfully!')),
        );
      },
      child: Text('Save'),
    );
  }

  Widget _buildAvatarSelect() {
    print('Image URL: ${_editedUser.imageUrl}');
    return Column(
      children: <Widget>[
        Container(
          width: 240,
          height: 240,
          margin: const EdgeInsets.only(top: 8, right: 10),
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.grey),
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: !_editedUser.hasFeaturedImage()
                ? const Center(child: Text('No Image'))
                : FittedBox(
              child: _editedUser.featuredImage == null
                  ? Image.network(
                _editedUser.imageUrl,
                fit: BoxFit.cover,
              )
                  : Image.file(
                _editedUser.featuredImage!,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
        _buildImagePickerButton(),
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
          _editedUser = _editedUser.copyWith(
            featuredImage: File(imageFile.path),
          );

          setState(() {});
        } catch (error) {
          showErrorDialog(context, 'Something went wrong.');
        }

      },
    );
  }

}
