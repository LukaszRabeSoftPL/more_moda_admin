class Article {
  final String id;
  String title;
  String body;
  String mainCategoryId;

  Article({
    required this.id,
    required this.title,
    required this.body,
    required this.mainCategoryId,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      mainCategoryId: json['main_category_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'main_category_id': mainCategoryId,
    };
  }
}
