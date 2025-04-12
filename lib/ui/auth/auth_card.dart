import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_manager.dart';

enum AuthMode { signup, login }

class AuthCard extends StatefulWidget {
  const AuthCard({
    super.key,
  });

  @override
  State<AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.login;
  final Map<String, String> _authData = {
    'email': '',
    'password': '',
    'phone': '',
    'name': '',
  };
  final _isSubmitting = ValueNotifier<bool>(false);
  final _passwordController = TextEditingController();
  bool _obscureText = true;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    _isSubmitting.value = true;

    try {
      if (_authMode == AuthMode.login) {
        await context.read<AuthManager>().login(
          _authData['email']!,
          _authData['password']!,
        );
      } else {
        await context.read<AuthManager>().signup(
          _authData['email']!,
          _authData['password']!,
          _authData['phone']!,
          _authData['name']!,
        );
        _switchAuthMode();
      }
    } catch (error) {
      log('$error');
      if (mounted) {
        // showErrorDialog(context, error.toString());
      }
    }

    _isSubmitting.value = false;
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.login) {
      setState(() {
        _authMode = AuthMode.signup;
      });
    } else {
      setState(() {
        _authMode = AuthMode.login;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.sizeOf(context);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 6.0,
      child: Container(
        height: _authMode == AuthMode.signup ? 400 : 270,
        constraints: BoxConstraints(minHeight: _authMode == AuthMode.signup ? 400 : 270),
        width: deviceSize.width * 0.85,
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                _buildAuthModeSwitchButton(),
                _buildEmailField(),
                const SizedBox(height: 10),
                _buildPasswordField(),
                if (_authMode == AuthMode.signup) ...[
                  const SizedBox(height: 10),
                  _buildNameField(),
                  const SizedBox(height: 10),
                  _buildPhoneField(),
                ],
                const SizedBox(height: 20),
                ValueListenableBuilder<bool>(
                  valueListenable: _isSubmitting,
                  builder: (context, isSubmitting, child) {
                    if (isSubmitting) {
                      return const CircularProgressIndicator();
                    }
                    return _buildSubmitButton();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthModeSwitchButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: TextButton(
            onPressed: () {
              setState(() {
                _authMode = AuthMode.login;
              });
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 0), // Giảm padding top và bottom
              textStyle: TextStyle(
                color: _authMode == AuthMode.login
                    ? Theme.of(context).colorScheme.primary
                    : Colors.black,
                fontWeight: _authMode == AuthMode.login
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            child: const Text('Login'),
          ),
        ),
        Expanded(
          child: TextButton(
            onPressed: () {
              setState(() {
                _authMode = AuthMode.signup;
              });
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 0),
              textStyle: TextStyle(
                color: _authMode == AuthMode.signup
                    ? Theme.of(context).colorScheme.primary
                    : Colors.black,
                fontWeight: _authMode == AuthMode.signup
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            child: const Text('Signup'),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submit,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 12.0),
      ),
      child: Text(_authMode == AuthMode.login ? 'LOGIN' : 'SIGN UP'),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_outlined : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
      obscureText: _obscureText,
      controller: _passwordController,
      validator: (value) {
        if (value == null || value.length < 5) {
          return 'Password is too short!';
        }
        return null;
      },
      onSaved: (value) {
        _authData['password'] = value!;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'E-Mail',
        prefixIcon: Icon(Icons.email_outlined),
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value!.isEmpty || !value.contains('@')) {
          return 'Invalid email!';
        }
        return null;
      },
      onSaved: (value) {
        _authData['email'] = value!;
      },
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Phone Number',
        prefixIcon: Icon(Icons.phone_outlined),
      ),
      keyboardType: TextInputType.phone,
      validator: (value) {
        if (value!.isEmpty || value.length < 10) {
          return 'Invalid phone number!';
        }
        return null;
      },
      onSaved: (value) {
        _authData['phone'] = value!;
      },
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Your name',
        prefixIcon: Icon(Icons.person),
      ),
      keyboardType: TextInputType.name,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please input your name';
        }
        return null;
      },
      onSaved: (value) {
        _authData['name'] = value!;
      },
    );
  }
}
