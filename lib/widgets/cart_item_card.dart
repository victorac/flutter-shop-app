import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';

class CartItemCard extends StatelessWidget {
  const CartItemCard({
    super.key,
    required this.id,
    required this.productId,
    required this.title,
    required this.quantity,
    required this.price,
    required this.removeItem,
  });

  final String id;
  final String productId;
  final String title;
  final int quantity;
  final double price;
  final Function removeItem;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(id),
      background: Container(
        color: Theme.of(context).errorColor,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 8,
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 30,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        print(productId);
        removeItem(productId);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: FittedBox(
                  child: Text('\$$price'),
                ),
              ),
            ),
            title: Text(title),
            subtitle: Text('\$${(quantity * price)}'),
            trailing: Text('$quantity x'),
          ),
        ),
      ),
    );
  }
}
