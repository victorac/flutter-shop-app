import 'package:flutter/material.dart';

class CustomTextEditor extends StatefulWidget {
  const CustomTextEditor({
    super.key,
    required this.controller,
    required this.hintText,
    this.isDigit = false,
    this.imageUrl = '',
    this.displayImage = false,
  });

  final TextEditingController controller;
  final String hintText;
  final bool isDigit;
  final String imageUrl;
  final bool displayImage;

  @override
  State<CustomTextEditor> createState() => _CustomTextEditorState();
}

class _CustomTextEditorState extends State<CustomTextEditor> {
  bool _edit = false;
  late FocusNode focusNode;
  late String _imageUrl;

  @override
  void initState() {
    focusNode = FocusNode();
    _imageUrl = widget.imageUrl;
    super.initState();
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textField = Padding(
      padding: const EdgeInsets.all(8.0),
      child: Focus(
        onFocusChange: (value) {
          if (!value) {
            setState(() {
              _edit = false;
            });
          }
        },
        child: TextField(
          decoration: InputDecoration(
            border: const UnderlineInputBorder(),
            labelText: 'Enter ${widget.hintText}',
            suffixIcon: IconButton(
              onPressed: () {
                if (!_edit) {
                  FocusScope.of(context).requestFocus(focusNode);
                } else {
                  FocusScope.of(context).unfocus();
                  if (widget.displayImage) {
                    setState(() {
                      _imageUrl = widget.controller.text;
                    });
                  }
                }
                setState(() {
                  _edit = !_edit;
                });
              },
              icon: Icon(_edit ? Icons.check : Icons.edit),
            ),
          ),
          onTap: () => {
            setState(() {
              _edit = true;
            })
          },
          focusNode: focusNode,
          readOnly: !_edit,
          controller: widget.controller,
          onSubmitted: (value) => setState(() {
            _edit = false;
            FocusScope.of(context).unfocus();
            if (widget.displayImage) {
              setState(() {
                _imageUrl = widget.controller.text;
              });
            }
          }),
          keyboardType: widget.isDigit
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
        ),
      ),
    );

    if (widget.displayImage) {
      return ProductImageDisplay(imageUrl: _imageUrl, textField: textField);
    } else {
      return textField;
    }
  }
}

class ProductImageDisplay extends StatelessWidget {
  const ProductImageDisplay({
    Key? key,
    required String imageUrl,
    required this.textField,
  })  : _imageUrl = imageUrl,
        super(key: key);

  final String _imageUrl;
  final Padding textField;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ImageDisplay(imageUrl: _imageUrl),
          textField,
        ],
      ),
    );
  }
}

class ImageDisplay extends StatelessWidget {
  const ImageDisplay({
    super.key,
    required this.imageUrl,
  });

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      width: double.infinity,
      height: 150,
      child: Image.network(
        imageUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.error),
            Text('Image not found!'),
          ],
        ),
      ),
    );
  }
}
