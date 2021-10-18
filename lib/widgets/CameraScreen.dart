import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
//import 'package:gallery_saver/gallery_saver.dart';

import '../main.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? controller;

  late Future<void> initializeCameraControllerFuture;
  bool _isCameraInitialized = false;

  final resolutionPresets = ResolutionPreset.values;
  ResolutionPreset currentResolutionPreset = ResolutionPreset.high;

  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 10.0;
  double _currentZoomLevel = 5.0;

  double _minAvailableExposureOffset = 1.0;
  double _maxAvailableExposureOffset = 10.0;
  double _currentExposureOffset = 5.0;

  FlashMode? _currentFlashMode;
  bool _isRearCameraSelected = true;
  bool _isVideoCameraSelected = false;
  bool _isRecordingInProgress = false;

  // Counting pointers (number of user fingers on screen)
  int _pointers = 0;

  XFile? imageFile;
  XFile? videoFile;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void initCamera() {
    availableCameras().then((availableCameras) {
      cameras = availableCameras;
      if (cameras.length > 0) {
        onNewCameraSelected(cameras.first);
      } else {
        print("No camera available");
      }
    });

  }

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = controller;

    // Instantiating the camera controller
    final CameraController cameraController = CameraController(
      cameraDescription,
      currentResolutionPreset,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    //initializeCameraControllerFuture = cameraController.initialize();

    // Dispose the previous controller
    await previousCameraController?.dispose();

    // Replace with the new controller
    if (mounted) {
      setState(() {
        controller = cameraController;
      });
    }

    // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    // Initialize controller
    try {
      await cameraController.initialize();

      if (!kIsWeb) {
        await Future.wait([
          cameraController
              .getMinExposureOffset()
              .then((value) => _minAvailableExposureOffset = value),
          cameraController
              .getMaxExposureOffset()
              .then((value) => _maxAvailableExposureOffset = value),
          cameraController
              .getMaxZoomLevel()
              .then((value) => _maxAvailableZoom = value),
          cameraController
              .getMinZoomLevel()
              .then((value) => _minAvailableZoom = value),

          //initializeCameraControllerFuture = cameraController.initialize(),
        ]);
        _currentFlashMode = controller!.value.flashMode;
      }
    } on CameraException catch (e) {
      print('Error initializing camera: $e');
    }
    // Update the boolean
    if (mounted) {
      setState(() {
        _isCameraInitialized = controller!.value.isInitialized;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      // Free up memory when camera not active
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize the camera with same properties
      onNewCameraSelected(cameraController.description);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(key: _scaffoldKey, body: createCameraScreen());
  }

  Widget createCameraScreen() {
    return SafeArea(
        child: Scaffold(
            body: _isCameraInitialized
                //body:true
                ? Center(
                    child: Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: Stack(fit: StackFit.expand, children: [
                          //This container is for Camera Preview
                          Container(
                              //width: MediaQuery.of(context).size.width,
                              //height: MediaQuery.of(context).size.height - 200,
                              color: Colors.red,
                              child: createCameraPreview()),

                          //This container is for Flash Buttons
                          Positioned(
                              top: 0,
                              child: Container(
                                  padding: EdgeInsets.all(15.0),
                                  width: MediaQuery.of(context).size.width,
                                  height: 150,
                                  //color: Colors.deepPurple,
                                  child: Column(children: [
                                    createFlashButtonRow(),
                                    createCameraZoomSlider(),
                                  ]))),

                          //This container is for Camera Exposure Slider
                          Positioned(
                              right: 0,
                              top: 50,
                              child: Container(
                                width: 50,
                                height:
                                    MediaQuery.of(context).size.height - 100,
                                //color: Colors.amber,
                                child: createCameraExposureSlider(),
                              )),

                          //This container is for Camera Zoom Slider
                          Positioned(
                              bottom: 0,
                              child: Container(
                                  padding: EdgeInsets.all(0.0),
                                  width: MediaQuery.of(context).size.width,
                                  height: 130,
                                  //color: Colors.deepPurple,
                                  child: Column(
                                    children: [
                                      _isVideoCameraSelected
                                          ? createVideoToggleButton()
                                          : createCameraToggleButton(),
                                      createCameraBottomBar()
                                    ],
                                  )))
                        ])))
                : Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    color: Colors.black,
                    child: Center(child: CircularProgressIndicator()))));
  }

  Widget createCameraPreview() {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return const Text(
        'Tap a camera',
        style: TextStyle(
            color: Colors.white, fontSize: 24.0, fontWeight: FontWeight.w900),
      );
    } else {
      return Listener(
        onPointerDown: (_) => _currentZoomLevel++,
        onPointerUp: (_) => _currentZoomLevel--,
        child: CameraPreview(
          controller!,
          child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onScaleStart: _handleScaleStart,
              onScaleUpdate: _handleScaleUpdate,
              onTapDown: (details) => onViewFinderTap(details, constraints),
            );
          }),
        ),
      );
    }
  }

  Widget createCameraQualityDropDown() {
    return DropdownButton<ResolutionPreset>(
      dropdownColor: Colors.black87,
      underline: Container(),
      value: currentResolutionPreset,
      items: [
        for (ResolutionPreset preset in resolutionPresets)
          DropdownMenuItem(
            child: Text(
              preset.toString().split('.')[1].toUpperCase(),
              style: TextStyle(color: Colors.white),
            ),
            value: preset,
          )
      ],
      onChanged: (value) {
        setState(() {
          currentResolutionPreset = value!;
          _isCameraInitialized = false;
        });
        onNewCameraSelected(controller!.description);
      },
      hint: Text("Select item"),
    );
  }

  Widget createCameraZoomSlider() {
    return Expanded(
        flex: 1,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Slider(
              value: _currentZoomLevel,
              min: _minAvailableZoom,
              max: _maxAvailableZoom,
              activeColor: Colors.blue,
              inactiveColor: Colors.white30,
              onChanged: (value) async {
                setState(() {
                  _currentZoomLevel = value;
                });
                await controller!.setZoomLevel(value);
              },
            ),
            Text(
              _currentZoomLevel.toStringAsFixed(1) + 'x',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ));
  }

  Widget createCameraExposureSlider() {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      RotatedBox(
        quarterTurns: 3,
        child: Container(
          height: 80,
          child: Slider(
            value: _currentExposureOffset,
            min: _minAvailableExposureOffset,
            max: _maxAvailableExposureOffset,
            activeColor: Colors.blue,
            inactiveColor: Colors.white30,
            onChanged: (value) async {
              setState(() {
                _currentExposureOffset = value;
              });
              await controller!.setExposureOffset(value);
            },
          ),
        ),
      ),
      Text(
        _currentExposureOffset.toStringAsFixed(1) + 'x',
        style: TextStyle(color: Colors.white),
      )
    ]);
  }

  Widget createFlashButtonRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        InkWell(
          onTap: () async {
            setState(() {
              _currentFlashMode = FlashMode.always;
            });
            await controller!.setFlashMode(
              FlashMode.always,
            );
          },
          child: Icon(
            Icons.flash_on,
            color: _currentFlashMode == FlashMode.always
                ? Colors.amber
                : Colors.white,
          ),
        ),
        InkWell(
          onTap: () async {
            setState(() {
              _currentFlashMode = FlashMode.off;
            });
            await controller!.setFlashMode(
              FlashMode.off,
            );
          },
          child: Icon(
            Icons.flash_off,
            color: _currentFlashMode == FlashMode.off
                ? Colors.amber
                : Colors.white,
          ),
        ),
        InkWell(
          onTap: () async {
            setState(() {
              _currentFlashMode = FlashMode.auto;
            });
            await controller!.setFlashMode(
              FlashMode.auto,
            );
          },
          child: Icon(
            Icons.flash_auto,
            color: _currentFlashMode == FlashMode.auto
                ? Colors.amber
                : Colors.white,
          ),
        ),
        InkWell(
          onTap: () async {
            setState(() {
              _currentFlashMode = FlashMode.torch;
            });
            await controller!.setFlashMode(
              FlashMode.torch,
            );
          },
          child: Icon(
            Icons.highlight,
            color: _currentFlashMode == FlashMode.torch
                ? Colors.amber
                : Colors.white,
          ),
        ),
        createCameraQualityDropDown(),
      ],
    );
  }

  Widget createCameraToggleButton() {
    return Container(
        color: Colors.black12,
        padding: EdgeInsets.all(12.0),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              MaterialButton(
                shape: CircleBorder(),
                child: Icon(
                  _isRearCameraSelected
                      ? Icons.camera_rear
                      : Icons.camera_front,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: () {
                  setState(() {
                    _isCameraInitialized = false;
                  });
                  onNewCameraSelected(
                    cameras[_isRearCameraSelected ? 0 : 1],
                  );
                  setState(() {
                    _isRearCameraSelected = !_isRearCameraSelected;
                  });
                },
              ),
              MaterialButton(
                child: Icon(
                  Icons.circle,
                  color: Colors.white,
                  size: 60,
                ),
                onPressed: () {
                  takePicture();
                },
              ),
              MaterialButton(
                child: imageFile != null
                    //child: true
                    ? CircleAvatar(
                        backgroundImage: FileImage(File(imageFile!.path)),
                        radius: 30,
                      )
                    : Icon(
                        Icons.image,
                        color: Colors.white,
                        size: 30,
                      ),
                onPressed: () {},
              )
            ]));
  }

  Widget createVideoToggleButton() {
    return Container(
        color: Colors.black12,
        padding: EdgeInsets.all(12.0),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              MaterialButton(
                shape: CircleBorder(),
                child: Icon(
                  _isRearCameraSelected
                      ? Icons.camera_rear
                      : Icons.camera_front,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: () {
                  setState(() {
                    _isCameraInitialized = false;
                  });
                  onNewCameraSelected(
                    cameras[_isRearCameraSelected ? 0 : 1],
                  );
                  setState(() {
                    _isRearCameraSelected = !_isRearCameraSelected;
                  });
                },
              ),
              MaterialButton(
                child: controller!.value.isRecordingVideo
                    //child: true
                    ? Icon(
                        Icons.circle_rounded,
                        color: Colors.red,
                        size: 60,
                      )
                    : Icon(
                        Icons.video_camera_front,
                        color: Colors.white,
                        size: 60,
                      ),
                onPressed: () async {
                  if (!controller!.value.isRecordingVideo) {
                    startVideoRecording();
                  } else {
                    onStopButtonPressed();
                  }
                },
              ),
              MaterialButton(
                child: controller!.value.isRecordingVideo
                    //child: true
                    ? Icon(
                        Icons.image,
                        color: Colors.red,
                        size: 30,
                      )
                    : Icon(
                        Icons.image,
                        color: Colors.white,
                        size: 30,
                      ),
                onPressed: () {},
              )
            ]));
  }

  Widget createCameraBottomBar() {
    return Container(
        color: Colors.black38,
        padding: EdgeInsets.all(8.0),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              MaterialButton(
                  child: _isVideoCameraSelected
                      ? Icon(
                          Icons.camera_alt,
                          color: Colors.grey,
                          size: 30,
                        )
                      : Icon(
                          Icons.camera_alt,
                          color: Colors.amber,
                          size: 30,
                        ),
                  onPressed: () async {
                    setState(() {
                      _isVideoCameraSelected = false;
                    });
                  }),
              MaterialButton(
                child: _isVideoCameraSelected
                    //child: true
                    ? Icon(
                        Icons.video_camera_back,
                        color: Colors.amber,
                        size: 30,
                      )
                    : Icon(
                        Icons.video_camera_back,
                        color: Colors.grey,
                        size: 30,
                      ),
                onPressed: () {
                  setState(() {
                    _isVideoCameraSelected = true;
                  });
                },
              ),
            ]));
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _minAvailableZoom = _currentZoomLevel;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (controller == null || _pointers != 2) {
      return;
    }

    _currentZoomLevel = (_minAvailableZoom * details.scale)
        .clamp(_minAvailableZoom, _maxAvailableZoom);

    await controller!.setZoomLevel(_currentZoomLevel);
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) {
      return;
    }

    final CameraController cameraController = controller!;

    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController.setExposurePoint(offset);
    cameraController.setFocusPoint(offset);
  }

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;
    if (cameraController!.value.isTakingPicture) {
      return null;
    }

    try {
      XFile xFile = await cameraController.takePicture();

      if (xFile == null) {
        return Future.value(null);
      }

      final directory = await getApplicationDocumentsDirectory();
      String path = directory.path;
      String fileToBeSaved = '$path/' + DateTime.now().toString() + '.png';
      xFile.saveTo(fileToBeSaved);

      setState(() {
        imageFile = xFile;
      });

      return xFile;
    } on CameraException catch (e) {
      print('Error occured whilte taking picture: $e');
      return null;
    }
  }

  void onVideoRecordButtonPressed() {
    startVideoRecording().then((_) {
      if (mounted) setState(() {});
    });
  }

  void onStopButtonPressed() {
    stopVideoRecording().then((videoFile) {
      if (mounted) setState(() {});
      if (videoFile != null) {
        //_startVideoPlayer();

      }
    });
  }

  Future<void> startVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return;
    }

    if (cameraController.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return;
    }

    try {
      await cameraController.startVideoRecording();
    } on CameraException catch (e) {
      showInSnackBar(e.description.toString());
      return;
    }
  }

  Future<XFile?> stopVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      XFile xFile = await cameraController.stopVideoRecording();

      if (xFile == null) {
        return Future.value(null);
      }

      final directory = await getApplicationDocumentsDirectory();
      String path = directory.path;
      String fileToBeSaved = '$path/' + DateTime.now().toString() + '.mp4';
      xFile.saveTo(fileToBeSaved);

      setState(() {
        videoFile = xFile;
      });

      return xFile;
    } on CameraException catch (e) {
      print('Error occured whilte taking picture: $e');
      return null;
    }
  }

  Future<void> pauseVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      await cameraController.pauseVideoRecording();
    } on CameraException catch (e) {
      showInSnackBar(e.description.toString());
      rethrow;
    }
  }

  Future<void> resumeVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      await cameraController.resumeVideoRecording();
    } on CameraException catch (e) {
      showInSnackBar(e.description.toString());
      rethrow;
    }
  }

  void showInSnackBar(String message) {
    _scaffoldKey.currentState?.showSnackBar(SnackBar(content: Text(message)));
  }
}
