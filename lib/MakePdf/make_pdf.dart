import 'dart:io';

import 'package:edge_detection/edge_detection.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/widgets.dart' as pw;

import '../home_screen.dart';

class MakePdfPage extends StatefulWidget {
  const MakePdfPage({Key? key, required this.ref}) : super(key: key);

  final String ref;
  @override
  State<MakePdfPage> createState() => _MakePdfPageState();
}

class _MakePdfPageState extends State<MakePdfPage> {

  List<File> _imagePath = [];
  List<XFile> _imagePaths = [];

  final nameController = TextEditingController();
  final key = GlobalKey<FormState>();


  nameFile()
  {
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            contentPadding: EdgeInsets.zero,
            content: Container(
              height: Get.height * 0.15,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children:
                [
                  SizedBox(
                    height: Get.height * 0.01,
                  ),

                  //Text("Name your file", style: TextStyle(fontSize: Get.width * 0.04, fontWeight: FontWeight.bold),),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: Get.width * 0.02),
                    child: Form(
                      key: key,
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: "Name your file"
                        ),
                        controller: nameController,
                        validator: (value){
                          if(value!.isEmpty)
                            {
                              return "* required";
                            }
                        },
                      ),
                    ),
                  ),

                  SizedBox(
                    height: Get.height * 0.009,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children:
                    [
                      TextButton(onPressed: (){
                        Navigator.of(context).pop();
                      }, child: Text("Cancel", style: TextStyle(fontSize: Get.width * 0.04),)),
                      TextButton(onPressed: ()async{

                        if(key.currentState!.validate())
                          {
                            Navigator.of(context).pop();
                            Size size = Get.size;
                            showDialog(
                              context: context,
                              builder: (builder) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  content: Container(
                                    height: size.height * 0.10,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children:
                                      [
                                        CircularProgressIndicator(),
                                        Text("please wait..."),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );

                            await Future.delayed(Duration(seconds: 2));
                            convertFile();
                          }
                      }, child: Text("Save", style: TextStyle(fontSize: Get.width * 0.04),))
                    ],
                  ),
                ],
              ),
            ),
          );
        }
    );
  }

  void getImage() async {

     print("camera");

    bool isCameraGranted = await Permission.camera.request().isGranted;

    if (!isCameraGranted) {
      isCameraGranted =
          await Permission.camera.request() == PermissionStatus.granted;
    }

    if (!isCameraGranted) {
      // Have not permission to camera
      return;
    }

    String imagePath =
        "${(await getApplicationSupportDirectory()).path}${(DateTime.now().millisecondsSinceEpoch / 1000).round()}.jpeg";

    try {
      bool success = await EdgeDetection.detectEdge(
        imagePath,
        canUseGallery: true,
        androidScanTitle: 'Scanning', // use custom localizations for android
        androidCropTitle: 'Crop',
        androidCropBlackWhiteTitle: 'Black White',
        androidCropReset: 'Reset',
      );
      if(success == true)
      {
        setState((){
          _imagePath.add(File(imagePath));
        });
      }
      else
      {
        Get.back();
      }
    } catch (e) {
      print(e);
    }

  }


  Future<void> getImagesFromGallery()async{

    final pickedImages = await ImagePicker().pickMultiImage();

    if(pickedImages.isNotEmpty || _imagePaths.length != 0)
    {
      _imagePaths.addAll(pickedImages);
    }
    else
    {
      Get.back();
    }

    setState((){
    });

  }

  var files = [];

  void convertFile()async{

    var list = [];


    for(int i=0; i < _imagePaths.length; i++)
    {
      _imagePath.add(File(_imagePaths[i].path));
    }
    createPdf();
  }

  void createPdf() async {


    final pdf = pw.Document();

    for (int i = 0; i < _imagePath.length; i++) {
      final image = pw.MemoryImage(_imagePath[i].readAsBytesSync());
      pdf.addPage(
        pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Image(image),
              );
            }),
      );
    }



    Directory pdfDirectory = Directory('/storage/emulated/0/PDF SCANNER');

    if(pdfDirectory.existsSync())
    {
      savePdfToDir(pdfDirectory, pdf);
    }
    else
    {
      Future<void> dir = pdfDirectory.create().then((value){
        savePdfToDir(value, pdf);
      });
    }
  }

  void savePdfToDir(Directory directory, pw.Document pdf)async
  {

    try {
      final file = File("${directory.path}/${nameController.text}.pdf");
      await file.writeAsBytes(await pdf.save());
      Get.back();
      Fluttertoast.showToast(msg:"your pdf file is saved successfully");
      Get.back();
      setState(() {
        _imagePath.clear();
      });
    } catch (e){
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.ref == "camera" ? getImage() : getImagesFromGallery();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(

      appBar: AppBar(
        title: Text("Make Pdf Page"),
        centerTitle: true,
      ),

      body: Stack(
        children: [

          widget.ref == "camera" ? _imagePath.isNotEmpty ? GridView.builder(
              itemCount: _imagePath.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 1.5,
                crossAxisSpacing: 1,
              ),
              itemBuilder: (context, index){

                return Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Image(
                    fit: BoxFit.cover,
                    image: FileImage(_imagePath[index]),
                  ),
                );
              }) : Container() : _imagePaths.isNotEmpty ? GridView.builder(
              itemCount: _imagePaths.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 1.5,
                crossAxisSpacing: 1,
              ),
              itemBuilder: (context, index){
                return Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Image(
                    fit: BoxFit.cover,
                    image: FileImage(File(_imagePaths[index].path)),
                  ),
                );
              }) : Container(),

          Positioned(
            top: Get.height * 0.75,
              left: Get.width * 0.1,
              right: Get.width * 0.1,
              child: ElevatedButton(
                  onPressed: (){
                    //nameFile();
                    String path = DateTime.now().millisecondsSinceEpoch.toString();
                    nameController.text = path;
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
                              left: Get.width * 0.02,
                              right: Get.width * 0.02
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:
                              [
                                SizedBox(
                                  height: Get.height * 0.03,
                                ),

                                Text("Convert", style: TextStyle(fontSize: Get.width * 0.05, fontWeight: FontWeight.bold, color: Colors.white),),

                                SizedBox(
                                  height: Get.height * 0.05,
                                ),

                                Text("Name", style: TextStyle(fontSize: Get.width * 0.04,  color: Colors.white),),

                                Form(
                                  key: key,
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                        hintText: "Name your file",
                                      hintStyle: TextStyle(color: Colors.white),
                                    ),
                                    controller: nameController,
                                    style: TextStyle(color: Colors.white),
                                    validator: (value){
                                      if(value!.isEmpty)
                                      {
                                        return "* required";
                                      }
                                    },
                                  ),
                                ),

                                SizedBox(
                                  height: Get.height * 0.009,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children:
                                  [
                                    TextButton(onPressed: (){
                                      Navigator.of(context).pop();
                                    }, child: Text("Cancel", style: TextStyle(fontSize: Get.width * 0.04),)),
                                    TextButton(onPressed: ()async{

                                      if(key.currentState!.validate())
                                      {
                                        Navigator.of(context).pop();
                                        Size size = Get.size;
                                        showDialog(
                                          context: context,
                                          builder: (builder) {
                                            return AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10.0),
                                              ),
                                              content: Container(
                                                height: size.height * 0.10,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                  children:
                                                  [
                                                    CircularProgressIndicator(),
                                                    Text("please wait..."),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );

                                        await Future.delayed(Duration(seconds: 2));
                                        convertFile();
                                      }
                                    }, child: Text("Save", style: TextStyle(fontSize: Get.width * 0.04),))
                                  ],
                                ),
                                SizedBox(
                                  height: Get.height * 0.03,
                                ),
                              ],
                            ),
                          );
                        }
                    );
                  },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: Size(Get.height * 0.1, Get.height * 0.07),
                ),
                  child: Text("Create", style: TextStyle(fontSize: Get.width * 0.05),),
              )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          widget.ref == "camera" ? getImage() : getImagesFromGallery();
        },
        child:widget.ref == "camera" ? Icon(Icons.camera) : Icon(Icons.photo_library),
      ),
    );
  }
}


