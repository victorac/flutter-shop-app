import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/auth.dart';

import '../screens/edit_product_screen.dart';
import '../providers/products.dart';
import '../widgets/user_product_item.dart';
import '../widgets/app_drawer.dart';

class UserProductsScreen extends StatelessWidget {
  static const String routeName = '/user-products';
  String? _uid;
  String? _token;

  UserProductsScreen({super.key});

  Future<void> _refreshItems(BuildContext context) async {
    try {
      await Provider.of<Products>(context, listen: false)
          .getItems(_uid as String, _token as String);
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    _uid = Provider.of<Auth>(context).userId;
    _token = Provider.of<Auth>(context).token;
    final productsData = Provider.of<Products>(context);
    final removeItem = Provider.of<Products>(context).removeItem;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your products'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshItems(context),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
            itemCount: productsData.items.length,
            itemBuilder: (context, index) => UserProductItem(
              product: productsData.items[index],
              removeItem: removeItem,
            ),
          ),
        ),
      ),
      drawer: AppDrawer(),
    );
  }
}
