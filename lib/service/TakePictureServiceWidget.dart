import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';


import 'package:camera/camera.dart';
import 'package:flutter/material.dart';


class TakePictureServiceWidget extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    return TakePictureServiceWidgetState();
  }
}

class TakePictureServiceWidgetState extends State<TakePictureServiceWidget>{

  int selectedIndex = 0;
  bool start = false;
  bool isRec = false;

  late List<CameraDescription> cameras = [];
  late CameraDescription firstCamera;

  late CameraController cameraController;
  late Future<void> initializeCameraControllerFuture;
  late Future<Directory> videoDirectoryPath;

  late XFile imageFile;
  late XFile videoFile;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> initializeCamera() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      cameras = await availableCameras();
    } on CameraException catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    initializeCamera();

    firstCamera = cameras.first;
    cameraController = CameraController(firstCamera, ResolutionPreset.high);
    initializeCameraControllerFuture = cameraController.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    cameraController.dispose();
    super.dispose();
  }




  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(
        children: <Widget>[
          FutureBuilder(
            future: initializeCameraControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return CameraPreview(cameraController);
              } else {
                return Center(child: CircularProgressIndicator(backgroundColor: Colors.black,));
              }
            },
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FloatingActionButton(
                  backgroundColor: Colors.orange,
                  child: Icon(Icons.camera_alt, color: Colors.white),
                  onPressed: () {
                    //takePicture(context);
                    takePicture2();
                  },
                ),
              ),
            ),
          ),
          isRec == true ?
          SafeArea(
            child: Container(
              height: 40,
              // alignment: Alignment.topLeft,
              decoration: BoxDecoration(
                color: Color(0xFFEE4400),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "REC",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFFFAFAFA)),
                ),
              ),
            ),
          )
          : SizedBox(
            height: 20,
          )
        ],
      ),
      bottomNavigationBar:
              BottomNavigationBar(
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.camera),
                    title: Text('Picture'),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.videocam),
                    title: Text('Video'),
                  ),
                ],
                currentIndex: selectedIndex,
                selectedItemColor: Colors.amber[800],
                onTap: onItemTapped,
              ),
    );
  }

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  void showInSnackBar(String message) {
    // ignore: deprecated_member_use
    _scaffoldKey.currentState?.showSnackBar(SnackBar(content: Text(message)));
  }


  void takePicture(BuildContext context) async {
    try {
      await initializeCameraControllerFuture;

      if (selectedIndex == 0) {
        // capture picture
        await cameraController.takePicture().then((XFile file) {
          if (mounted) {
            setState(() {
              imageFile = file;
              //videoController.dispose();
            });
            if (file != null) showInSnackBar('Picture saved to ${file.path}');
          }
        });
        Navigator.pop(context);
      } else {
        //video recording
        if (start) {
          //start recording
          await cameraController.startVideoRecording();
          setState(() {
            start = !start;
            isRec = !isRec;
          });
        } else {
          // stop recording
          cameraController.stopVideoRecording();
          setState(() {
            isRec = !isRec;
          });
          Navigator.pop(context);
        }
      }
    } catch (e) {
      showInSnackBar(e.toString());
    }
  }


  Future<XFile> takePicture2() async {
    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
    }

    if (cameraController.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      //return null;
    }

    try {
      XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      showInSnackBar(e.description.toString());
      return cameraController.takePicture();
    }
  }

}