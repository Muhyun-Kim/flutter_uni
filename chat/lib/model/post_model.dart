import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  PostModel({
    required this.text,
    required this.createdAt,
    required this.posterName,
    required this.posterImgUrl,
    required this.posterId,
    required this.reference,
  });

  factory PostModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
    final data = documentSnapshot.data()!;
    return PostModel(
      text: data["text"],
      createdAt: data["createdAt"],
      posterName: data["posterName"],
      posterImgUrl: data["posterImgUrl"],
      posterId: data["posterId"],
      reference: documentSnapshot.reference,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "text": text,
      "createdAt": createdAt,
      "posterName": posterName,
      "posterImgUrl": posterImgUrl,
      "posterId": posterId,
    };
  }

  final String text;
  final Timestamp createdAt;
  final String posterName;
  final String posterImgUrl;
  final String posterId;
  final DocumentReference reference;
}
