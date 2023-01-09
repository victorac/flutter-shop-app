import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';
import '../providers/product.dart';
import '../screens/product_detail_screen.dart';

class ProductItem extends StatelessWidget {
  ProductItem({super.key});

  @override
  Widget build(BuildContext context) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final product = Provider.of<Product>(context, listen: false);
    final cartData = Provider.of<Cart>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          leading: Consumer<Product>(
            builder: (_, product, __) => IconButton(
              onPressed: () async {
                try {
                  await product.toggleIsFavorite();
                } catch (error) {
                  scaffoldMessenger.clearSnackBars();
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Error updating favorite',
                          textAlign: TextAlign.center),
                    ),
                  );
                }
              },
              color: Theme.of(context).colorScheme.secondary,
              icon: Icon(
                product.isFavorite ? Icons.favorite : Icons.favorite_border,
              ),
            ),
          ),
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
            onPressed: () {
              cartData.addItem(
                product.id,
                product.title,
                product.price,
              );
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Added item to cart!'),
                  action: SnackBarAction(
                    label: "UNDO",
                    onPressed: () => cartData.removeSingleItem(product.id),
                  ),
                ),
              );
            },
            color: Theme.of(context).colorScheme.secondary,
            icon: const Icon(
              Icons.shopping_cart,
            ),
          ),
        ),
        child: InkWell(
          onTap: () => Navigator.of(context).pushNamed(
            ProductDetailScreen.routeName,
            arguments: product.id,
          ),
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
