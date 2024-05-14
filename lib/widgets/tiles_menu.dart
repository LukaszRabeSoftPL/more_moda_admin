import 'package:flutter/material.dart';

class MenuItem extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const MenuItem({
    Key? key,
    required this.title,
    required this.selected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      selected: selected,
      selectedColor: Colors.white, // Kolor tekstu dla zaznaczonego elementu
      selectedTileColor:
          Colors.blue.withOpacity(0.2), // Kolor tła dla zaznaczonego elementu
      tileColor: selected
          ? Colors.blue
          : null, // Tło zmienia się gdy element jest aktywny
      onTap: onTap,
    );
  }
}
//                 },