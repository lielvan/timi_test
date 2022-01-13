import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:timi_test/tasks_list.dart';
import 'package:timi_test/map.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimiState()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tasks Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Tasks Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int navIndex = 0;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    await Provider.of<TimiState>(context).fromJson();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: IndexedStack(
        index: navIndex,
        children: const <Widget>[
          TasksList(),
          GMap(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.sync),
        onPressed: () async {
          await Provider.of<TimiState>(context, listen: false).fromJson();
          setState(() {});
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: navIndex,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.view_list), label: 'Tasks'),
            BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          ],
          onTap: (int newIndex) {
            print(newIndex);
            setState(() {
              navIndex = newIndex;
            });
          }),
    );
  }
}

/// STATE class
class TimiState extends ChangeNotifier {
  String version = '';
  List<Task> tasks = [];
  LatLng mapLocation = LatLng(32.08, 34.8);
  TimiState();

  Future<void> fromJson() async {
    var url = Uri.parse('https://timi.parks.org.il/recorder/demo/tasks/?token=secrettokenforapi123');
    var response = await http.get(url);
    Map<String, dynamic> decodedResponse = jsonDecode(response.body);

    String _version = decodedResponse['version'];
    if (_version == version) {
      print('version is same');
      return;
    } else {
      version = _version;
      List<Map<String, dynamic>> _jsonTasks = List<Map<String, dynamic>>.from(decodedResponse['tasks']);
      tasks = _jsonTasks.map((task) => Task.fromMap(task)).toList();
      notifyListeners();
    }
  }

  void updateLocation(LatLng loc) {
    mapLocation = loc;
    notifyListeners();
  }
}

class Task {
  final String? title;
  final List<double> geom;
  final int? start_hour;
  final int? end_hour;
  Task({this.title, geom, this.start_hour, this.end_hour}) : this.geom = geom;

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      title: map['title'],
      geom: List<double>.from(map['geom']),
      start_hour: map['start_hour'],
      end_hour: map['end_hour'],
    );
  }

  bool isInRange(LatLng loc) {
    if ((geom[0] < loc.longitude && geom[2] > loc.longitude) && (geom[1] < loc.latitude && geom[3] > loc.latitude)) {
      return true;
    } else {
      return false;
    }
  }
}
