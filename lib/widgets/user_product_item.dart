import 'package:flutter/material.dart';

import '../providers/product.dart';
import '../screens/edit_product_screen.dart';

class UserProductItem extends StatelessWidget {
  const UserProductItem(
      {super.key, required this.product, required this.removeItem});
  final Product product;
  final Function removeItem;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(product.imageUrl),
      ),
      title: Text(product.title),
      trailing: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName,
                  arguments: product.id);
            },
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () => showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                      title: const Text('Are you sure?'),
                      content:
                          const Text('Do you want to delete this product?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(
                            backgroundColor: Theme.of(context).errorColor,
                          ),
                          child: const Text('Delete'),
                        ),
                      ],
                    )).then((value) => {if (value) removeItem(product.id)}),
            icon: const Icon(Icons.delete),
          )
        ],
      ),
    );
  }
}
