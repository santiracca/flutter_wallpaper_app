import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:wally_app/config/config.dart';
import 'package:wally_app/screens/add_wallpaper_screen.dart';
import 'package:wally_app/screens/wallpaper_view_screen.dart';

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser _user;
  final Firestore _db = Firestore.instance;

  // var images = [
  //   "https://images.pexels.com/photos/775483/pexels-photo-775483.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940",
  //   "https://images.pexels.com/photos/3326103/pexels-photo-3326103.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500",
  //   "https://images.pexels.com/photos/1927314/pexels-photo-1927314.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500",
  //   "https://images.pexels.com/photos/2085376/pexels-photo-2085376.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940",
  //   "https://images.pexels.com/photos/3377538/pexels-photo-3377538.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940",
  //   "https://images.pexels.com/photos/3381028/pexels-photo-3381028.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940",
  //   "https://images.pexels.com/photos/3389722/pexels-photo-3389722.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940"
  // ];

  // @override
  // void initState() {

  //   super.initState();
  // }

  @override
  void didChangeDependencies() {
    fetchUserData();
    super.didChangeDependencies();
  }

  void fetchUserData() async {
    final currentUser = await _auth.currentUser();
    setState(() {
      _user = currentUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: _user == null
            ? CircularProgressIndicator()
            : Column(
                children: <Widget>[
                  SizedBox(
                    height: 20,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: FadeInImage(
                      width: 200,
                      height: 200,
                      placeholder: AssetImage("assets/placeholder.png"),
                      fit: BoxFit.cover,
                      image: NetworkImage("${_user.photoUrl}"),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text("${_user.displayName}"),
                  RaisedButton(
                    onPressed: () {
                      _auth.signOut();
                    },
                    child: Text('Logout'),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("My Wallpapers"),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                fullscreenDialog: true,
                                builder: (context) => AddWallpaperPage(),
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  ),
                  StreamBuilder(
                    stream: _db
                        .collection("wallpapers")
                        .where("uploaded_by", isEqualTo: _user.uid)
                        .snapshots(),
                    builder: (ctx, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData) {
                        return StaggeredGridView.countBuilder(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          staggeredTileBuilder: (int index) =>
                              StaggeredTile.fit(1),
                          itemCount: snapshot.data.documents.length,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 20,
                          padding: EdgeInsets.symmetric(
                            horizontal: 15,
                          ),
                          itemBuilder: (ctx, index) {
                            return InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => WallpaperViewPage(
                                        heroId: snapshot
                                            .data.documents[index].documentID,
                                        image: snapshot
                                            .data.documents[index].data['url']),
                                  ),
                                );
                              },
                              child: Stack(
                                children: <Widget>[
                                  Hero(
                                    tag: snapshot
                                        .data.documents[index].documentID,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: CachedNetworkImage(
                                        placeholder: (context, url) => Image(
                                          image: AssetImage(
                                              "assets/placeholder.png"),
                                        ),
                                        imageUrl: snapshot
                                            .data.documents[index].data['url'],
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      _db
                                          .collection("wallpapers")
                                          .document(snapshot
                                              .data.documents[index].documentID)
                                          .delete();
                                    },
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                  )
                                ],
                              ),
                            );
                          },
                        );
                      }
                      return SpinKitCubeGrid(color: primaryColor);
                    },
                  ),
                ],
              ),
      ),
    );
  }
}
