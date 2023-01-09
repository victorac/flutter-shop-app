import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart';
import '../providers/cart.dart';
import '../widgets/cart_item_card.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart-screen';
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    final List<CartItem> cartItems = cart.items.values.toList();
    final isCartEmpty = cart.itemCount == 0;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total",
                    style: TextStyle(fontSize: 20),
                  ),
                  const Spacer(),
                  Chip(
                    label: Text(
                      '\$${cart.total.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Theme.of(context)
                            .primaryTextTheme
                            .titleLarge!
                            .color,
                      ),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  TextButton(
                    onPressed: isCartEmpty
                        ? null
                        : () async {
                            try {
                              await Provider.of<Orders>(context, listen: false)
                                  .addOrder(cart);
                              await cart.clear();
                            } catch (error) {
                              scaffoldMessenger.clearSnackBars();
                              scaffoldMessenger.showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Error while making the order!',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            }
                          },
                    child: const Text('Order!'),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: cart.productCount,
              itemBuilder: (context, index) => CartItemCard(
                productId: cartItems[index].productId,
                title: cartItems[index].title,
                quantity: cartItems[index].quantity,
                price: cartItems[index].price,
                removeItem: cart.removeItem,
              ),
            ),
          )
        ],
      ),
    );
  }
}
