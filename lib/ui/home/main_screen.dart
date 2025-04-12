import 'package:ct312h_project/ui/home/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:ct312h_project/ui/screens.dart';

import '../../models/user.dart';
import '../shared/app_drawer.dart';
import '../user/user_screen.dart';

class MainScreen extends StatefulWidget {
  final User? user;
  const MainScreen({
    super.key,
    required this.changeThemeMode,
    this.user,
  });

  final Function(bool) changeThemeMode;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int indexPage = 0;

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    List<Widget> widgetList = [
      const HomeScreen(),
      const MenuScreen(),
      if (user != null) CartScreen() else const NavigateScreen(),
      if (user != null) UserScreen(user: user) else const NavigateScreen(),
    ];

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Center(
        child: widgetList[indexPage],
      ),
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
      drawer: user == null ? const AppDrawerGuest() : ( user.role == "admin" ? AppDrawerAdmin() : AppDrawerCustomer(user: user)),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            indexPage = index;
          });
        },
        currentIndex: indexPage,
        selectedItemColor: isDarkMode ? Colors.white : Colors.orange,
        unselectedItemColor: isDarkMode ? Colors.grey : Colors.black,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Menu'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'More'),
        ],
      ),
    );
  }
}
