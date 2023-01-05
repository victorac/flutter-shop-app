import 'package:flutter/material.dart';

import '../screens/user_products_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/orders_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(padding: EdgeInsets.zero, children: [
        DrawerHeader(
          decoration:
              BoxDecoration(color: Theme.of(context).colorScheme.primary),
          child: const Text(
            'Happy shopping!',
            style: TextStyle(
              // color: Colors.white,
              fontSize: 24,
            ),
          ),
        ),
        ListTile(
          onTap: () => Navigator.of(context).pushReplacementNamed('/'),
          leading: const Icon(Icons.shop),
          title: const Text('Shop'),
        ),
        ListTile(
          onTap: () =>
              Navigator.of(context).pushReplacementNamed(CartScreen.routeName),
          leading: const Icon(Icons.shopping_cart),
          title: const Text('Cart'),
        ),
        ListTile(
          onTap: () => Navigator.of(context)
              .pushReplacementNamed(OrdersScreen.routeName),
          leading: const Icon(Icons.receipt),
          title: const Text('Orders'),
        ),
        ListTile(
          onTap: () => Navigator.of(context)
              .pushReplacementNamed(UserProductsScreen.routeName),
          leading: const Icon(Icons.category),
          title: const Text('Products'),
        ),
      ]),
    );
  }
}
