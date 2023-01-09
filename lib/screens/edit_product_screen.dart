import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';

class MutableProduct {
  String id;
  String title;
  String description;
  String imageUrl;
  String price;
  bool isFavorite;

  MutableProduct({
    this.id = '',
    this.title = '',
    this.description = '',
    this.imageUrl = '',
    this.price = '',
    this.isFavorite = false,
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
  final urlRegex = RegExp(
      r"(https?|ftp)://([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:,.;]*)?",
      caseSensitive: false);
  bool _isInit = true;
  bool _isLoading = false;

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
    if (_isInit) {
      final products = Provider.of<Products>(context, listen: false);
      final productId = ModalRoute.of(context)!.settings.arguments;
      if (productId == null) {
        _product = MutableProduct();
      } else {
        final productRef = products.item(productId as String);
        _product = MutableProduct(
          id: productRef.id,
          title: productRef.title,
          price: productRef.price.toStringAsFixed(2),
          description: productRef.description,
          imageUrl: productRef.imageUrl,
          isFavorite: productRef.isFavorite,
        );
      }
      _imageSrc = _product.imageUrl;
      _imgController.text = _product.imageUrl;
      _isInit = false;
    }
  }

  @override
  void dispose() {
    _imgController.dispose();
    super.dispose();
  }

  Future<void> _addProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    // updates the MutableProduct _product with form data
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<Products>(context, listen: false).addItem(
        title: _product.title,
        description: _product.description,
        price: double.parse(_product.price),
        imageUrl: _product.imageUrl,
      );
    } catch (error) {
      await showDialog(
        context: context,
        builder: ((ctx) => AlertDialog(
              title: const Text('Error'),
              content:
                  const Text('There was an error while adding the product'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('OK'),
                )
              ],
            )),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
    }
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    // updates the MutableProduct _product with form data
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<Products>(context, listen: false).updateItem(
        _product.id,
        _product.title,
        _product.description,
        double.parse(_product.price),
        _product.imageUrl,
        _product.isFavorite,
      );
    } catch (error) {
      await showDialog(
        context: context,
        builder: ((ctx) => AlertDialog(
              title: const Text('Error'),
              content:
                  const Text('There was an error while updating the product'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('OK'),
                )
              ],
            )),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
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
              if (_product.id.isEmpty) {
                _addProduct();
              } else {
                _updateProduct();
              }
            },
            icon: const Icon(
              Icons.save,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please provide a title';
                          }
                        },
                      ),
                      TextFormField(
                          initialValue: _product.price.toString(),
                          decoration: const InputDecoration(labelText: 'Price'),
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          onSaved: (newValue) =>
                              _product.price = newValue as String,
                          validator: (value) {
                            try {
                              double.parse(value as String);
                            } on FormatException {
                              return 'Please provide a valid number';
                            }
                          }),
                      TextFormField(
                        initialValue: _product.description,
                        decoration:
                            const InputDecoration(labelText: 'Description'),
                        keyboardType: TextInputType.multiline,
                        maxLines: 3,
                        textInputAction: TextInputAction.newline,
                        onSaved: (newValue) =>
                            _product.description = newValue as String,
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Please provide a description'
                            : null,
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
                                border:
                                    Border.all(width: 1, color: Colors.grey)),
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
                                  decoration: const InputDecoration(
                                      labelText: 'Image URL'),
                                  keyboardType: TextInputType.url,
                                  textInputAction: TextInputAction.done,
                                  validator: (value) {
                                    return urlRegex.hasMatch(value as String)
                                        ? null
                                        : 'Plase input a valid URL';
                                  },
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
