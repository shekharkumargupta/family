import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class TakePictureScreenWidget extends StatefulWidget {

  final List<CameraDescription> cameras;
  final CameraDescription firstCamera;

  const TakePictureScreenWidget({
    Key key,
    this.cameras,
    this.firstCamera
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();

  /// Returns a suitable camera icon for [direction].
  IconData getCameraLensIcon(CameraLensDirection direction) {
    switch (direction) {
      case CameraLensDirection.back:
        return Icons.camera_rear;
      case CameraLensDirection.front:
        return Icons.camera_front;
      case CameraLensDirection.external:
        return Icons.camera;
      default:
        throw ArgumentError('Unknown lens direction');
    }
  }

  void logError(String code, String message) {
    if (message != null) {
      print('Error: $code\nError Message: $message');
    } else {
      print('Error: $code');
    }
  }
}

class TakePictureScreenState extends State<TakePictureScreenWidget>
    with WidgetsBindingObserver, TickerProviderStateMixin {

  CameraController controller;
  Future<void> _initializeControllerFuture;

  XFile imageFile;
  XFile videoFile;
  VideoPlayerController videoController;
  VoidCallback videoPlayerListener;
  bool enableAudio = true;
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _currentExposureOffset = 0.0;
  AnimationController _flashModeControlRowAnimationController;
  Animation<double> _flashModeControlRowAnimation;
  AnimationController _exposureModeControlRowAnimationController;
  Animation<double> _exposureModeControlRowAnimation;
  AnimationController _focusModeControlRowAnimationController;
  Animation<double> _focusModeControlRowAnimation;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentScale = 1.0;
  double _baseScale = 1.0;

  // Counting pointers (number of user fingers on screen)
  int _pointers = 0;

  T _ambiguate<T>(T value) => value;

  @override
  void initState() {
    super.initState();
    _ambiguate(WidgetsBinding.instance)?.addObserver(this);


    controller = CameraController(
      widget.firstCamera,
      ResolutionPreset.medium,
    );
    //_initializeControllerFuture = controller.initialize();



    _flashModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _flashModeControlRowAnimation = CurvedAnimation(
      parent: _flashModeControlRowAnimationController,
      curve: Curves.easeInCubic,
    );
    _exposureModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _exposureModeControlRowAnimation = CurvedAnimation(
      parent: _exposureModeControlRowAnimationController,
      curve: Curves.easeInCubic,
    );
    _focusModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _focusModeControlRowAnimation = CurvedAnimation(
      parent: _focusModeControlRowAnimationController,
      curve: Curves.easeInCubic,
    );

  }

  @override
  void dispose() {
    _ambiguate(WidgetsBinding.instance)?.removeObserver(this);
    _flashModeControlRowAnimationController.dispose();
    _exposureModeControlRowAnimationController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController.description);
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Camera example'),
      ),

      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: Center(
                  child: _cameraPreviewWidget(),
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(
                  color:
                      controller != null && controller.value.isRecordingVideo
                          ? Colors.redAccent
                          : Colors.grey,
                  width: 3.0,
                ),
              ),
            ),
          ),

          _captureControlRowWidget(),
          _modeControlRowWidget(),

          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                _cameraTogglesRowWidget(),
                _thumbnailWidget(),
              ],
            ),
          ),


        ],
      ),
    );
  }

  Widget _cameraPreviewWidget() {
    CameraController cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return const Text(
        'Tap a camera',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return Listener(
        onPointerDown: (_) => _pointers++,
        onPointerUp: (_) => _pointers--,
        child: CameraPreview(
          controller,
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

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (controller == null || _pointers != 2) {
      return;
    }

    _currentScale = (_baseScale * details.scale)
        .clamp(_minAvailableZoom, _maxAvailableZoom);

    await controller.setZoomLevel(_currentScale);
  }

  /// Display the thumbnail of the captured image or video.
  Widget _thumbnailWidget() {
    final VideoPlayerController localVideoController = videoController;

    return Expanded(
      child: Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            localVideoController == null && imageFile == null
                ? Container()
                : SizedBox(
                    child: (localVideoController == null)
                        ? Image.file(File(imageFile.path))
                        : Container(
                            child: Center(
                              child: AspectRatio(
                                  aspectRatio:
                                      localVideoController.value.size != null
                                          ? localVideoController
                                              .value.aspectRatio
                                          : 1.0,
                                  child: VideoPlayer(localVideoController)),
                            ),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.pink)),
                          ),
                    width: 64.0,
                    height: 64.0,
                  ),
          ],
        ),
      ),
    );
  }

  /// Display a bar with buttons to change the flash and exposure modes
  Widget _modeControlRowWidget() {

    CameraController cameraController = controller;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.flash_on),
              color: Colors.blue,
              onPressed: cameraController != null ? onFlashModeButtonPressed : null,
            ),
            IconButton(
              icon: Icon(Icons.exposure),
              color: Colors.blue,
              onPressed:
              cameraController != null ? onExposureModeButtonPressed : null,
            ),
            IconButton(
              icon: Icon(Icons.filter_center_focus),
              color: Colors.blue,
              onPressed: cameraController != null ? onFocusModeButtonPressed : null,
            ),
            IconButton(
              icon: Icon(enableAudio ? Icons.volume_up : Icons.volume_mute),
              color: Colors.blue,
              onPressed: cameraController != null ? onAudioModeButtonPressed : null,
            ),
            IconButton(
              icon: Icon(cameraController.value.isCaptureOrientationLocked
                  ? Icons.screen_lock_rotation
                  : Icons.screen_rotation),
              color: Colors.blue,
              onPressed: cameraController != null
                  ? onCaptureOrientationLockButtonPressed
                  : null,
            ),
          ],
        ),
        _flashModeControlRowWidget(),
        _exposureModeControlRowWidget(),
        _focusModeControlRowWidget(),
      ],
    );
  }

  Widget _flashModeControlRowWidget() {

    CameraController cameraController = controller;

    /*
    return SizeTransition(
      sizeFactor: _flashModeControlRowAnimation,
      child: ClipRect(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: [
            IconButton(
              icon: Icon(Icons.flash_off),
              color: controller.value.flashMode == FlashMode.off
                  ? Colors.orange
                  : Colors.blue,
              onPressed: controller != null
                  ? () => onSetFlashModeButtonPressed(FlashMode.off)
                  : null,
            ),
            IconButton(
              icon: Icon(Icons.flash_auto),
              color: controller.value.flashMode == FlashMode.auto
                  ? Colors.orange
                  : Colors.blue,
              onPressed: controller != null
                  ? () => onSetFlashModeButtonPressed(FlashMode.auto)
                  : null,
            ),
            IconButton(
              icon: Icon(Icons.flash_on),
              color: controller.value.flashMode == FlashMode.always
                  ? Colors.orange
                  : Colors.blue,
              onPressed: controller != null
                  ? () => onSetFlashModeButtonPressed(FlashMode.always)
                  : null,
            ),
            IconButton(
              icon: Icon(Icons.highlight),
              color: controller.value.flashMode == FlashMode.torch
                  ? Colors.orange
                  : Colors.blue,
              onPressed: controller != null
                  ? () => onSetFlashModeButtonPressed(FlashMode.torch)
                  : null,
            ),
          ],
        ),
      ),
    );
    */



    return ClipRect(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        children: [
          IconButton(
            icon: Icon(Icons.flash_off),
            color: cameraController.value.flashMode == FlashMode.off
                ? Colors.orange
                : Colors.blue,
            onPressed: cameraController != null
                ? () => onSetFlashModeButtonPressed(FlashMode.off)
                : null,
          ),
          IconButton(
            icon: Icon(Icons.flash_auto),
            color: cameraController.value.flashMode == FlashMode.auto
                ? Colors.orange
                : Colors.blue,
            onPressed: controller != null
                ? () => onSetFlashModeButtonPressed(FlashMode.auto)
                : null,
          ),
          IconButton(
            icon: Icon(Icons.flash_on),
            color: cameraController.value.flashMode == FlashMode.always
                ? Colors.orange
                : Colors.blue,
            onPressed: cameraController != null
                ? () => onSetFlashModeButtonPressed(FlashMode.always)
                : null,
          ),
          IconButton(
            icon: Icon(Icons.highlight),
            color: cameraController.value.flashMode == FlashMode.torch
                ? Colors.orange
                : Colors.blue,
            onPressed: cameraController != null
                ? () => onSetFlashModeButtonPressed(FlashMode.torch)
                : null,
          ),
        ],
      ),
    );

  }

  Widget _exposureModeControlRowWidget() {

    CameraController cameraController = controller;

    final ButtonStyle styleAuto = TextButton.styleFrom(
      primary: cameraController.value.exposureMode == ExposureMode.auto
          ? Colors.orange
          : Colors.blue,
    );
    final ButtonStyle styleLocked = TextButton.styleFrom(
      primary: cameraController.value.exposureMode == ExposureMode.locked
          ? Colors.orange
          : Colors.blue,
    );

    return SizeTransition(
      sizeFactor: _exposureModeControlRowAnimation,
      child: ClipRect(
        child: Container(
          color: Colors.grey.shade50,
          child: Column(
            children: [
              Center(
                child: Text("Exposure Mode"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: [
                  TextButton(
                    child: Text('AUTO'),
                    style: styleAuto,
                    onPressed: cameraController != null
                        ? () =>
                            onSetExposureModeButtonPressed(ExposureMode.auto)
                        : null,
                    onLongPress: () {
                      if (cameraController != null) {
                        cameraController.setExposurePoint(null);
                        showInSnackBar('Resetting exposure point');
                      }
                    },
                  ),
                  TextButton(
                    child: Text('LOCKED'),
                    style: styleLocked,
                    onPressed: controller != null
                        ? () =>
                            onSetExposureModeButtonPressed(ExposureMode.locked)
                        : null,
                  ),
                  TextButton(
                    child: Text('RESET OFFSET'),
                    style: styleLocked,
                    onPressed: cameraController != null
                        ? () => cameraController.setExposureOffset(0.0)
                        : null,
                  ),
                ],
              ),
              Center(
                child: Text("Exposure Offset"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(_minAvailableExposureOffset.toString()),
                  Slider(
                    value: _currentExposureOffset,
                    min: _minAvailableExposureOffset,
                    max: _maxAvailableExposureOffset,
                    label: _currentExposureOffset.toString(),
                    onChanged: _minAvailableExposureOffset ==
                            _maxAvailableExposureOffset
                        ? null
                        : setExposureOffset,
                  ),
                  Text(_maxAvailableExposureOffset.toString()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _focusModeControlRowWidget() {

    CameraController cameraController = controller;

    final ButtonStyle styleAuto = TextButton.styleFrom(
      primary: cameraController.value.focusMode == FocusMode.auto
          ? Colors.orange
          : Colors.blue,
    );
    final ButtonStyle styleLocked = TextButton.styleFrom(
      primary: cameraController.value.focusMode == FocusMode.locked
          ? Colors.orange
          : Colors.blue,
    );

    return SizeTransition(
      sizeFactor: _focusModeControlRowAnimation,
      child: ClipRect(
        child: Container(
          color: Colors.grey.shade50,
          child: Column(
            children: [
              Center(
                child: Text("Focus Mode"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: [
                  TextButton(
                    child: Text('AUTO'),
                    style: styleAuto,
                    onPressed: cameraController != null
                        ? () => onSetFocusModeButtonPressed(FocusMode.auto)
                        : null,
                    onLongPress: () {
                      if (cameraController != null) cameraController.setFocusPoint(null);
                      showInSnackBar('Resetting focus point');
                    },
                  ),
                  TextButton(
                    child: Text('LOCKED'),
                    style: styleLocked,
                    onPressed: cameraController != null
                        ? () => onSetFocusModeButtonPressed(FocusMode.locked)
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Display the control bar with buttons to take pictures and record videos.
  Widget _captureControlRowWidget() {
    final CameraController cameraController = controller;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.camera_alt),
          color: Colors.blue,
          onPressed: cameraController != null &&
                  cameraController.value.isInitialized &&
                  !cameraController.value.isRecordingVideo
              ? onTakePictureButtonPressed
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.videocam),
          color: Colors.blue,
          onPressed: cameraController != null &&
                  cameraController.value.isInitialized &&
                  !cameraController.value.isRecordingVideo
              ? onVideoRecordButtonPressed
              : null,
        ),
        IconButton(
          icon: cameraController != null &&
                  cameraController.value.isRecordingPaused
              ? Icon(Icons.play_arrow)
              : Icon(Icons.pause),
          color: Colors.blue,
          onPressed: cameraController != null &&
                  cameraController.value.isInitialized &&
                  cameraController.value.isRecordingVideo
              ? (cameraController.value.isRecordingPaused)
                  ? onResumeButtonPressed
                  : onPauseButtonPressed
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.stop),
          color: Colors.red,
          onPressed: cameraController != null &&
                  cameraController.value.isInitialized &&
                  cameraController.value.isRecordingVideo
              ? onStopButtonPressed
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.pause_presentation),
          color:
              cameraController != null && cameraController.value.isRecordingPaused
                  ? Colors.red
                  : Colors.blue,
          onPressed:
              cameraController == null ? null : onPausePreviewButtonPressed,
        ),
      ],
    );
  }

  /// Display a row of toggle to select the camera (or a message if no camera is available).
  Widget _cameraTogglesRowWidget() {

    CameraController cameraController = controller;

    final List<Widget> toggles = <Widget>[];

    final onChanged = (CameraDescription description) {
      if (description == null) {
        return;
      }
      onNewCameraSelected(description);
    };

    /*
    if (widget.cameras.isEmpty) {
      return const Text('No camera found');
    } else {
      for (CameraDescription cameraDescription in widget.cameras) {
        toggles.add(
          SizedBox(
            width: 90.0,
            child: RadioListTile<CameraDescription>(
              title: Icon(widget.getCameraLensIcon(cameraDescription.lensDirection)),
              groupValue: cameraController.description,
              value: cameraDescription,
              onChanged: onChanged(cameraDescription)
            ),
          ),
        );
      }
    }*/


    toggles.add(
      SizedBox(
        width: 90.0,
        child: RadioListTile<CameraDescription>(
            title: Icon(Icons.filter_center_focus),
            groupValue: cameraController.description,
            value: cameraController.description,
            onChanged: onChanged(cameraController.description)
        ),
      ),
    );


    return Row(children: toggles);
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    // ignore: deprecated_member_use
    _scaffoldKey.currentState?.showSnackBar(SnackBar(content: Text(message)));
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) {
      return;
    }

    final CameraController cameraController = controller;

    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController.setExposurePoint(offset);
    cameraController.setFocusPoint(offset);
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {

    if (controller != null) {
      await controller.dispose();
    }

    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
      enableAudio: enableAudio,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    controller = cameraController;

    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      if (mounted) setState(() {});
      if (cameraController.value.hasError) {
        showInSnackBar(
            'Camera error ${cameraController.value.errorDescription}');
      }
    });

    try {
      await cameraController.initialize();
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
      ]);
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onTakePictureButtonPressed() {
    takePicture().then((XFile file) {
      if (mounted) {
        setState(() {
          imageFile = file;
          videoController.dispose();
        });
        if (file != null) showInSnackBar('Picture saved to ${file.path}');
      }
    });
  }

  void onFlashModeButtonPressed() {
    if (_flashModeControlRowAnimationController.value == 1) {
      _flashModeControlRowAnimationController.reverse();
    } else {
      _flashModeControlRowAnimationController.forward();
      _exposureModeControlRowAnimationController.reverse();
      _focusModeControlRowAnimationController.reverse();
    }
  }

  void onExposureModeButtonPressed() {
    if (_exposureModeControlRowAnimationController.value == 1) {
      _exposureModeControlRowAnimationController.reverse();
    } else {
      _exposureModeControlRowAnimationController.forward();
      _flashModeControlRowAnimationController.reverse();
      _focusModeControlRowAnimationController.reverse();
    }
  }

  void onFocusModeButtonPressed() {
    if (_focusModeControlRowAnimationController.value == 1) {
      _focusModeControlRowAnimationController.reverse();
    } else {
      _focusModeControlRowAnimationController.forward();
      _flashModeControlRowAnimationController.reverse();
      _exposureModeControlRowAnimationController.reverse();
    }
  }

  void onAudioModeButtonPressed() {
    enableAudio = !enableAudio;
    if (controller != null) {
      onNewCameraSelected(controller.description);
    }
  }

  void onCaptureOrientationLockButtonPressed() async {
    if (controller != null) {
      final CameraController cameraController = controller;
      if (cameraController.value.isCaptureOrientationLocked) {
        await cameraController.unlockCaptureOrientation();
        showInSnackBar('Capture orientation unlocked');
      } else {
        await cameraController.lockCaptureOrientation();
        showInSnackBar(
            'Capture orientation locked to ${cameraController.value.lockedCaptureOrientation.toString().split('.').last}');
      }
    }
  }

  void onSetFlashModeButtonPressed(FlashMode mode) {
    setFlashMode(mode).then((_) {
      if (mounted) setState(() {});
      showInSnackBar('Flash mode set to ${mode.toString().split('.').last}');
    });
  }

  void onSetExposureModeButtonPressed(ExposureMode mode) {
    setExposureMode(mode).then((_) {
      if (mounted) setState(() {});
      showInSnackBar('Exposure mode set to ${mode.toString().split('.').last}');
    });
  }

  void onSetFocusModeButtonPressed(FocusMode mode) {
    setFocusMode(mode).then((_) {
      if (mounted) setState(() {});
      showInSnackBar('Focus mode set to ${mode.toString().split('.').last}');
    });
  }

  void onVideoRecordButtonPressed() {
    startVideoRecording().then((_) {
      if (mounted) setState(() {});
    });
  }

  void onStopButtonPressed() {
    stopVideoRecording().then((file) {
      if (mounted) setState(() {});
      if (file != null) {
        showInSnackBar('Video recorded to ${file.path}');
        videoFile = file;
        _startVideoPlayer();
      }
    });
  }

  Future<void> onPausePreviewButtonPressed() async {
    final CameraController cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return;
    }

    if (cameraController.value.isRecordingPaused) {
      await cameraController.resumeVideoRecording();
    } else {
      await cameraController.stopVideoRecording();
    }

    if (mounted) setState(() {});
  }

  void onPauseButtonPressed() {
    pauseVideoRecording().then((_) {
      if (mounted) setState(() {});
      showInSnackBar('Video recording paused');
    });
  }

  void onResumeButtonPressed() {
    resumeVideoRecording().then((_) {
      if (mounted) setState(() {});
      showInSnackBar('Video recording resumed');
    });
  }

  Future<void> startVideoRecording() async {
    final CameraController cameraController = controller;

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
      _showCameraException(e);
      return;
    }
  }

  Future<XFile> stopVideoRecording() async {
    final CameraController cameraController = controller;
    try {
      return cameraController.stopVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return cameraController.takePicture();
    }
  }

  Future<void> pauseVideoRecording() async {
    final CameraController cameraController = controller;
    try {
      await cameraController.pauseVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> resumeVideoRecording() async {
    final CameraController cameraController = controller;
    try {
      await cameraController.resumeVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> setFlashMode(FlashMode mode) async {
    try {
      await controller.setFlashMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> setExposureMode(ExposureMode mode) async {
    try {
      await controller.setExposureMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> setExposureOffset(double offset) async {
    setState(() {
      _currentExposureOffset = offset;
    });
    try {
      offset = await controller.setExposureOffset(offset);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> setFocusMode(FocusMode mode) async {
    if (controller == null) {
      return;
    }

    try {
      await controller.setFocusMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> _startVideoPlayer() async {
    if (videoFile == null) {
      return;
    }

    final VideoPlayerController vController =
        VideoPlayerController.file(File(videoFile.path));
    videoPlayerListener = () {
      if (videoController != null && videoController.value.size != null) {
        // Refreshing the state to update video player with the correct ratio.
        if (mounted) setState(() {});
        videoController.removeListener(videoPlayerListener);
      }
    };
    vController.addListener(videoPlayerListener);
    await vController.setLooping(true);
    await vController.initialize();
    await videoController.dispose();
    if (mounted) {
      setState(() {
        //imageFile = null;
        videoController = vController;
      });
    }
    await vController.play();
  }

  Future<XFile> takePicture() async {
    final CameraController cameraController = controller;
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
      _showCameraException(e);
      return cameraController.takePicture();
    }
  }

  void _showCameraException(CameraException e) {
    //widget.logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }


}

