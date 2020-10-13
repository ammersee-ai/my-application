import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Weather'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> list = new List();
  void fetchData() {
    getData().then((res) {
      setState(() {
        list.addAll(res);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Center(
        child: new ListView.builder(
          itemCount: list.length,
          itemBuilder: ((BuildContext _context, int position) {
            return new ListTile(
              title: new Text(list[position]['temperatureCelsius'].toString()),
              trailing: new Text(list[position]['deviceId'].toString()),
              leading: new Text(list[position]['timestamp'].toString()),//new Image.network(list[position]['avatar_url']),
            );
          }),
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> getData() async {
    var url = "https://wetterstation.tapped.dev/readings";
    List<dynamic> data = new List();
    List<Map<String, dynamic>> convertedList = new List();
    var httpClient = new HttpClient();
    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    //check status 200 here
    if (response.statusCode == HttpStatus.OK) {
      var jsonString = await response.transform(utf8.decoder).join();
      data = json.decode(jsonString);
      //data = jsonDecode(response.body);
      //List<Map<String, dynamic>> convertedList = new List();
      for (int i = 0; i < data.length; i++) {
        //converts dynamic to a map of string,dynamic
        Map<String, dynamic> map = Map<String, dynamic>.from(data[i]);
        for (String key in map.keys) {
          if (key == 'temperatureCelsius') {
            map[key] = double.parse(map[key].toString()).toInt();
          }
          if (key == 'timestamp') {
            //parse the time from timestamp
            DateFormat dateFormat = DateFormat("yyyy-MM-ddTHH:mm:ss");
            DateTime dateTime = dateFormat.parse(map[key]);
            String t = dateTime.hour.toString() + ':' +
                dateTime.minute.toString();
            map[key] = t;
          }
        }
        convertedList.add(map);
      }
      //take things of listconverted and sort it by the timestamp
      convertedList.sort((a, b) => (b['timestamp'].compareTo(a['timestamp'])));
      print(convertedList);
      return convertedList;
    }
    else{
      return convertedList;
    }
  }
}
