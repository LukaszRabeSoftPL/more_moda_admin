import 'package:flutter/material.dart';

class CompaniesPage extends StatelessWidget {
  const CompaniesPage({Key? keyCompanies}) : super(key: keyCompanies);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Companies Page')),
      body: Center(child: Text('Companies Page')),
    );
  }
}
