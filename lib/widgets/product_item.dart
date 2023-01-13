import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../providers/cart.dart';
import '../providers/product.dart';
import '../screens/product_detail_screen.dart';

class ProductItem extends StatelessWidget {
  const ProductItem({super.key});

  Future<void> _addItemToCart(Cart cartData, Product product) async {
    if (cartData.items.containsKey(product.id)) {
      cartData.updateItem(
        product.id,
        product.title,
        product.price,
      );
    } else {
      cartData.addItem(
        product.id,
        product.title,
        product.price,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final product = Provider.of<Product>(context, listen: false);
    final cartData = Provider.of<Cart>(context, listen: false);
    final token = Provider.of<Auth>(context, listen: false).token;
    final uid = Provider.of<Auth>(context, listen: false).userId;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          leading: Consumer<Product>(
            builder: (_, product, __) => IconButton(
              onPressed: () async {
                try {
                  await product.toggleIsFavorite(uid, token);
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
            onPressed: () async {
              try {
                await _addItemToCart(cartData, product);
                scaffoldMessenger.clearSnackBars();
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: const Text('Added item to cart!'),
                    action: SnackBarAction(
                      label: "UNDO",
                      onPressed: () async {
                        try {
                          await cartData.removeSingleItem(product.id);
                        } catch (error) {
                          scaffoldMessenger.clearSnackBars();
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Error undoing add item to cart',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                );
              } catch (error) {
                scaffoldMessenger.clearSnackBars();
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Failed adding item to cart!'),
                  ),
                );
              }
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
