import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class PdfViewer extends StatefulWidget {

  const PdfViewer({Key? key, required this.filePath}) : super(key: key);

  final String filePath;

  @override
  State<PdfViewer> createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text("Pdf viewer"),
        centerTitle: true,
        leading: IconButton(
          onPressed: (){
            Get.back();
          },
          icon:const Icon(Icons.arrow_back),
        ),
      ),
      body: PDFView(
        filePath: widget.filePath,
      ),
    );
  }
}
