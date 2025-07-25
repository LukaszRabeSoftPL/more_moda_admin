import 'package:more_moda_admin/controllers/main_categories_controller.dart';
import 'package:more_moda_admin/controllers/subcategories_controller.dart';
import 'package:more_moda_admin/static/static.dart';
import 'package:more_moda_admin/views/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class AddSubcategoryBaustoffe extends StatelessWidget {
  const AddSubcategoryBaustoffe({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    String newSubCategoryName = '';

    return Dialog(
      child: Container(
        width: width * 0.3,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xFF3E84BE), width: 3),
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Neue Unterkategorie hinzufügen',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: popuptitleColor),
            ),
            Divider(),
            TextFormField(
              showCursor: true,
              autofillHints: ['Add new category'],
              onChanged: (value) {
                newSubCategoryName = value;
              },
              onFieldSubmitted: (value) {
                createSubCategoryBaustoffe(value);
                if (value != null && value.isNotEmpty) {
                  Navigator.pop(context);
                }
              },
            ),
            SizedBox.fromSize(size: const Size(0, 10)),
            customButton(
              text: 'Unterkategorie hinzufügen',
              onPressed: () {
                createSubCategoryBaustoffe(newSubCategoryName);
                if (newSubCategoryName != null &&
                    newSubCategoryName.isNotEmpty) {
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
