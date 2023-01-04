import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';

class ProductDetailScreen extends StatelessWidget {
  static const String routeName = '/product-detail';
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String id = ModalRoute.of(context)!.settings.arguments as String;
    final productsData = Provider.of<Products>(
      context,
      listen: false,
    );
    final product = productsData.item(id);
    // get data from id
    return Scaffold(
      appBar: AppBar(title: Text(product.title)),
      // body: ,
    );
  }
}
