import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class WallpaperViewPage extends StatefulWidget {
  final String image;
  final String heroId;

  WallpaperViewPage({@required this.image, @required this.heroId});

  @override
  _WallpaperViewPageState createState() => _WallpaperViewPageState();
}

class _WallpaperViewPageState extends State<WallpaperViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: <Widget>[
              Container(
                child: Hero(
                  tag: widget.heroId,
                  child: CachedNetworkImage(
                    placeholder: (context, url) => Image(
                      image: AssetImage("assets/placeholder.png"),
                    ),
                    imageUrl: widget.image,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
