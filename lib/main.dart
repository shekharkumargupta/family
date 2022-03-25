import 'dart:io';

import 'package:camera/camera.dart';
import 'package:family/view/MainTab.dart';
import 'package:family/view/PostForm.dart';
import 'package:family/view/PostList.dart';
import 'package:family/widgets/CameraScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:family/service/PostService.dart';

List<CameraDescription> cameras = [];
late CameraDescription firstCamera;

File? imageFile;
File? videoFile;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  /*
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyDixcd9bpFq34LSGGsxOCG-AbIHmvigqGE",
        authDomain: "family-3e0bf.firebaseapp.com",
        projectId: "family-3e0bf",
        storageBucket: "family-3e0bf.appspot.com",
        messagingSenderId: "269950461764",
        appId: "1:269950461764:web:20c00e10045f9f76d3d911",
        measurementId: "G-EBN57FWXYC"
    ),
  );
  */
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (context) => MainTab(),
        '/createPost': (context) => PostForm(),
        '/listPost': (context) => PostList(),
      },

      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      //home: MainTab(),
      //home: CameraScreen(),
    );
  }
}
