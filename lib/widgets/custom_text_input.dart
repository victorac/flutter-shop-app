import 'package:flutter/material.dart';

class CustomTextEditor extends StatefulWidget {
  const CustomTextEditor(
      {super.key, required this.controller, required this.hintText});

  final TextEditingController controller;
  final String hintText;

  @override
  State<CustomTextEditor> createState() => _CustomTextEditorState();
}

class _CustomTextEditorState extends State<CustomTextEditor> {
  bool _edit = false;

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
                setState(() {
                  _edit = !_edit;
                  FocusManager.instance.primaryFocus?.unfocus();
                });
              },
              icon: Icon(_edit ? Icons.check : Icons.edit),
            )),
        onTap: () => {},
        readOnly: !_edit,
        controller: widget.controller,
        onSubmitted: (value) => setState(() {
          _edit = false;
          FocusManager.instance.primaryFocus?.unfocus();
        }),
      ),
    );
  }
}
