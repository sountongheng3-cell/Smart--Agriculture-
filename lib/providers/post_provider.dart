import 'package:flutter/material.dart';

import '../models/post_model.dart';
import '../services/post_service.dart';

class PostProvider extends ChangeNotifier {
  bool _isLoading = false;

  List<PostModel> _posts = [];

  bool get isLoading => _isLoading;

  List<PostModel> get posts => _posts;

  // Fetch Posts
  Future<void> fetchPosts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _posts = await PostService.getPosts();
    } catch (e) {
      debugPrint(e.toString());
    }

    _isLoading = false;
    notifyListeners();
  }
}
