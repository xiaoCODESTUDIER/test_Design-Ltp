import 'package:flutter/material.dart';
class OptionSelector<T> extends StatefulWidget {
  final List<T> options;
  final ValueChanged<T> onOptionSelected;
  const OptionSelector({super.key, required this.options, required this.onOptionSelected});
  @override
  // ignore: library_private_types_in_public_api
  _OptionSelectorState<T> createState() => _OptionSelectorState<T>();
}
class _OptionSelectorState<T> extends State<OptionSelector<T>> {
  T? _selectedOption;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: widget.options.map((option){
        return InkWell(
          onTap: () {
            setState(() {
              _selectedOption = option;
            });
            widget.onOptionSelected(option);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              color: _selectedOption == option ? Colors.blue : Colors.white,
            ),
            child: Text(
              option.toString(),
              style: TextStyle(color: _selectedOption == option ? Colors.white : Colors.black),
            ),
          ),
        );
      }).toList(),
    );
  }
}