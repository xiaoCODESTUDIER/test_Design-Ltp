import 'package:flutter/material.dart';

class MenuButton{
  final String text;
  final VoidCallback onPressed;
  MenuButton({required this.text, required this.onPressed});
}

class MenuBar extends StatelessWidget{
  final List<MenuButton> buttons;
  const MenuBar({super.key, required this.buttons});
  
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: buttons.map((button) {
          return Column(
            children: [
              ElevatedButton(
                onPressed: button.onPressed,
                child: Text(button.text),
              ),
              const SizedBox(height: 10),
            ],
          );
        }).toList(),
      ),
    );
  }
}