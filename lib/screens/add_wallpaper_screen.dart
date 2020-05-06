import 'package:flutter/material.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

class AddWallpaperPage extends StatefulWidget {
  @override
  _AddWallpaperPageState createState() => _AddWallpaperPageState();
}

class _AddWallpaperPageState extends State<AddWallpaperPage> {
  File _image;

  void _loadImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
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
            ],
          ),
          width: MediaQuery.of(context).size.width,
        ),
      ),
    );
  }
}
