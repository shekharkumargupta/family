

import 'dart:io';

import 'package:camera/camera.dart';
//import 'package:permission_handler/permission_handler.dart';

class ApplicationStorageUtil {

  final String APPLICATION_DIRECTORY_NAME = "Family";
  late Directory directory;

  Future<String> createDirectory(String folderName) async {
    directory = Directory("storage/emulated/0/$folderName/");

    /*
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    */

    if ((await directory.exists())) {
      return directory.path;
    } else {
      await directory.create(recursive: true);
      return directory.path;
    }
  }

  Future<File> saveFile(XFile xFile, String fileType) async {
    String applicationDirectoryName = await createDirectory(APPLICATION_DIRECTORY_NAME);
    String fileName = applicationDirectoryName + getFileNameFromTime(fileType);

    File file = File(xFile.path);
    return file.copy(fileName);
  }

  Future<String> getFilePathToBeSaved(XFile xFile, String fileType) async {
    String applicationDirectoryName = await createDirectory(APPLICATION_DIRECTORY_NAME);
    String fileName = applicationDirectoryName + getFileNameFromTime(fileType);

    return Future.value(fileName);
  }


  String getFileNameFromTime(String fileType) {
    DateTime now = DateTime.now();
    String fileName = now.year.toString() +
        now.month.toString() +
        now.day.toString() +
        now.hour.toString() +
        now.minute.toString() +
        now.second.toString() +
        "." + fileType;
    return fileName;
  }

  String getApplicationDirectory(){
    return APPLICATION_DIRECTORY_NAME;
  }

}