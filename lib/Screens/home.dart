// ignore_for_file: unnecessary_null_comparison, unused_element, avoid_print

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_app/Widgets/todo_item.dart';
import '../model/todo.dart';
import '../constants/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _database = Hive.box('todos');

  List<ToDo> todosList = [];

  List<ToDo> _foundToDo = [];

  final _todoController = TextEditingController();

  @override
  void initState() {
    _database.isNotEmpty ? readData() : null;

    _foundToDo = todosList;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tdBGColor,
      appBar: AppBar(
        backgroundColor: tdBGColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'TODO APP',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(
                          bottom: 20,
                          right: 20,
                          left: 20,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          controller: _todoController,
                          decoration: const InputDecoration(
                            hintText: 'Add a new todo item',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                        bottom: 20,
                        right: 20,
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          _addToDoItem(_todoController.text);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: tdBlue,
                          minimumSize: const Size(60, 60),
                          shape: const CircleBorder(),
                        ),
                        child: const Text(
                          '+',
                          style: TextStyle(
                            fontSize: 40,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(
                          top: 30,
                          bottom: 20,
                        ),
                        child: const Text(
                          'ToDos',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      for (ToDo todo in _foundToDo.reversed)
                        ToDoItem(
                          todo: todo,
                          onToDoChanged: _handleToDoChange,
                          onDeleteItem: _deleteToDoItem,
                        ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleToDoChange(ToDo todo) {
    setState(() {
      todo.isDone = !todo.isDone;
      writeData();
    });
  }

  void _deleteToDoItem(String id) {
    setState(() {
      todosList.removeWhere((item) => item.id == id);
      writeData();
    });
  }

  void _addToDoItem(String toDo) {
    if (toDo.isNotEmpty) {
      setState(() {
        todosList.add(ToDo(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          todoText: toDo,
        ));
        writeData();
      });
      _todoController.clear();
    }
  }

  void _runFilter(String enteredKeyword) {
    List<ToDo> results = [];
    if (enteredKeyword.isEmpty) {
      results = todosList;
    } else {
      results = todosList
          .where((item) => item.todoText!
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      _foundToDo = results;
    });
  }

  void writeData() {
    _database.clear();
    _database.put(2, todosList);
    readData();
  }

  void readData() {
    List<ToDo> todos = _database.get(2, defaultValue: <ToDo>[]).cast<ToDo>();
    print(todos);
    if (todos == null) {
      todosList = [];
    } else {
      todosList = todos;
    }
  }

  void deleteData() {}
}
