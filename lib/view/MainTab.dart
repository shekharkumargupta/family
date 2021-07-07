import 'package:flutter/material.dart';
import 'package:family/view/MediaList.dart';
import 'package:family/view/PeopleList.dart';
import 'package:family/view/PostList.dart';

class MainTab extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
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
              onTap: (value) => print(value),
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
                print('Current index ${DefaultTabController.of(context).index}');
            },
            child: const Icon(Icons.add),
            backgroundColor: Colors.indigo,
          ),
        ),
      ),
    );
  }
}
