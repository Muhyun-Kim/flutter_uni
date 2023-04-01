import 'package:chatt/main.dart';
import 'package:chatt/model/post_model.dart';
import 'package:chatt/screens/my_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('チャット'),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return const MyPage();
                  }));
                },
                child: CircleAvatar(
                  backgroundImage: NetworkImage(
                    FirebaseAuth.instance.currentUser!.photoURL!,
                  ),
                ),
              ),
            )
          ],
        ),
        body: Center(
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot<PostModel>>(
                  stream: postReference.orderBy("createdAt").snapshots(),
                  builder: ((context, snapshot) {
                    final posts = snapshot.data?.docs ?? [];
                    return ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index].data();
                        return PostWidget(post: post);
                      },
                    );
                  }),
                ),
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: "今何してる？",
                  fillColor: Colors.amber[100],
                  filled: true,
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromARGB(255, 240, 221, 163),
                      width: 1,
                    ),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromARGB(255, 238, 188, 39),
                      width: 1,
                    ),
                  ),
                ),
                onFieldSubmitted: (text) {
                  final newDocumentReference = postReference.doc();

                  final user = FirebaseAuth.instance.currentUser!;

                  final newPost = PostModel(
                    text: text,
                    createdAt: Timestamp.now(),
                    posterName: user.displayName!,
                    posterImgUrl: user.photoURL!,
                    posterId: user.uid,
                    reference: postReference.doc(),
                  );
                  newDocumentReference.set(newPost);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PostWidget extends StatelessWidget {
  const PostWidget({
    super.key,
    required this.post,
  });

  final PostModel post;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(post.posterImgUrl),
          ),
          const SizedBox(
            width: 4,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      post.posterName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(DateFormat("yyyy/MM/dd HH:mm:ss")
                        .format(post.createdAt.toDate())),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: FirebaseAuth.instance.currentUser!.uid ==
                                  post.posterId
                              ? const Color.fromARGB(255, 147, 197, 239)
                              : const Color.fromARGB(255, 233, 182, 221),
                        ),
                        child: Text(post.text)),
                    if (FirebaseAuth.instance.currentUser!.uid == post.posterId)
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              post.reference.delete();
                            },
                            icon: const Icon(Icons.delete),
                          ),
                          IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text("update"),
                                    content: TextFormField(
                                      initialValue: post.text,
                                      autofocus: true,
                                      onFieldSubmitted: (newText) {
                                        post.reference.update(
                                          {
                                            "text": newText,
                                          },
                                        );
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  );
                                },
                              );
                            },
                            icon: const Icon(Icons.edit),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
