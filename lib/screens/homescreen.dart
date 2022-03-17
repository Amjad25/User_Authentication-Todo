import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_learning/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

final textController = TextEditingController();

class _HomeState extends State<Home> {
  TextEditingController todoTextController = TextEditingController();
  TextEditingController _updateTodoController = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;

  addData() async {
    //create clloection name of tasks
    //Data Store in Collection as Map
    await FirebaseFirestore.instance
        .collection('tasks')
        .doc(auth.currentUser!.uid)
        .collection('todo') 
        .add({
      'task': todoTextController.text,
      'date':
          '${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}',
    });
  }

  List allTasks = [];

  String task = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Todo App"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Add Todo"),
                  content: TextField(
                    controller: todoTextController,
                    decoration:
                        InputDecoration(hintText: "Plase Add Todo task"),
                    onChanged: (value) {
                      task = value;
                    },
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          addData();
                          allTasks.add(task);
                          Navigator.pop(context);
                          print(task);
                          todoTextController.clear();
                        });
                      },
                      child: Text("Add"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        todoTextController.clear();
                      },
                      child: Text("Cancel"),
                    ),
                  ],
                );
              });
        },
        child: Icon(Icons.task),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('tasks')
                    .doc(auth.currentUser!.uid)
                    .collection('todo')
                    .orderBy('task')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    return ListView(
                      children:
                          snapshot.data!.docs.map((DocumentSnapshot document) {
                        Map<String, dynamic> data =
                            document.data()! as Map<String, dynamic>;
                        return ListTile(
                          title: Text(data['task']),
                          subtitle: Text(data['date']),
                          trailing: Wrap(
                            children: [
                              IconButton(
                                  onPressed: () {
                                    document.reference.delete();
                                  },
                                  icon: Icon(Icons.edit)),
                              IconButton(
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text("update Todo"),
                                            content: ListView(
                                              children: [
                                                TextField(
                                                  controller:
                                                      _updateTodoController,
                                                ),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                  onPressed: () {
                                                    document.reference.update({
                                                      'tasks':
                                                          _updateTodoController
                                                              .text
                                                    });
                                                    _updateTodoController
                                                        .clear();
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text("Update Todo"))
                                            ],
                                          );
                                        });
                                  },
                                  icon: Icon(Icons.delete)),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  }
                  return Center(
                    child: Text("No Data"),
                  );
                }
                ),
          )

          // ListTile(
          //   title: Text(task),
          // )
        ],
      ),
    );
  }

  void showEditinDialog() {}
}
