import 'package:flutter/material.dart';
import 'package:wally_app/screens/account_screen.dart';
import 'package:wally_app/screens/explore_screen.dart';
import 'package:wally_app/screens/favorites_screen.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectPageIndex = 0;

  var _pages = [ExplorePage(), FavoritesPage(), AccountPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WallyApp'),
      ),
      body: _pages[_selectPageIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            title: Text("Explore"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            title: Text("Favorites"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            title: Text("Account"),
          )
        ],
        currentIndex: _selectPageIndex,
        onTap: (index) {
          setState(() {
            _selectPageIndex = index;
          });
        },
      ),
    );
  }
}
