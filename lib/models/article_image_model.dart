class ArticleImage {
  final String id;
  final String articleId;
  final String imageUrl;

  ArticleImage({
    required this.id,
    required this.articleId,
    required this.imageUrl,
  });

  factory ArticleImage.fromJson(Map<String, dynamic> json) {
    return ArticleImage(
      id: json['id'],
      articleId: json['article_id'],
      imageUrl: json['image_url'],
    );
  }
}
