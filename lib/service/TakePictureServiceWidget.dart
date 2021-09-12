// ignore_for_file: must_be_immutable
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';


import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class TakePictureServiceWidget extends StatefulWidget{

  CameraDescription camera;

  TakePictureServiceWidget(camera){
    this.camera = camera;
  }

  @override
  State<StatefulWidget> createState() {
    return TakePictureServiceWidgetState();
  }
}

class TakePictureServiceWidgetState extends State<TakePictureServiceWidget>{

  int selectedIndex = 0;
  bool start = false;
  bool isRec = false;

  CameraController cameraController;
  Future<void> initializeCameraControllerFuture;
  Future<Directory> videoDirectoryPath;
  String fileName;

  @override
  void initState() {
    super.initState();

    cameraController =
        CameraController(widget.camera, ResolutionPreset.medium);

    initializeCameraControllerFuture = cameraController.initialize();
    //fileInit();
  }


  void fileInit() async {
    fileName = DateTime.now() as String;
    videoDirectoryPath = join((await getTemporaryDirectory()).path, '${fileName}.mp4') as Future<Directory>;
  }

  void takePicture(BuildContext context) async {
    try {
      await initializeCameraControllerFuture;

      if (selectedIndex == 0) {
        // capture picture
        await cameraController.takePicture();
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
      print(e);
    }
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
                return Center(child: CircularProgressIndicator());
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
                  // child: Icon(Icons.camera_alt, color: Colors.white),
                  onPressed: () {
                    takePicture(context);
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
            height: 0,
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
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

}