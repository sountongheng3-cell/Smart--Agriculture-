class PostModel {
  final int id;
  final String title;
  final String content;
  final String image;
  final String author;

  PostModel({
    required this.id,
    required this.title,
    required this.content,
    required this.image,
    required this.author,
  });

  // Convert JSON to Object
  factory PostModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return PostModel(
      id: json['id'] ?? 0,

      title: json['title'] ?? '',

      content: json['content'] ?? '',

      image: json['image'] ?? '',

      author: json['author'] ?? '',
    );
  }

  // Convert Object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'image': image,
      'author': author,
    };
  }
}