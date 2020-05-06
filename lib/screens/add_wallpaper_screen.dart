import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

class AddWallpaperPage extends StatefulWidget {
  @override
  _AddWallpaperPageState createState() => _AddWallpaperPageState();
}

class _AddWallpaperPageState extends State<AddWallpaperPage> {
  File _image;

  final ImageLabeler labeler = FirebaseVision.instance.imageLabeler();

  List<ImageLabel> detectedLabels;

  @override
  void dispose() {
    labeler.close();
    super.dispose();
  }

  void _loadImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(image);

    List<ImageLabel> labels = await labeler.processImage(visionImage);

    setState(() {
      _image = image;
      detectedLabels = labels;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Wallpaper'),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: <Widget>[
              InkWell(
                onTap: _loadImage,
                child: _image != null
                    ? Image.file(_image)
                    : Image(
                        image: AssetImage("assets/placeholder.jpg"),
                      ),
              ),
              Text("Click on image to upload wallpaper"),
              SizedBox(
                height: 20,
              ),
              detectedLabels != null
                  ? Wrap(
                      children: detectedLabels.map((label) {
                        return Chip(
                          label: Text(label.text),
                        );
                      }).toList(),
                    )
                  : Container()
            ],
          ),
          width: MediaQuery.of(context).size.width,
        ),
      ),
    );
  }
}
