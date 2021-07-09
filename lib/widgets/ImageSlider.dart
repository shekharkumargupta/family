import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:family/model/Media.dart';
import 'package:family/widgets/ImageWidget.dart';

class ImageSlider {

  ImageSlider();

  createImageSlider(List<Media> medias){
    return CarouselSlider(
      items: createImageSliderItems(medias),
      options: CarouselOptions(
        //height: 180.0,
        enlargeCenterPage: true,
        autoPlay: false,
        aspectRatio: 12 / 9,
        autoPlayCurve: Curves.fastOutSlowIn,
        enableInfiniteScroll: true,
        autoPlayAnimationDuration: Duration(milliseconds: 900),
        viewportFraction: 1.2,
      ),
    );
  }

  createImageSliderItems(List<Media> medias){
    List<Widget> widgetList = [];
    medias.forEach((media) {
      widgetList.add(createImageItem(media.url));
    });
    return widgetList;
  }

  createImageItem(String imageUrl){
    return Container(
      alignment: Alignment.center,
      child: FutureBuilder<Widget>(
        future: ImageWidget().createImageWidget(imageUrl),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return snapshot.data;
          } else {
            return LinearProgressIndicator(
              //backgroundColor: Colors.indigo,
            );
          }
        },
      ),
    );
  }

}