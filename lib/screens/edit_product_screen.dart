import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import '../providers/product.dart';

class MutableProduct {
  String id;
  String title;
  String description;
  String imageUrl;
  double price;

  MutableProduct({
    this.id = '',
    this.title = '',
    this.description = '',
    this.imageUrl = '',
    this.price = 0,
  });
}

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';
  const EditProductScreen({super.key});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late String _imageSrc;
  late TextEditingController _imgController;
  late GlobalKey<FormState> _formKey;
  late MutableProduct _product;
  late Function _updateItem;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _imageSrc = '';
    _imgController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final products = Provider.of<Products>(context, listen: false);
    final productId = ModalRoute.of(context)!.settings.arguments as String;
    final productRef = products.tryItem(productId);
    _updateItem = products.updateItem;
    if (productRef == null) {
      _product = MutableProduct(id: DateTime.now().toString());
    } else {
      _product = MutableProduct(
        id: productRef.id,
        title: productRef.title,
        price: productRef.price,
        description: productRef.description,
        imageUrl: productRef.imageUrl,
      );
    }
    _imageSrc = _product.imageUrl;
    _imgController.text = _product.imageUrl;
  }

  @override
  void dispose() {
    _imgController.dispose();
    super.dispose();
  }

  void _updateProduct() {
    _formKey.currentState!.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your products'),
        actions: [
          IconButton(
            onPressed: () {
              _updateProduct();
              _updateItem(
                _product.id,
                _product.title,
                _product.description,
                _product.price,
                _product.imageUrl,
              );
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.save,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  initialValue: _product.title,
                  decoration: const InputDecoration(labelText: 'Title'),
                  textInputAction: TextInputAction.next,
                  onSaved: (newValue) {
                    _product.title = newValue as String;
                  },
                ),
                TextFormField(
                  initialValue: _product.price.toString(),
                  decoration: const InputDecoration(labelText: 'Price'),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  onSaved: (newValue) =>
                      _product.price = double.parse(newValue as String),
                ),
                TextFormField(
                  initialValue: _product.description,
                  decoration: const InputDecoration(labelText: 'Description'),
                  keyboardType: TextInputType.multiline,
                  maxLines: 3,
                  textInputAction: TextInputAction.newline,
                  onSaved: (newValue) =>
                      _product.description = newValue as String,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.only(
                        top: 15,
                        right: 10,
                      ),
                      decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.grey)),
                      child: Image.network(
                        _imageSrc,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.error),
                      ),
                    ),
                    Expanded(
                      child: Focus(
                        onFocusChange: (value) {
                          if (!value) {
                            setState(() {
                              _imageSrc = _imgController.text;
                            });
                          }
                        },
                        child: TextFormField(
                            controller: _imgController,
                            decoration:
                                const InputDecoration(labelText: 'Image URL'),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (value) => setState(() {
                                  _imageSrc = value;
                                }),
                            onSaved: (newValue) =>
                                _product.imageUrl = newValue as String),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
