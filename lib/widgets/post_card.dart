import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../models/post_model.dart';
import '../screens/community/comment_screen.dart';

class PostCard extends StatefulWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  int likes = 0;

  bool isLiked = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

      elevation: 3,

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // User Header
            Row(
              children: [
                const CircleAvatar(child: Icon(Icons.person)),

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        widget.post.author,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),

                      const Text(
                        '2 hours ago',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Text(
              widget.post.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text(widget.post.content),

            const SizedBox(height: 15),

            if (widget.post.image.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(15),

                child: Image.network(
                  widget.post.image,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

            const SizedBox(height: 15),

            const Divider(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,

              children: [
                // Like
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      if (isLiked) {
                        likes--;
                        isLiked = false;
                      } else {
                        likes++;
                        isLiked = true;
                      }
                    });
                  },

                  icon: Icon(
                    Icons.thumb_up,
                    color: isLiked ? Colors.blue : Colors.grey,
                  ),

                  label: Text('$likes Like'),
                ),

                // Comment
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CommentScreen()),
                    );
                  },

                  icon: const Icon(Icons.comment, color: Colors.green),

                  label: const Text('Comment'),
                ),

                // Share
                TextButton.icon(
                  onPressed: () {
                    Share.share(
                      '${widget.post.title}\n\n${widget.post.content}',
                    );
                  },

                  icon: const Icon(Icons.share, color: Colors.orange),

                  label: const Text('Share'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
