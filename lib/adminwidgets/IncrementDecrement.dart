import 'package:flutter/material.dart';

class IncrementDecrementFormField extends StatefulWidget {
  final String labelText;

  const IncrementDecrementFormField({super.key, required this.labelText});

  @override
  // ignore: library_private_types_in_public_api
  _IncrementDecrementFormFieldState createState() => _IncrementDecrementFormFieldState();
}

class _IncrementDecrementFormFieldState extends State<IncrementDecrementFormField> {
  int _value = 0;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = _value.toString();
  }

  // Method to increase the value
  void _increaseValue() {
    setState(() {
      _value++;
      _controller.text = _value.toString();
    });
  }

  // Method to decrease the value
  void _decreaseValue() {
    setState(() {
      if (_value > 0) {
        _value--;
        _controller.text = _value.toString();
      }
    });
  }

  // Method to handle changes from the text field
  void _handleTextChanged(String value) {
    final int? newValue = int.tryParse(value);
    if (newValue != null && newValue >= 0) {
      setState(() {
        _value = newValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: _decreaseValue,
          icon: const Icon(Icons.remove),
        ),
        Expanded(
          child: TextFormField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: widget.labelText,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            ),
            textAlign: TextAlign.center,
            onChanged: _handleTextChanged, // Handle text field changes
          ),
        ),
        IconButton(
          onPressed: _increaseValue,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
