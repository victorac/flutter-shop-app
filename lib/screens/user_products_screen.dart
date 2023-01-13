import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/edit_product_screen.dart';
import '../providers/products.dart';
import '../widgets/user_product_item.dart';
import '../widgets/app_drawer.dart';

class UserProductsScreen extends StatelessWidget {
  static const String routeName = '/user-products';

  const UserProductsScreen({super.key});

  Future<void> _refreshItems(BuildContext context) async {
    try {
      await Provider.of<Products>(context, listen: false).getUserItems();
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: FutureBuilder(
        future: _refreshItems(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return RefreshIndicator(
              onRefresh: () => _refreshItems(context),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Consumer<Products>(
                  builder: (context, productsData, _) => ListView.builder(
                    itemCount: productsData.items.length,
                    itemBuilder: (context, index) => UserProductItem(
                      product: productsData.items[index],
                      removeItem: productsData.removeItem,
                    ),
                  ),
                ),
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      drawer: AppDrawer(),
    );
  }
}
