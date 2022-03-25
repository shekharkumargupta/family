import 'package:family/view/MediaList.dart';
import 'package:family/view/PeopleList.dart';
import 'package:family/view/PostList.dart';
import 'package:flutter/material.dart';

class MainTab extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MainTabState();
  }
}

class MainTabState extends State<MainTab> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData.light(),
        home: DefaultTabController(
          length: 3,
          child: new Scaffold(
            body: new NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  new SliverAppBar(
                    title: Text("Smile"),
                    floating: true,
                    pinned: true,
                    snap: true,
                    bottom: new TabBar(
                      tabs: <Tab>[
                        Tab(icon: Icon(Icons.messenger)),
                        Tab(icon: Icon(Icons.people)),
                        Tab(icon: Icon(Icons.perm_media))
                      ], // <-- total of 2 tabs
                    ),
                  ),
                ];
              },
              body: new TabBarView(
                children: <Widget>[
                  Center(
                    child: PostList(),
                  ),
                  Center(child: PeopleList()),
                  Center(
                    child: MediaList(),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
