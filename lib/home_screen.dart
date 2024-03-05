import 'dart:io';
import 'dart:isolate';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:edge_detection/edge_detection.dart';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_scanner/test.dart';
import 'package:permission_handler/permission_handler.dart';


import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import 'DownloadDocuments/download_docs.dart';
import 'MakePdf/make_pdf.dart';
import 'OtherDocuments/other_docs.dart';
import 'PdfViewer/pdf_viewer.dart';
import 'WhatsappDocuments/whatsapp_docs.dart';


retrievePdfFiles(SendPort sendPort) async {

  List<File> pdfFiles = [];
  pdfFiles.clear();
  Directory directory = Directory('/storage/emulated/0/PDF SCANNER');

  if(directory.existsSync()){
    List<FileSystemEntity> files = directory.listSync();
    for(final FileSystemEntity file in files){
      if(file is File && file.path.endsWith('.pdf')){
        pdfFiles.add(file);
        print(file.statSync().changed);
        print("*************************");
      }
    }
  }
  sendPort.send(pdfFiles);
}


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<File> _imagePath = [];
  List<XFile> _imagePaths = [];
  List<File> pdfFiles = [];
  bool isLoading = true;

  getPdfFiles() async {

    isLoading = true;
    final receiverPort = ReceivePort();

    await Isolate.spawn(retrievePdfFiles, receiverPort.sendPort);


    receiverPort.listen((files){
      pdfFiles = files;
      setState((){
        isLoading = false;
      });
    });
  }

  var files = [];

  deleteDialogue(var fileName, File filePath)async{


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
                    }, child: Text("OK", style: TextStyle(color: Colors.white),),),
                  ],
                ),
              ],
            ),
          );
        }
    );

  }

  void dialogue() {
    showDialog(
      context: context,
      builder: (builder) {
        return AlertDialog(
          backgroundColor: Color(0xff2d2a2d),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          content: Container(
            height: 120.0,
            child: Column(
              children: [
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => MakePdfPage(ref: 'camera',)));
                  },
                  leading: const Icon(Icons.camera_alt, color: Colors.white,),
                  title: const Text("Camera", style: TextStyle(color: Colors.white),),
                ),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => MakePdfPage(ref: 'gallery',)));
                  },
                  leading: const Icon(Icons.photo_library, color: Colors.white,),
                  title: const Text("Gallery", style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String imageSelected = "No image selected";

  Future<void> getImagesFromGallery()async{

    _imagePath.clear();
    _imagePaths.clear();


    final pickedImages = await ImagePicker().pickMultiImage();

    if(pickedImages.isNotEmpty)
      {
        _imagePaths.addAll(pickedImages);
      }

    setState((){
    });

    convertFile();
  }

  Future<void> getImage() async {

    _imagePath.clear();
    _imagePaths.clear();

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
          setState(() {
            _imagePath.add(File(imagePath));
          });
        }
    } catch (e) {
      print(e);
    }

  }

  void showToastMsg(String msg) {
    Fluttertoast.showToast(msg: msg);
  }

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
    String path = DateTime.now().millisecondsSinceEpoch.toString();

    try {

      final file = File("${directory.path}/${path}.pdf");
      await file.writeAsBytes(await pdf.save());
      showToastMsg("your pdf file is saved successfully");
      setState(() {
        _imagePath.clear();
      });

        } catch (e) {
                print(e);
                showToastMsg(e.toString());
          }
  }

  getPermissions()async {

    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      var release = androidInfo.version.release;

      if(release == "9"){



      }
      else
        {
          var externalPermission = await Permission.manageExternalStorage.request();

          if (externalPermission.isGranted) {
            Get.back();
            print("granted");
          } else {
            print("denied");
          }
        }


    }


  }

  showDialogue()async
  {

    final size = Get.size;

    await Future.delayed(Duration(milliseconds: 50));
    // ignore: use_build_context_synchronously
    showDialog(
        context: context,
        builder: (context)
        {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children:
              [
                Text("Request Permission",textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: size.width * 0.06),),

                SizedBox(
                  height: size.height * 0.01,
                ),

                Text("Allow External Storage Permission to access all pdf files", textAlign: TextAlign.center,),
              ],
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:
                [
                  TextButton(onPressed: (){
                    Get.back();
                  }, child: Text("ASK ME LATER"),),

                  TextButton(
                    onPressed: (){
                      getPermissions();
                    },
                    child: Text("ALLOW"),
                  )
                ],
              ),
            ],
          );
        }
    );
  }

  Widget drawer()
  {
    return Drawer(
      backgroundColor: Color(0xff2d2a2d),
      child: ListView(
        children:
        [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.green,
            ), //BoxDecoration
            child: UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.green),
              accountName: Text(
                "Abhishek Mishra",
                style: TextStyle(fontSize: 18),
              ),
              accountEmail: Text("abhishekm977@gmail.com"),
              currentAccountPictureSize: Size.square(50),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Color.fromARGB(255, 165, 255, 137),
                child: Text(
                  "A",
                  style: TextStyle(fontSize: 30.0, color: Colors.blue),
                ), //Text
              ), //circleAvatar
            ), //UserAccountDrawerHeader
          ),

          ListTile(
            leading: Icon(Icons.storage, color: Colors.white,),
            title: Text("Whatsapp documents", style: TextStyle(color: Colors.white),),
            onTap: ()async{

              var androidInfo = await DeviceInfoPlugin().androidInfo;
              var release = androidInfo.version.release;

              if (release == "9") {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => WhatsappDocs()));
              }
              else
              {
                final status = await Permission.manageExternalStorage.status;
                if (status.isGranted) {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => WhatsappDocs()));
                }
                else {
                  Get.back();
                  showDialogue();
                }
              }
            },
          ),

          ListTile(
            leading: Icon(Icons.download, color: Colors.white,),
            title: Text("Download Documents", style: TextStyle(color: Colors.white),),
            onTap: ()async {
              var androidInfo = await DeviceInfoPlugin().androidInfo;
              var release = androidInfo.version.release;

              if (release == "9") {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => DownloadDocs()));
              }
              else
              {
                final status = await Permission.manageExternalStorage.status;
                if (status.isGranted) {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => DownloadDocs()));
                }
                else {
                  Get.back();
                  showDialogue();
                }
              }
            },
          ),

          ListTile(
            leading: Icon(Icons.add, color: Colors.white,),
            title: Text("Other Documents", style: TextStyle(color: Colors.white),),
            onTap: ()async{

              var androidInfo = await DeviceInfoPlugin().androidInfo;
              var release = androidInfo.version.release;

              if (release == "9") {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) =>const OtherDocs()));
              }
              else
              {
                final status = await Permission.manageExternalStorage.status;
                if (status.isGranted) {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) =>const OtherDocs()));
                }
                else {
                  Get.back();
                  showDialogue();
                }
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    pdfFiles.clear();
    getPdfFiles();
  }


  @override
  Widget build(BuildContext context){
    getPdfFiles();
    Size size = MediaQuery.of(context).size;


    return Scaffold(
      backgroundColor: Colors.black,
      drawer: drawer(),
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text("Scan documents"),
        actions: [
          _imagePath.isEmpty ? Container() : IconButton(
              onPressed: () => convertFile(), icon: Icon(Icons.picture_as_pdf)),
          _imagePath.isEmpty ? Container() : IconButton(
              onPressed: () {
                _imagePath.clear();
                _imagePaths.clear();
                setState(() {});
              },
              icon: Icon(Icons.clear))
        ],
      ),

      body: pdfFiles.isEmpty ? Center(child: Text("No File Found", style: TextStyle(color: Colors.red),),) : ListView.builder(
        itemCount: pdfFiles.length,
        physics: BouncingScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index){
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
                                  height: Get.height * 0.03,
                                ),

                                InkWell(
                                  onTap: ()async{
                                    Navigator.pop(context);
                                    deleteDialogue(pdfFiles[index].path.split('/').last, pdfFiles[index]);
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
      ),

      // floatingActionButton: SpeedDial(
      //   icon: Icons.add,
      //   backgroundColor: Colors.blue,
      //   closeManually: true,
      //   activeIcon: Icons.clear,
      //   overlayOpacity: 0,
      //   children:
      //   [
      //     SpeedDialChild(
      //       child: const Icon(Icons.camera_alt,color: Colors.white),
      //       label: 'Camera',
      //       backgroundColor: Colors.blueAccent,
      //       onTap: (){
      //         Navigator.of(context).push(MaterialPageRoute(builder: (context) => Test()));
      //       },
      //     ),
      //     SpeedDialChild(
      //       child: const Icon(Icons.photo,color: Colors.white),
      //       label: 'Gallery',
      //       backgroundColor: Colors.blueAccent,
      //       onTap: () {
      //         Navigator.of(context).push(MaterialPageRoute(builder: (context) => MakePdfPage(ref: 'gallery',)));
      //       },
      //     ),
      //   ],
      // ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: (){
          dialogue();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
