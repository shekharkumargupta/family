import 'dart:async';

import 'package:flutter/material.dart';

class ImageWidget {

  //'https://picsum.photos/900/600';

  ImageWidget();

  Future<Widget> createImageWidget(String imageUrl) async {
      final Completer<Widget> completer = Completer();
      final url = imageUrl;
      final image = NetworkImage(url);
      // final config = await image.obtainKey();
      final load = image.resolve(const ImageConfiguration());

      final listener = new ImageStreamListener((ImageInfo info, isSync) async {
        print(info.image.width);
        print(info.image.height);

        if (info.image.width == 80 && info.image.height == 160) {
          completer.complete(Container(child: Text('AZAZA')));
        } else {
          completer.complete(Container(child: Image(image: image)));
        }
      });

      load.addListener(listener);
      return completer.future;
  }
}