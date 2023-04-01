import 'package:chatt/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      appBar: AppBar(
        title: const Text("my page"),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 12,
            ),
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(
                user.photoURL!,
              ),
            ),
            Text(
              user.displayName!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("ユーザーID : ${user.uid}"),
                Text("登録日 : ${user.metadata.creationTime!}"),
              ],
            ),
            const SizedBox(
              height: 24,
            ),
            ElevatedButton(
              onPressed: () async {
                await GoogleSignIn().signOut();
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) {
                      return const SignInPage();
                    },
                  ),
                  (route) => false,
                );
              },
              child: const Text("サインアウト"),
            )
          ],
        ),
      ),
    );
  }
}
