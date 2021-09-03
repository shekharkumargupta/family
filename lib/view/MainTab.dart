import 'package:flutter/material.dart';
import 'package:family/view/MediaList.dart';
import 'package:family/view/PeopleList.dart';
import 'package:family/view/PostList.dart';

import 'PostForm.dart';

class MainTab extends StatelessWidget {

  int selectedTabIndex = 0;

  @override
  Widget build(BuildContext context){
    return MaterialApp(
        home: DefaultTabController(
          length: 3,
          child: new Scaffold(
            body: new NestedScrollView(
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
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
                  Center(
                    child: PeopleList()
                  ),
                  Center(
                    child: MediaList(),
                  )
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: (){
                //print('Current index ${DefaultTabController.of(context).index}');
                print('Current index ${selectedTabIndex}');

                Navigator.push(context,
                  MaterialPageRoute(builder: (context) => PostForm()),
                );
              },
              child: const Icon(Icons.camera),
              backgroundColor: Colors.indigo,
            ),
          ),
        )
    );
  }

  /*
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        initialIndex: selectedTabIndex,
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.messenger)),
                Tab(icon: Icon(Icons.people)),
                Tab(icon: Icon(Icons.perm_media))
              ],
              onTap: (tabIndex) => {
                  selectedTabIndex = tabIndex
              },
            ),
            title: Text('Family'),
          ),

          body: TabBarView(
            children: [
              PostList(),
              PeopleList(),
              MediaList()
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: (){
                //print('Current index ${DefaultTabController.of(context).index}');
                print('Current index ${selectedTabIndex}');

                Navigator.push(context,
                  MaterialPageRoute(builder: (context) => PostForm()),
                );
            },
            child: const Icon(Icons.camera),
            backgroundColor: Colors.indigo,
          ),
        ),
      ),
    );
  }
  */


}
