import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FeedScreen extends StatefulWidget {
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _postController = TextEditingController();

  void _createPost() async {
    if (_postController.text.isNotEmpty) {
      final user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        String username = userDoc['username'];

        await _firestore.collection('posts').add({
          'userId': user.uid,
          'username': username,
          'content': _postController.text,
          'timestamp': FieldValue.serverTimestamp(),
        });
        _postController.clear();
      }
    }
  }

  void _updatePost(String postId, String currentContent) async {
    final updatedContent = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: currentContent);
        return AlertDialog(
          title: Text('Update Post'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: 'Post Content'),
            maxLines: null,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: Text('Update'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );

    if (updatedContent != null && updatedContent.isNotEmpty) {
      await _firestore.collection('posts').doc(postId).update({
        'content': updatedContent,
      });
    }
  }

  void _deletePost(String postId, String userId) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null && currentUser.uid == userId) {
      await _firestore.collection('posts').doc(postId).delete();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You can only delete your own posts')),
      );
    }
  }

  void _logout() async {
    try {
      await _auth.signOut();
      Get.offAllNamed('/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feed'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _postController,
                    decoration: InputDecoration(labelText: 'Create a post'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _createPost,
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: _firestore.collection('posts').orderBy('timestamp', descending: true).snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var document = snapshot.data!.docs[index];
                    var data = document.data() as Map<String, dynamic>;
                    String username = data['username'] ?? 'Unknown User';
                    String postContent = data['content'] ?? 'No Content';
                    String postId = document.id;
                    String userId = data['userId'] ?? '';

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text(username),
                        subtitle: Text(postContent),
                        trailing: userId == _auth.currentUser?.uid
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () => _updatePost(postId, postContent),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () => _deletePost(postId, userId),
                                  ),
                                ],
                              )
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
