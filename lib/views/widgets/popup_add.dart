import 'package:more_moda_admin/controllers/main_categories_controller.dart';
import 'package:more_moda_admin/static/static.dart';
import 'package:more_moda_admin/views/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class AddMainCategoryCustomDialog extends StatelessWidget {
  const AddMainCategoryCustomDialog({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    String newCategoryName = '';

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      child: Container(
        width: width * 0.3,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          // border: Border.all(color: Color(0xFFC4CFD7), width: 3),
          color: Colors.white,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Neue Kategorie hinzufügen',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: popuptitleColor),
            ),
            Divider(),
            TextFormField(
              decoration: textFieldDecoration.copyWith(
                labelText: 'Name der neuen Kategorie',
              ),
              autofillHints: ['Add new category'],
              onChanged: (value) {
                newCategoryName = value;
              },
              onFieldSubmitted: (value) {
                createMainCategories(value);
                if (value != null && value.isNotEmpty) {
                  Navigator.pop(context);
                }
              },
            ),
            SizedBox(
              height: 10,
            ),
            customButton(
              text: 'Hinzufügen',
              onPressed: () {
                createMainCategories(newCategoryName);
                if (newCategoryName != null && newCategoryName.isNotEmpty) {
                  Navigator.pop(context);
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
