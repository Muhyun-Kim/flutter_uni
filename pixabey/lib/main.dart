import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pixabey/api_key.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: PixabeyPage(),
    );
  }
}

class PixabeyPage extends StatefulWidget {
  const PixabeyPage({super.key});

  @override
  State<PixabeyPage> createState() => _PixabeyPageState();
}

class _PixabeyPageState extends State<PixabeyPage> {
  List<PixabeyImg> pixabeyImges = [];

  Future<void> fetchImages(String serchWord) async {
    final response = await Dio().get(
        "https://pixabay.com/api/?key=$fixabeyApiKey&q=$serchWord&image_type=photo&pretty=true");
    final List hits = response.data["hits"];
    pixabeyImges = hits.map(
      (e) {
        return PixabeyImg.fromMap(e);
      },
    ).toList();
    setState(() {});
  }

  Future<void> shareImg(String url) async {
    final response = await Dio().get(
      url,
      options: Options(responseType: ResponseType.bytes),
    );
    final dir = await getTemporaryDirectory();
    final file =
        await File("${dir.path}/image.png").writeAsBytes(response.data);
    Share.shareXFiles([XFile(file.path)]);
  }

  @override
  void initState() {
    super.initState();
    fetchImages("花");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          initialValue: "花",
          decoration: const InputDecoration(
            fillColor: Colors.white,
            filled: true,
          ),
          onFieldSubmitted: (value) {
            fetchImages(value);
          },
        ),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemCount: pixabeyImges.length,
        itemBuilder: (context, index) {
          final pixabeyImg = pixabeyImges[index];
          return InkWell(
            onTap: () async {
              shareImg(pixabeyImg.webformatURL);
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  pixabeyImg.previewURL,
                  fit: BoxFit.cover,
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    color: Colors.white,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.thumb_up_alt_outlined,
                          size: 14,
                        ),
                        Text("${pixabeyImg.likes}"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class PixabeyImg {
  final String webformatURL;
  final String previewURL;
  final int likes;

  PixabeyImg({
    required this.webformatURL,
    required this.previewURL,
    required this.likes,
  });

  factory PixabeyImg.fromMap(Map<String, dynamic> map) {
    return PixabeyImg(
      webformatURL: map["webformatURL"],
      previewURL: map["previewURL"],
      likes: map["likes"],
    );
  }
}
