import 'package:ct312h_project/ui/start_screen.dart';
import 'package:ct312h_project/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:ct312h_project/ui/home/items_manager.dart';
import 'package:ct312h_project/ui/auth/auth_manager.dart';
import 'package:ct312h_project/ui/cart/cart_manager.dart';
import 'package:ct312h_project/ui/screens.dart';
import 'package:ct312h_project/ui/order/order_manager.dart';
import 'package:ct312h_project/models/order_history.dart';
import 'package:ct312h_project/ui/splash_screen.dart';

void main() async {
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode themeMode = ThemeMode.light;
  ColorSelection colorSelected = ColorSelection.deepOrange;

  @override
  Widget build(BuildContext context) {
    final cartManager = CartManager();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => ItemsManager()),
        ChangeNotifierProvider(create: (ctx) => AuthManager(cartManager)),
        ChangeNotifierProvider(create: (ctx) => cartManager),
        ChangeNotifierProvider(create: (ctx) => OrderManager()),
      ],
      child: Consumer<AuthManager>(
        builder: (ctx, authManager, child) {
          return MaterialApp(
            title: 'AT Food',
            debugShowCheckedModeBanner: false,
            themeMode: themeMode,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: colorSelected.color,
              ),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: colorSelected.color,
                brightness: Brightness.dark,
              ),
            ),
            // Changed this part to show SplashScreen first
            home: const SplashScreen(),
            routes: {
              '/main': (context) => authManager.isAuth
                  ? SafeArea(
                      child: MainScreen(
                        changeThemeMode: changeThemeMode,
                        user: authManager.user,
                      ),
                    )
                  : const SafeArea(child: AuthScreen()),
              '/shop': (context) =>
                  MainScreen(changeThemeMode: changeThemeMode),
              '/start': (context) => StartScreen(),
              '/order': (context) => const OrderScreen(),
              '/home': (context) => const HomeScreen(),
              '/manage_items': (context) =>
                  ManageItemsScreen(changeThemeMode: changeThemeMode),
              '/history': (context) => HistoryScreen(),
              '/order_detail': (context) => OrderDetailScreen(
                    order: ModalRoute.of(context)?.settings.arguments
                        as OrderHistory,
                  ),
              '/auth': (context) => authManager.isAuth
                  ? SafeArea(
                      child: MainScreen(
                        changeThemeMode: changeThemeMode,
                        user: authManager.user,
                      ),
                    )
                  : const SafeArea(child: AuthScreen()),
            },
            onGenerateRoute: (settings) {
              if (settings.name == AddItemScreen.routeName) {
                final itemId = settings.arguments as String?;
                return MaterialPageRoute(
                  builder: (ctx) {
                    return SafeArea(
                      child: AddItemScreen(
                        itemId != null
                            ? ctx.read<ItemsManager>().findById(itemId)
                            : null,
                      ),
                    );
                  },
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }

  void changeThemeMode(bool useLightMode) {
    setState(() {
      themeMode = useLightMode ? ThemeMode.light : ThemeMode.dark;
    });
  }
}
