import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'main.dart';

/// TasksList class showing all tasks fetched from server
class TasksList extends StatefulWidget {
  const TasksList({Key? key}) : super(key: key);

  @override
  _TasksListState createState() => _TasksListState();
}

class _TasksListState extends State<TasksList> {
  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      ListTile(
        title: Text('TEST'),
        subtitle: Text('From 00 to 23'),
        trailing: Icon(Icons.done),
      ),
      for (var t in Provider.of<TimiState>(context).tasks)
        ListTile(
          title: Text('${t.title}'),
          subtitle: Text('From ${t.start_hour} to ${t.end_hour}'),
          trailing: (t.isInRange(Provider.of<TimiState>(context).mapLocation)) ? Icon(Icons.done) : null,
        )
    ]);
  }
}
