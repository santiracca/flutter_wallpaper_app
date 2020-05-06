import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

import 'package:image_picker/image_picker.dart';

class AddWallpaperPage extends StatefulWidget {
  @override
  _AddWallpaperPageState createState() => _AddWallpaperPageState();
}

class _AddWallpaperPageState extends State<AddWallpaperPage> {
  File _image;

  final ImageLabeler labeler = FirebaseVision.instance.imageLabeler();

  List<ImageLabel> detectedLabels;

  final Firestore _db = Firestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  bool _isUploading = false;
  bool _isCompletedUploading = false;

  List<String> labelsInString = [];

  @override
  void dispose() {
    labeler.close();
    super.dispose();
  }

  void _loadImage() async {
    var image = await ImagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 30,
    );
    final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(image);

    List<ImageLabel> labels = await labeler.processImage(visionImage);

    for (var i in labels) {
      labelsInString.add(i.text);
    }

    setState(() {
      _image = image;
      detectedLabels = labels;
    });
  }

  void _uploadWallpaper() async {
    if (_image != null) {
      String fileName = path.basename(_image.path);
      print(fileName);

      FirebaseUser user = await _auth.currentUser();
      String uid = user.uid;

      StorageUploadTask task = _storage
          .ref()
          .child("wallpapers")
          .child(uid)
          .child(fileName)
          .putFile(_image);

      task.events.listen((e) {
        if (e.type == StorageTaskEventType.progress) {
          setState(() {
            _isUploading = true;
          });
        }
        if (e.type == StorageTaskEventType.success) {
          e.snapshot.ref.getDownloadURL().then((url) {
            _db.collection("wallpapers").add({
              "url": url,
              "date": DateTime.now(),
              "uploaded_by": uid,
              "tags": labelsInString
            });
            Navigator.of(context).pop();
          });
          setState(() {
            _isUploading = false;
            _isCompletedUploading = true;
          });
        }
      });
    } else {
      showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              actions: <Widget>[
                RaisedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: Text("Ok"),
                )
              ],
              title: Text("Error"),
              content: Text("select image to upload"),
            );
          });
    }
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
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Wrap(
                        spacing: 10,
                        children: detectedLabels.map((label) {
                          return Chip(
                            label: Text(label.text),
                          );
                        }).toList(),
                      ),
                    )
                  : Container(),
              SizedBox(
                height: 40,
              ),
              if (_isUploading) ...[Text('Uploading wallpaper...')],
              if (_isCompletedUploading) ...[Text("Upload Completed")],
              SizedBox(
                height: 40,
              ),
              RaisedButton(
                onPressed: _uploadWallpaper,
                child: Text("Upload Wallpaper"),
              )
            ],
          ),
          width: MediaQuery.of(context).size.width,
        ),
      ),
    );
  }
}
