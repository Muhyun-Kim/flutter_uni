import 'package:chatt/firebase_options.dart';
import 'package:chatt/model/post_model.dart';
import 'package:chatt/screens/chat_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      return const MaterialApp(
        home: SignInPage(),
      );
    } else {
      return const MaterialApp(
        home: ChatPage(),
      );
    }
  }
}

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  Future<void> signInWithGoogle() async {
    final googleUser =
        await GoogleSignIn(scopes: ['profile', 'email']).signIn();

    final googleAuth = await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GoogleSignIn'),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('GoogleSignIn'),
          onPressed: () async {
            await signInWithGoogle();
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) {
                    return const ChatPage();
                  },
                ),
                (route) => false,
              );
            }
          },
        ),
      ),
    );
  }
}

final postReference =
    FirebaseFirestore.instance.collection("post").withConverter<PostModel>(
  fromFirestore: (documentSnapshot, _) {
    return PostModel.fromFirestore(documentSnapshot);
  },
  toFirestore: (data, _) {
    return data.toMap();
  },
);
