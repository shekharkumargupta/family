

import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class StorageUtil {


  Future<String> createFolder(String cow) async {
    final folderName = cow;
    final path = Directory("storage/emulated/0/$folderName");
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    if ((await path.exists())) {
      return path.path;
    } else {
      path.create();
      return path.path;
    }
  }


}