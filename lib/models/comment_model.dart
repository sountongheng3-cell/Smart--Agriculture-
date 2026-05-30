class CommentModel {
  final int id;
  final String userName;
  final String comment;

  CommentModel({
    required this.id,
    required this.userName,
    required this.comment,
  });

  // Convert JSON to Object
  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] ?? 0,

      userName: json['user_name'] ?? '',

      comment: json['comment'] ?? '',
    );
  }

  // Convert Object to JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'user_name': userName, 'comment': comment};
  }
}
