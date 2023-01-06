import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/custom_text_input.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const String routeName = '/edit-product';
  const EditProductScreen({super.key});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late TextEditingController _idController;
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _imageController;

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController();
    _titleController = TextEditingController();
    _descController = TextEditingController();
    _priceController = TextEditingController();
    _imageController = TextEditingController();
  }

  @override
  void dispose() {
    _idController.dispose();
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String productId =
        ModalRoute.of(context)!.settings.arguments as String;
    final products = Provider.of<Products>(context, listen: false);
    final product = products.item(productId);

    _idController.text = product.id;
    _titleController.text = product.title;
    _descController.text = product.description;
    _priceController.text = product.price.toString();
    _imageController.text = product.imageUrl;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit product'),
        actions: [
          IconButton(
              onPressed: () {
                products.updateItem(
                  _idController.text,
                  _titleController.text,
                  _descController.text,
                  double.parse(_priceController.text),
                  _imageController.text,
                );
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.save))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CustomTextEditor(
              controller: _imageController,
              hintText: "image URL",
              imageUrl: _imageController.text,
              displayImage: true,
            ),
            CustomTextEditor(controller: _idController, hintText: "ID"),
            CustomTextEditor(controller: _titleController, hintText: "name"),
            CustomTextEditor(
                controller: _descController, hintText: "description"),
            CustomTextEditor(
              controller: _priceController,
              hintText: "price",
              isDigit: true,
            ),
          ],
        ),
      ),
    );
  }
}
