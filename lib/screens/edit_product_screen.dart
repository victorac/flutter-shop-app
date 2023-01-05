import 'package:flutter/material.dart';
import 'package:shop_app/widgets/custom_text_input.dart';

class EditProductScreen extends StatefulWidget {
  static const String routeName = '/edit-product';
  const EditProductScreen({
    super.key,
    this.id = '',
    this.title = '',
    this.description = '',
    this.price = 0,
    this.imageUrl = '',
  });

  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late TextEditingController _idController;
  bool _editId = false;
  late TextEditingController _titleController;
  bool _editTitle = false;
  late TextEditingController _descController;
  bool _editDesc = false;
  late TextEditingController _priceController;
  bool _editPrice = false;
  late TextEditingController _imageController;
  bool _editImage = false;
  late String _previousImage;

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController();
    _idController.text = widget.id;
    _titleController = TextEditingController();
    _titleController.text = widget.title;
    _descController = TextEditingController();
    _descController.text = widget.title;
    _priceController = TextEditingController();
    _priceController.text = widget.price.toString();
    _imageController = TextEditingController();
    _imageController.text = widget.imageUrl;
    _previousImage = widget.imageUrl;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit product'),
      ),
      body: Column(
        children: [
          if (!_editImage)
            Card(
              child: Container(
                margin: const EdgeInsets.all(10),
                width: double.infinity,
                height: 150,
                child: Image.network(
                  _imageController.text,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          CustomTextEditor(controller: _imageController, hintText: "image URL"),
        ],
      ),
    );
  }
}
