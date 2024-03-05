import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

import '../PdfViewer/pdf_viewer.dart';
import '../home_screen.dart';

retrievePdfFiles(SendPort sendPort) async {
  List<File> pdfFiles = [];
  pdfFiles.clear();

  Directory directory = Directory('/storage/emulated/0');
  if (directory.existsSync()) {
    List<FileSystemEntity> files = directory.listSync();
    for (final FileSystemEntity file in files) {
      if (file is File && file.path.endsWith('.pdf')) {
        pdfFiles.add(file);
      }
    }
  }

  sendPort.send(pdfFiles);
}

sumsungDirectory(SendPort sendPort) {
  List<File> pdfFiles = [];
  pdfFiles.clear();
  Directory directory = Directory('/storage/emulated/0/Samsung');

  if (directory.existsSync()) {
    List<FileSystemEntity> files = directory.listSync();
    for (final FileSystemEntity file in files) {
      if (file is File && file.path.endsWith('.pdf')) {
        pdfFiles.add(file);
      }
    }
  }

  sendPort.send(pdfFiles);
}

androidDirectory(SendPort sendPort) {
  List<File> pdfFiles = [];
  pdfFiles.clear();
  Directory directory = Directory('/storage/emulated/0/Android');

  if (directory.existsSync()) {
    List<FileSystemEntity> files = directory.listSync();
    for (final FileSystemEntity file in files) {
      if (file is File && file.path.endsWith('.pdf')) {
        pdfFiles.add(file);
      }
    }
  }

  sendPort.send(pdfFiles);
}

musicDirectory(SendPort sendPort) {
  List<File> pdfFiles = [];
  pdfFiles.clear();
  Directory directory = Directory('/storage/emulated/0/Music');

  if (directory.existsSync()) {
    List<FileSystemEntity> files = directory.listSync();
    for (final FileSystemEntity file in files) {
      if (file is File && file.path.endsWith('.pdf')) {
        pdfFiles.add(file);
      }
    }
  }

  sendPort.send(pdfFiles);
}

ringtonesDirectory(SendPort sendPort) {
  List<File> pdfFiles = [];
  pdfFiles.clear();
  Directory directory = Directory('/storage/emulated/0/Ringtones');

  if (directory.existsSync()) {
    List<FileSystemEntity> files = directory.listSync();
    for (final FileSystemEntity file in files) {
      if (file is File && file.path.endsWith('.pdf')) {
        pdfFiles.add(file);
      }
    }
  }

  sendPort.send(pdfFiles);
}

alaramDirectory(SendPort sendPort) {
  List<File> pdfFiles = [];
  pdfFiles.clear();
  Directory directory = Directory('/storage/emulated/0/Alarms');

  if (directory.existsSync()) {
    List<FileSystemEntity> files = directory.listSync();
    for (final FileSystemEntity file in files) {
      if (file is File && file.path.endsWith('.pdf')) {
        pdfFiles.add(file);
      }
    }
  }

  sendPort.send(pdfFiles);
}

notificationDirectory(SendPort sendPort) {
  List<File> pdfFiles = [];
  pdfFiles.clear();
  Directory directory = Directory('/storage/emulated/0/Notifications');

  if (directory.existsSync()) {
    List<FileSystemEntity> files = directory.listSync();
    for (final FileSystemEntity file in files) {
      if (file is File && file.path.endsWith('.pdf')) {
        pdfFiles.add(file);
      }
    }
  }

  sendPort.send(pdfFiles);
}

picturesDirectory(SendPort sendPort) {
  List<File> pdfFiles = [];
  pdfFiles.clear();
  Directory directory = Directory('/storage/emulated/0/Pictures');

  if (directory.existsSync()) {
    List<FileSystemEntity> files = directory.listSync();
    for (final FileSystemEntity file in files) {
      if (file is File && file.path.endsWith('.pdf')) {
        pdfFiles.add(file);
      }
    }
  }

  sendPort.send(pdfFiles);
}

moviesDirectory(SendPort sendPort) {
  List<File> pdfFiles = [];
  pdfFiles.clear();
  Directory directory = Directory('/storage/emulated/0/Movies');
  if (directory.existsSync()) {
    List<FileSystemEntity> files = directory.listSync();
    for (final FileSystemEntity file in files) {
      if (file is File && file.path.endsWith('.pdf')) {
        pdfFiles.add(file);
      }
    }
  }

  sendPort.send(pdfFiles);
}

