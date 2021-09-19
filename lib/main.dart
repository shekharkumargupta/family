
import 'package:camera/camera.dart';
import 'package:family/view/MainTab.dart';
import 'package:family/widgets/TakePictureScreen.dart';
import 'package:family/widgets/TakePictureScreenWidget.dart';
import 'package:flutter/material.dart';



List<CameraDescription> cameras = [];
CameraDescription firstCamera;

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras().then ((cameras) {
      firstCamera = cameras.first;
    }).catchError((e) {
      print('Error Camera:$e');
    });
  } on CameraException catch (e) {
    print(e);
  }

  runApp(
      MaterialApp(
          title: 'Test Camera',
          builder: (context, child) =>
          //TakePictureScreen(camera: firstCamera)
          TakePictureScreenWidget(cameras: cameras, firstCamera: firstCamera)
        //MainTab(cameras: cameras, firstCamera: firstCamera)
      )
  );


}


