import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import './providers/auth.dart';
import './providers/orders.dart';
import './providers/cart.dart';
import './providers/products.dart';
import './screens/orders_screen.dart';
import './screens/cart_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/product_overview_screen.dart';
import './screens/user_products_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/auth_screen.dart';

Future main() async {
  await dotenv.load(fileName: ".env");
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  Widget authenticated(Auth auth, Widget widget) {
    return auth.isLoggedIn ? widget : AuthScreen();
  }

  @override
  Widget build(BuildContext context) {
    final primaryThemeData =
        ThemeData(primarySwatch: Colors.amber, fontFamily: 'Lato');
    final themeData = primaryThemeData.copyWith(
        colorScheme: primaryThemeData.colorScheme.copyWith(
      secondary: Colors.deepOrange,
    ));
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          update: (context, auth, previousProducts) => Products(
            auth.userId,
            auth.token,
            previousProducts?.items ?? [],
          ),
          create: (context) => Products(),
        ),
        ChangeNotifierProxyProvider<Auth, Cart>(
          update: (context, auth, previousCart) => Cart(
            auth.userId,
            auth.token,
            previousCart?.items,
          ),
          create: (context) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          update: (context, auth, previousOrders) => Orders(
            auth.userId,
            auth.token,
            previousOrders?.orders ?? [],
          ),
          create: (context) => Orders(),
        ),
      ],
      child: Consumer<Auth>(
        builder: (context, auth, child) => MaterialApp(
          title: "MyShop",
          theme: themeData,
          home: authenticated(auth, ProductOverviewScreen()),
          routes: {
            ProductOverviewScreen.routeName: (context) =>
                authenticated(auth, ProductOverviewScreen()),
            ProductDetailScreen.routeName: (context) =>
                authenticated(auth, ProductDetailScreen()),
            CartScreen.routeName: (context) =>
                authenticated(auth, CartScreen()),
            OrdersScreen.routeName: (context) =>
                authenticated(auth, OrdersScreen()),
            UserProductsScreen.routeName: (context) =>
                authenticated(auth, UserProductsScreen()),
            EditProductScreen.routeName: (context) =>
                authenticated(auth, EditProductScreen()),
            AuthScreen.routeName: (context) => AuthScreen(),
          },
        ),
      ),
    );
  }
}
