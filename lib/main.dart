import 'dart:io';

import 'package:camera/camera.dart';
import 'package:family/view/MainTab.dart';
import 'package:family/widgets/CameraScreen.dart';
import 'package:flutter/material.dart';

List<CameraDescription> cameras = [];
late CameraDescription firstCamera;

File? imageFile;
File? videoFile;

Future<void> main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: MainTab(),
      //home: CameraScreen(),
    );
  }
}