downloadDirectory(SendPort sendPort) {
  List<File> pdfFiles = [];
  pdfFiles.clear();
  Directory directory = Directory('/storage/emulated/0/Download');

  if (directory.existsSync()) {
    List<FileSystemEntity> files = directory.listSync();
    for (final FileSystemEntity file in files) {
      if (file is File && file.path.endsWith('.pdf')) {
        pdfFiles.add(file);
      }
    }
  }

  sendPort.send(pdfFiles);
}

dcimDirectory(SendPort sendPort) {
  List<File> pdfFiles = [];
  pdfFiles.clear();
  Directory directory = Directory('/storage/emulated/0/DCIM');

  if (directory.existsSync()) {
    List<FileSystemEntity> files = directory.listSync();
    for (final FileSystemEntity file in files) {
      if (file is File && file.path.endsWith('.pdf')) {
        pdfFiles.add(file);
      }
    }
  }

  sendPort.send(pdfFiles);
}

class OtherDocs extends StatefulWidget {
  const OtherDocs({Key? key}) : super(key: key);

  @override
  State<OtherDocs> createState() => _OtherDocsState();
}

class _OtherDocsState extends State<OtherDocs> {
  bool isLoading = true;
  List<File> pdfFiless = [];

  deleteDialogue(var fileName, File filePath, var index)async{


    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context)
        {
          return AlertDialog(
            backgroundColor: Color(0xff2d2a2d),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children:
              [
                Text("Warning", style: TextStyle(color: Colors.white),),
                SizedBox(
                  height: Get.height * 0.01,
                ),
                Text("Are you sure to delete ${fileName}?", style: TextStyle(color: Colors.grey),),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children:
                  [
                    MaterialButton(onPressed: (){
                      Navigator.of(context).pop();
                    }, child: Text("CANCEL", style: TextStyle(color: Colors.white),),),
                    MaterialButton(onPressed: ()async{
                      await filePath.delete();
                      Navigator.of(context).pop();
                      pdfFiless.removeAt(index);
                      setState(() {
                      });
                    }, child: Text("OK", style: TextStyle(color: Colors.white),),),
                  ],
                ),
              ],
            ),
          );
        }
    );

  }

  getPdfFiles() async {
    final receiverPort = ReceivePort();
    final receiverPort1 = ReceivePort();
    final receiverPort2 = ReceivePort();
    final receiverPort3 = ReceivePort();
    final receiverPort4 = ReceivePort();
    final receiverPort5 = ReceivePort();
    final receiverPort6 = ReceivePort();
    final receiverPort7 = ReceivePort();
    final receiverPort8 = ReceivePort();
    final receiverPort9 = ReceivePort();
    final receiverPort10 = ReceivePort();

    await Isolate.spawn(retrievePdfFiles, receiverPort.sendPort);
    await Isolate.spawn(sumsungDirectory, receiverPort1.sendPort);
    await Isolate.spawn(androidDirectory, receiverPort2.sendPort);
    await Isolate.spawn(musicDirectory, receiverPort3.sendPort);
    await Isolate.spawn(ringtonesDirectory, receiverPort4.sendPort);
    await Isolate.spawn(alaramDirectory, receiverPort5.sendPort);
    await Isolate.spawn(notificationDirectory, receiverPort6.sendPort);
    await Isolate.spawn(picturesDirectory, receiverPort7.sendPort);
    await Isolate.spawn(moviesDirectory, receiverPort8.sendPort);
    await Isolate.spawn(downloadDirectory, receiverPort9.sendPort);
    await Isolate.spawn(dcimDirectory, receiverPort10.sendPort);

    receiverPort.listen((files) {
      pdfFiless.addAll(files);
    });

    receiverPort1.listen((files){
      pdfFiless.addAll(files);
    });

    receiverPort2.listen((files){
      pdfFiless.addAll(files);
    });

    receiverPort3.listen((files){
      pdfFiless.addAll(files);
    });

    receiverPort4.listen((files){
      pdfFiless.addAll(files);
    });

    receiverPort5.listen((files){
      pdfFiless.addAll(files);
    });

    receiverPort6.listen((files){
      pdfFiless.addAll(files);
    });

    receiverPort7.listen((files){
      pdfFiless.addAll(files);
    });

    receiverPort8.listen((files){
      pdfFiless.addAll(files);
    });

    receiverPort9.listen((files){
      pdfFiless.addAll(files);
    });

    receiverPort10.listen((files){
      pdfFiless.addAll(files);
      setState(() {
        isLoading = false;
      });
    });

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pdfFiless.clear();
    getPdfFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.red,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const HomePage()));
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text("Other Documents"),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.red,),
            )
          : pdfFiless.length != 0 ? ListView.builder(
              itemCount: pdfFiless.length,
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.black,
                    child: ListTile(
                      title: Text(pdfFiless[index].path.split('/').last, style: TextStyle(color: Colors.white),),
                      leading: Image(image: AssetImage("Assets/Icons/pdf_icon.png"),),
                      subtitle: Text(pdfFiless[index].statSync().changed.toString(), style: TextStyle(color: Colors.white),),
                      trailing: IconButton(
                        onPressed: (){
                          showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Color(0xff2d2a2d),
                              //backgroundColor: Color(0xff3d363d),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(20.0),
                                  topLeft: Radius.circular(20.0),
                                ),
                              ),
                              builder:(context){
                                return Padding(
                                  padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(context).viewInsets.bottom,
                                      left: Get.width * 0.03,
                                      right: Get.width * 0.03
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children:
                                    [
                                      SizedBox(
                                        height: Get.height * 0.02,
                                      ),
                                      Center(
                                        child: Container(
                                          height: Get.height * 0.005,
                                          width: Get.width * 0.15,
                                          decoration: BoxDecoration(
                                            color: Colors.grey,
                                            borderRadius: BorderRadius.circular(10.0),
                                          ),
                                        ),
                                      ),

                                      SizedBox(
                                        height: Get.height * 0.02,
                                      ),


                                      Row(
                                        children:
                                        [
                                          Image(image: AssetImage("Assets/Icons/pdf_icon.png"),),
                                          SizedBox(
                                            width: Get.size.width * 0.02,
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children:
                                            [
                                              Container(
                                                width: Get.size.width * 0.7,
                                                  child: Text(pdfFiless[index].path.split('/').last, style: TextStyle(color: Colors.white),)),
                                              Text(pdfFiless[index].statSync().changed.toString(), style: TextStyle(color: Colors.white),),
                                            ],
                                          ),
                                        ],
                                      ),


                                      SizedBox(
                                        height: Get.height * 0.02,
                                      ),

                                      Container(
                                        color: Colors.grey,
                                        height: Get.height * 0.001,
                                        width: double.infinity,
                                      ),

                                      SizedBox(
                                        height: Get.height * 0.02,
                                      ),

                                      InkWell(
                                        onTap: ()async{
                                          Navigator.of(context).pop();
                                          await Share.shareXFiles([XFile(pdfFiless[index].path)]);
                                        },
                                        child: Row(
                                          children:
                                          [
                                            Icon(Icons.share, color: Colors.white,),
                                            SizedBox(
                                              width: Get.size.width * 0.02,
                                            ),
                                            Text("Share", style: TextStyle(color: Colors.white),),
                                          ],
                                        ),
                                      ),

                                      SizedBox(
                                        height: Get.height * 0.035,
                                      ),

                                      InkWell(
                                        onTap: (){
                                          Navigator.of(context).pop();
                                          deleteDialogue(pdfFiless[index].path.split('/').last, pdfFiless[index], index);
                                        },
                                        child: Row(
                                          children:
                                          [
                                            Icon(Icons.delete, color: Colors.white,),
                                            SizedBox(
                                              width: Get.size.width * 0.02,
                                            ),
                                            Text("Delete", style: TextStyle(color: Colors.white),),
                                          ],
                                        ),
                                      ),

                                      SizedBox(
                                        height: Get.height * 0.02,
                                      ),
                                    ],
                                  ),
                                );
                              }
                          );
                        },
                        icon: Icon(Icons.more_vert_rounded, color: Colors.white,),

                      ),
                      onTap: (){
                        Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => PdfViewer(
                              filePath: pdfFiless[index].path,
                            )));
                  },
                ));
              },
            ) : Center(child: Text("No file found", style: TextStyle(color: Colors.red)),),
    );
  }
}
