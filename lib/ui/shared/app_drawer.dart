import 'package:ct312h_project/ui/admin/manage_items_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../auth/auth_manager.dart';

class AppDrawerAdmin extends StatelessWidget {
  const AppDrawerAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: const Text('Admin'),
            automaticallyImplyLeading: false,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.shop),
            title: const Text('Shop'),
            onTap: (){
              Navigator.of(context).pushReplacementNamed('/main');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Manage Items'),
            onTap: (){
              Navigator.of(context).pushReplacementNamed(ManageItemsScreen.routeName);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: (){
              Navigator.pushReplacementNamed(context, '/auth');
              context.read<AuthManager>().logout();
            },
          ),
        ],
      ),
    );
  }
}

class AppDrawerGuest extends StatelessWidget {
  const AppDrawerGuest({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: const Text('Start'),
            automaticallyImplyLeading: false,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.shop),
            title: const Text('Login / Signup'),
            onTap: (){
              Navigator.of(context).pushReplacementNamed('/main');
            },
          ),
        ],
      ),
    );
  }
}

class AppDrawerCustomer extends StatelessWidget {
  final User user;

  const AppDrawerCustomer({
    super.key,
    required this.user
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
              title: Text('Hello ${user.name} !'),
              automaticallyImplyLeading: false
          ),
          user.imageUrl != '' ? _buildAvatarWidget() :
            (user.gender == 'Female' ? ListTile(
                title: Image.asset(
                  'assets/images/woman-avt.png',
                  height: 120,
                  fit: BoxFit.contain )
                ) : ListTile(
                title: Image.asset(
                  'assets/images/man-avt.png',
                  height: 120,
                  fit: BoxFit.contain,
                  )
                )
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.receipt),
            title: const Text('Order History'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/history');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/auth');
              context.read<AuthManager>().logout();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarWidget() {
    return ListTile(
        title: Container(
            width: 120,
            height: 120,
            margin: const EdgeInsets.only(top: 8, right: 8),
            child: ClipOval(
              child: Image.network(
                user.imageUrl,
                fit: BoxFit.cover,
              ),
            )
        )
    );
  }
}

