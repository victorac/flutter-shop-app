import 'package:flutter/material.dart';

class CustomTextEditor extends StatefulWidget {
  const CustomTextEditor({
    super.key,
    required this.controller,
    required this.hintText,
    this.isDigit = false,
  });

  final TextEditingController controller;
  final String hintText;
  final bool isDigit;
  @override
  State<CustomTextEditor> createState() => _CustomTextEditorState();
}

class _CustomTextEditorState extends State<CustomTextEditor> {
  bool _edit = false;
  late FocusNode focusNode;

  @override
  void initState() {
    focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
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
        }),
        keyboardType: widget.isDigit
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
      ),
    );
  }
}
