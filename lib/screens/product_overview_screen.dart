import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/cart_screen.dart';
import '../providers/cart.dart';
import '../widgets/badge.dart';
import '../widgets/products_grid.dart';
import '../widgets/app_drawer.dart';

class ProductOverviewScreen extends StatefulWidget {
  const ProductOverviewScreen({super.key});

  @override
  State<ProductOverviewScreen> createState() => _ProductOverviewScreenState();
}

enum ProductsFilter { favorites, all }

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  bool _filterFavorites = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MyShop"),
        actions: [
          Consumer<Cart>(
            builder: (_, cart, child) => Badge(
              value: cart.itemCount.toString(),
              child: child,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.shopping_cart,
              ),
              onPressed: () =>
                  Navigator.of(context).pushNamed(CartScreen.routeName),
            ),
          ),
          PopupMenuButton(
            itemBuilder: ((context) => [
                  const PopupMenuItem(
                    value: ProductsFilter.favorites,
                    child: Text('Only favorites'),
                  ),
                  const PopupMenuItem(
                    value: ProductsFilter.all,
                    child: Text('Show all'),
                  ),
                ]),
            onSelected: (value) => setState(() {
              if (value == ProductsFilter.all) {
                _filterFavorites = false;
              } else {
                _filterFavorites = true;
              }
            }),
            icon: const Icon(
              Icons.more_vert,
            ),
          )
        ],
      ),
      body: ProductsGrid(
        filterFavorites: _filterFavorites,
      ),
      drawer: const AppDrawer(),
    );
  }
}
