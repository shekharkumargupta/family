
import 'package:camera/camera.dart';
import 'package:family/view/MainTab.dart';
import 'package:family/widgets/TakePictureScreenWidget.dart';
import 'package:flutter/material.dart';



List<CameraDescription> cameras = [];

Future<void> main() async {
  //CameraDescription firstCamera;
  // Fetch the available cameras before initializing the app.
  try {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras().then ((cameras) {
     // firstCamera = cameras.first;
      //print("FirstCamera: " + firstCamera.name);

    }).catchError((e) {
      print('Error Camera:$e');
    });
  } on CameraException catch (e) {
    print(e);
  }
  runApp(MainTab(cameras: cameras));
}


