import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

import '../PdfViewer/pdf_viewer.dart';
import '../home_screen.dart';

 retrievePdfFiles(SendPort sendPort) async {

   List<File> pdfFiles = [];
   pdfFiles.clear();
   Directory directory = Directory('/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Documents');

  if(directory.existsSync()){
    List<FileSystemEntity> files = directory.listSync();
    for(final FileSystemEntity file in files){
      if(file is File && file.path.endsWith('.pdf')){
        pdfFiles.add(file);
      }
    }
  }
  sendPort.send(pdfFiles);
}

class WhatsappDocs extends StatefulWidget {
  const WhatsappDocs({Key? key}) : super(key: key);

  @override
  State<WhatsappDocs> createState() => _WhatsappDocsState();
}

class _WhatsappDocsState extends State<WhatsappDocs> {

  List<File> pdfFiles = [];

  bool isLoading = true;

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
                      pdfFiles.removeAt(index);
                      setState((){
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

    await Isolate.spawn(retrievePdfFiles, receiverPort.sendPort);


    receiverPort.listen((files){
      pdfFiles = files;
      setState((){
        isLoading = false;
      });
    });
  }

  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    pdfFiles.clear();
    getPdfFiles();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.red,
        leading: IconButton(onPressed: (){
          Navigator.of(context).push(MaterialPageRoute(builder: (context) =>const HomePage()));
        }, icon: Icon(Icons.arrow_back),),
        title: Text("Whatsapp Documents"),
      ),

      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Colors.red,),
      )
          :pdfFiles.length != 0 ? ListView.builder(
        itemCount: pdfFiles.length,
        physics: BouncingScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Card(
            color: Colors.black,
              child: ListTile(
                title: Text(pdfFiles[index].path.split('/').last, style: TextStyle(color: Colors.white),),
                subtitle: Text(pdfFiles[index].statSync().changed.toString(), style: TextStyle(color: Colors.white),),
                leading: Image(image: AssetImage("Assets/Icons/pdf_icon.png"),),
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
                                            child: Text(pdfFiles[index].path.split('/').last, style: TextStyle(color: Colors.white),)),
                                        Text(pdfFiles[index].statSync().changed.toString(), style: TextStyle(color: Colors.white),),
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
                                    await Share.shareXFiles([XFile(pdfFiles[index].path)]);
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
                                  height: Get.height * 0.02,
                                ),
                                InkWell(
                                  onTap: (){
                                    Navigator.of(context).pop();
                                    deleteDialogue(pdfFiles[index].path.split('/').last, pdfFiles[index], index);
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
                onTap: ()async{
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => PdfViewer(filePath: pdfFiles[index].path,)));
                },
              ));
        },
      ) : Center(child: Text("No file found", style: TextStyle(color: Colors.red)),),
    );
  }
}
