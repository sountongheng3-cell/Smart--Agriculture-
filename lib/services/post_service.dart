import '../core/constants/api_urls.dart';
import '../models/post_model.dart';
import 'api_service.dart';

class PostService {
  static Future<List<PostModel>> getPosts() async {
    final response = await ApiService.getRequest(ApiUrls.posts);

    List data = response['posts'];

    return data.map((json) {
      return PostModel(
        id: json['id'],
        title: json['title'],
        content: json['body'],
        image: 'https://picsum.photos/400/200',
        author: 'Farmer User',
      );
    }).toList();
  }
}
