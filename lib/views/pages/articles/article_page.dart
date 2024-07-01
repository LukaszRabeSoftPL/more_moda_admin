import 'package:flutter/material.dart';

class ArticlesPage extends StatelessWidget {
  const ArticlesPage({Key? articleKey}) : super(key: articleKey);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Article Page')),
      body: Center(child: Text('Article Page')),
    );
  }
}
