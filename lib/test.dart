import 'package:flutter/material.dart';


class Test extends StatefulWidget {
  const Test({Key? key}) : super(key: key);

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {

  void called()
  {
    print("called");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("test"),
        centerTitle: true,
      ),

      body: Center(child: Text("hi"),),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          called();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
