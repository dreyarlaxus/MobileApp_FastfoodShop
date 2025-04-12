import 'package:flutter/material.dart';

class ThemeButton extends StatelessWidget {
  const ThemeButton({
    super.key,
    required this.changeThemeMode,
  });

  final Function(bool) changeThemeMode;

  @override
  Widget build(BuildContext context) {
    bool isBright = Theme.of(context).brightness == Brightness.light;
    return IconButton(
      icon: Icon(
        isBright ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
      ),
      onPressed: () {
        changeThemeMode(!isBright);
      },
    );
  }
}
