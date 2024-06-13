import 'package:architect_schwarz_admin/controllers/main_categories_controller.dart';
import 'package:architect_schwarz_admin/controllers/subcategories_controller.dart';
import 'package:architect_schwarz_admin/static/static.dart';
import 'package:flutter/material.dart';

class addSubcategoryBauteile extends StatelessWidget {
  const addSubcategoryBauteile({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

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
              'Add new category',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: popuptitleColor),
            ),
            Divider(),
            TextFormField(
              autofillHints: ['Add new category'],
              onFieldSubmitted: (value) {
                createSubCategoryBauteile(value);
                if (value != null && value.isNotEmpty) {
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
