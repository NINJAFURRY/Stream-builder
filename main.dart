import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MyApp(),
  );
}

String command;
String ip;
var data;
var v;
var fire;

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var firebase = FirebaseFirestore.instance;

  check() async {
    var url = "http://$ip/cgi-bin/hello.py?x=$command";
    var response = await http.get(url);
    await firebase.collection("linux").add({
      'ip': ip,
      'command': command,
      'output': "${response.body}",
    });
    setState(() {
      data = response.body;
    });
    print(data);
  }

  get() async {
    var g = await firebase.collection("linux").get();
    v = g.docs[0].data();
    setState(() {
      fire = v;
    });

    print(v);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Control your linux machine"),
          backgroundColor: Colors.grey,
        ),
        body: Center(
          child: Container(
            height: double.infinity,
            width: 400,
            child: Column(
              children: [
                StreamBuilder(
                  stream: Firestore.instance.collection('linux').snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return Container(
                      color: Colors.grey,
                      width: double.infinity,
                      child: Card(
                        color: Colors.grey,
                        child:
                            Text(data ?? "Your command output is Loading..."),
                      ),
                    );
                  },
                ),
                Container(
                  height: 15,
                ),
                Container(
                  height: 15,
                ),
                TextField(
                  decoration: InputDecoration(
                    hintText: "IP address of linux os",
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(
                        color: Colors.red,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    ip = value;
                  },
                ),
                Container(
                  height: 15,
                ),
                TextField(
                  decoration: InputDecoration(
                    hintText: "Enter your command",
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(color: Colors.red),
                    ),
                  ),
                  onChanged: (value) {
                    command = (value);
                  },
                ),
                Container(
                  height: 15,
                ),
                RaisedButton(
                    child: Text("submit and add"),
                    color: Colors.red,
                    onPressed: check),
                RaisedButton(
                    child: Text("check"),
                    color: Colors.red,
                    onPressed: () {
                      print(data);
                    }),
                RaisedButton(
                  child: Text("get the data from firebase"),
                  color: Colors.red,
                  onPressed: get,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
