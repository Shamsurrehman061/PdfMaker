import 'dart:io';
import 'package:flutter/material.dart';


class RetrievePdfFile extends StatefulWidget {
  const RetrievePdfFile({Key? key}) : super(key: key);

  @override
  State<RetrievePdfFile> createState() => _RetrievePdfFileState();
}

class _RetrievePdfFileState extends State<RetrievePdfFile> {

  List<File> filesList = [];


  Future<void> pickPDFFile() async {

  }

  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    pickPDFFile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Retreiving pdf files"),
        centerTitle: true,
      ),

      body: Center(child: Text("hi"),),
    );
  }
}
