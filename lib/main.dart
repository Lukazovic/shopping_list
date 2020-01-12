import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/item.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping List',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  var items = new List<Item>();

  HomePage() {
    items = [];
    // items.add(Item(title: "Item 1", done: false));
    // items.add(Item(title: "Item 2", done: true));
    // items.add(Item(title: "Item 3", done: false));
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var newTaskControler = TextEditingController();

  void add() {
    if (newTaskControler.text.isEmpty) {
      return;
    }

    setState(() {
      widget.items.add(
        Item(
          title: newTaskControler.text,
          done: false,
        ),
      );
      newTaskControler.clear();
      save();
      // newTaskControler.text = ""; // válido também
    });
  }

  void remove(int index) {
    setState(() {
      widget.items.removeAt(index);
      save();
    });
  }

  Future load() async {
    var preferences = await SharedPreferences.getInstance();
    var data = preferences.getString('data');

    if (data != null) {
      Iterable decoded = jsonDecode(data);
      List<Item> result = decoded.map((x) => Item.fromJson(x)).toList();
      setState(() {
        widget.items = result;
      });
    }
  }

  save() async {
    var preferences = await SharedPreferences.getInstance();
    await preferences.setString('data', jsonEncode(widget.items));
  }

  _HomePageState() {
    load();
  }

  Future<String> showTextField(BuildContext context){

    TextEditingController customController = TextEditingController();

    return showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Text("Nome do item:"),
        content: TextField(
          controller: newTaskControler,
        ),
        actions: <Widget>[
          MaterialButton(
            elevation: 5.0,
            child: Text("Adicionar"),
            color: Colors.blue,
            onPressed: (){
              add();
              Navigator.of(context).pop(newTaskControler.text.toString());
            },
          )
        ],
      );
    },);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de compras"),
        // title: TextFormField(
        //   keyboardType: TextInputType.text,
        //   controller: newTaskControler,
        //   style: TextStyle(
        //     color: Colors.white,
        //     fontSize: 18,
        //   ),
        //   decoration: InputDecoration(
        //     labelText: "Lista de Compras",
        //     labelStyle: TextStyle(
        //       color: Colors.white,
        //     ),
        //   ),
        // ),
      ),
      body: ListView.builder(
        itemCount: widget.items.length,
        itemBuilder: (BuildContext context, int index) {
          final item = widget.items[index];

          return Dismissible(
            child: CheckboxListTile(
              title: Text(item.title),
              value: item.done,
              onChanged: (value) {
                setState(() {
                  item.done = value;
                  save();
                });
              },
            ),
            key: Key(item.title),
            background: Container(
              color: Colors.red.withOpacity(0.75),
            ),
            onDismissed: (direction) {
              return remove(index);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.pink,
        onPressed: () {
          showTextField(context).then((onValue) {
            // SnackBar mySnackBar = SnackBar(content: Text("foi adicionar com sucesso!"),);
            // Scaffold.of(context).showSnackBar(mySnackBar);
           });
        },
      ),
    );
  }
}
