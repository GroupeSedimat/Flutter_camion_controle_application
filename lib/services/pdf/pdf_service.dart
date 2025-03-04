import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_application_1/models/checklist/blueprint.dart';
import 'package:flutter_application_1/models/checklist/list_of_lists.dart';
import 'package:flutter_application_1/models/checklist/task.dart';
import 'package:flutter_application_1/models/company/company.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/services/database_firestore/check_list/database_image_service.dart';
import 'package:flutter_application_1/services/database_local/companies_table.dart';
import 'package:flutter_application_1/services/network_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/services/pdf/database_pdf_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:sqflite/sqflite.dart';

class PdfService {
  /// adapt to mode offline
  DatabasePDFService databasePDFService = DatabasePDFService();
  DatabaseImageService databaseImageService = DatabaseImageService();
  NetworkService networkService = NetworkService();

  Future<pw.Font> _loadFont() async {
    final fontData = await rootBundle.load("assets/fonts/roboto/Roboto-Regular.ttf");
    return pw.Font.ttf(fontData);
  }

  Future<Uint8List> createInvoice(
      Database db,
      MyUser user,
      Map<String, TaskChecklist> tasks,
      Map<String, Blueprint> sortedBlueprints,
      ListOfLists list) async {
    final pdf = pw.Document();
    final company = (await getOneCompanyWithID(db, user.company))!;
    final mobilityLogo = (await rootBundle.load('assets/images/keybas_logo.png')).buffer.asUint8List();
    final font = await _loadFont();
    final companyColumn = await _companyDatas(company, font);
    final photosToPDF = HashMap<int, Uint8List>();

    // final blueprintTaskList = _generateBlueprintTaskList(sortedBlueprints, tasks, list, photosToPDF);
    Map<Blueprint, TaskChecklist> blueprintTaskList = {};

    for (Blueprint blueprint in sortedBlueprints.values){
      for(TaskChecklist task in tasks.values){
        if (blueprint.nrEntryPosition == task.nrEntryPosition && blueprint.nrOfList == list.listNr && task.nrOfList == list.listNr){
          blueprintTaskList.addAll({blueprint: task});
          if(task.photoFilePath != "" && task.photoFilePath != null){
            String listNr = task.nrOfList.toString();
            String entryPos = task.nrEntryPosition.toString();
            while(listNr.length<4){
              listNr = "0$listNr";
            }
            while(entryPos.length<4){
              entryPos = "0$entryPos";
            }
            Directory tempDir = await getApplicationDocumentsDirectory();
            final fileTemp = File("${tempDir.path}/$listNr${entryPos}photoValidate.jpeg");
            if (await fileTemp.exists()) {
              Uint8List photoBytes = await fileTemp.readAsBytes();
              photosToPDF[task.nrEntryPosition] = photoBytes;
            }
          }
        }
      }
    }

    final pageTheme = pw.PageTheme(
      pageFormat: PdfPageFormat.a4,
      buildBackground: (context) => _watermark(mobilityLogo),
    );

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pageTheme,
        build: (context) => [_showValidation(blueprintTaskList, font, photosToPDF)],
        header: (context) => _header(context, font, user, list, mobilityLogo, companyColumn),
        footer: (context) => _footer(context, font),
      ),
    );

    if (photosToPDF.isNotEmpty) {
      pdf.addPage(
        pw.MultiPage(
          pageTheme: pageTheme,
          build: (context) => [_photoAttachments(photosToPDF)],
          header: (context) => _header(context, font, user, list, mobilityLogo, companyColumn),
          footer: (context) => _footer(context, font),
        ),
      );
    }

    return pdf.save();
  }

  // Map<Blueprint, TaskChecklist> _generateBlueprintTaskList(
  //     Map<String, Blueprint> sortedBlueprints,
  //     Map<String, TaskChecklist> tasks,
  //     ListOfLists list,
  //     Map<int, Uint8List> photosToPDF) {
  //   final blueprintTaskList = HashMap<Blueprint, TaskChecklist>();
  //
  //   for (final blueprint in sortedBlueprints.values) {
  //     for (final task in tasks.values) {
  //       if (blueprint.nrEntryPosition == task.nrEntryPosition &&
  //           blueprint.nrOfList == list.listNr &&
  //           task.nrOfList == list.listNr) {
  //         blueprintTaskList[blueprint] = task;
  //         if (task.photoFilePath?.isNotEmpty == true) {
  //           databaseImageService.downloadImageFromFirebase(task.photoFilePath!).then((photo) {
  //             if (photo != null) photosToPDF[task.nrEntryPosition] = photo;
  //           });
  //         }
  //       }
  //     }
  //   }
  //   return Map.fromEntries(
  //       blueprintTaskList.entries.toList()..sort((e1, e2) => e1.value.nrEntryPosition.compareTo(e2.value.nrEntryPosition)));
  // }

  pw.Widget _showValidation(Map<Blueprint, TaskChecklist> blueprintTaskList, pw.Font font, Map<int, Uint8List> photosToPDF) {
    int count = 1;
    return pw.ListView.builder(
      itemCount: blueprintTaskList.length,
      itemBuilder: (context, index) {
        final entry = blueprintTaskList.entries.elementAt(index);
        return pw.Column(
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Container(
                  width: 300,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "Task title: ${entry.key.title}",
                        style: pw.TextStyle(font: font),
                      ),
                      pw.Text(
                        "Task description: ${entry.key.description}",
                        style: pw.TextStyle(font: font),
                      ),
                      pw.Text(
                        "Validation date: ${DateFormat("dd-MM-yyyy h:mm a").format(entry.value.updatedAt)}",
                        style: pw.TextStyle(font: font),
                      ),
                    ],
                  ),
                ),
                pw.Container(
                  width: 150,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (entry.value.isDone == true)
                        pw.Text(
                          "Its ok",
                          style: pw.TextStyle(font: font, color: PdfColors.green),
                        ),
                      if (entry.value.isDone != true)
                        pw.Text(
                          "Its not ok!",
                          style: pw.TextStyle(font: font, color: PdfColors.red),
                        ),
                      if (entry.value.descriptionOfProblem != "" && entry.value.descriptionOfProblem != null)
                        pw.Text(
                          "Problem: ${entry.value.descriptionOfProblem}",
                          style: pw.TextStyle(font: font),
                        ),
                      if (photosToPDF.containsKey(entry.value.nrEntryPosition))
                        pw.Text(
                          "Photo: pièce jointe n° ${count++}",
                          style: pw.TextStyle(font: font),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            pw.Divider(thickness: 1, color: PdfColors.grey, height: 10),
          ],
        );
      },
    );
  }

  pw.Widget _photoAttachments(Map<int, Uint8List> photosToPDF) {
    int count = 1;
    return pw.Wrap(
      spacing: 20,
      alignment: pw.WrapAlignment.spaceAround,
      runAlignment: pw.WrapAlignment.spaceAround,
      children: [
        for(Uint8List element in photosToPDF.values)
          pw.Column(
            children: [
              pw.SizedBox(height: 20,),
              pw.Text("Pièce jointe n°: ${count++}"),
              pw.SizedBox(height: 10,),
              pw.Image(
                pw.MemoryImage(element),
                height: 250,
                width: null,
                fit: pw.BoxFit.scaleDown,
              ),
            ],
          ),
      ],
    );
  }

  pw.Widget _watermark(Uint8List logo) {
    return pw.Center(
      child: pw.Opacity(
        opacity: 0.3,
        child: pw.Transform.rotate(angle: 45, child: pw.Image(pw.MemoryImage(logo), fit: pw.BoxFit.contain)),
      ),
    );
  }

  pw.Column _header(pw.Context context, pw.Font font, MyUser user, ListOfLists list, Uint8List logo, pw.Row companyColumn) {
    return pw.Column(
        children: [
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("Créé avec MCTruckCheck", style: pw.TextStyle(font: font, fontSize: 14)),
                pw.Image(pw.MemoryImage(logo), height: 50),
              ]
          ),
          // pw.Text('Page ${context.pageNumber}/${context.pagesCount}'),
          pw.Divider(thickness: 1,color: PdfColors.black, height: 10 ),
          if(context.pageNumber == 1)
            pw.Column(
                children:
                [
                  pw.SizedBox(height: 20,),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      userDatas(user, font),
                      companyColumn,
                    ],
                  ),
                  pw.SizedBox(height: 20,),
                  pw.Text(
                    "List ${list.listName}",
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      letterSpacing: 2,
                      wordSpacing: 9,
                    ),
                  ),
                  pw.SizedBox(height: 20,),
                ]
            )
        ]
    );
  }

  pw.Widget _footer(pw.Context context, pw.Font font) {
    return pw.Column(
      children: [
        pw.Divider(),
        pw.Text('Page ${context.pageNumber}/${context.pagesCount}'),
      ],
    );
  }

  Future<pw.Row> _companyDatas(Company company, pw.Font font) async {
    /// define what and how should be displayed
    Uint8List? logoData;
    if (company.logo != null) {
      logoData = await _downloadImage(company.logo!);
    }
    return pw.Row(
        children: [
          if (logoData != null)
            pw.Image(
              pw.MemoryImage(logoData),
              width: 75,
              // height: 100,
            ),
          pw.SizedBox(
            width: 20,
          ),
          pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("Company name ${company.name}", style: pw.TextStyle(font: font, )),
                if(company.sirene != "" && company.sirene != null)
                  pw.Text("Sirene ${company.sirene}", style: pw.TextStyle(font: font)),
                if(company.tel != "" && company.tel != null)
                  pw.Text("Tel ${company.tel}", style: pw.TextStyle(font: font)),
                if(company.email != "" && company.email != null)
                  pw.Text("Email ${company.email}", style: pw.TextStyle(font: font)),
                if(company.address != "" && company.address != null)
                  pw.Text("Address ${company.address}", style: pw.TextStyle(font: font)),
              ]
          )
        ]
    );
  }

  Future<Uint8List?> _downloadImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      return response.statusCode == 200 ? response.bodyBytes : null;
    } catch (e) {
      return null;
    }
  }

  Future<String> savePdfFile(String companyID, Uint8List data, MyUser user, String userId, Future<void> Function() deleteOneTaskListOfUser) async {
    int time = DateTime.now().millisecondsSinceEpoch;
    String fileName = "${user.username}.${time.toString()}";
    // String documentsPath = await getDocumentsPath();
    String documentsPath = "/storage/emulated/0/Documents/camion_appli";
    String filePath = "$documentsPath/$fileName.pdf";
    String filePathDatabase = "${user.company}/$userId/${time.toString()}";
    final directory = Directory(documentsPath);
    if (!(await directory.exists())) {
      await directory.create(recursive: true);
    }
    /// save PDF to phone
    final file = File(filePath);
    await file.writeAsBytes(data);

    if(networkService.isOnline){
      /// and send to the database if there is an internet connection
      await databasePDFService.addPdfToFirebase(filePath, filePathDatabase);
    }else{
      /// if not, I'll save it on phone and synchronize it later
      Directory tempDir = await getApplicationDocumentsDirectory();
      print("temp directory ${tempDir.path}");
      final fileTemp = File("${tempDir.path}/$userId.${time.toString()}.pdf");
      await fileTemp.writeAsBytes(data);
    }
    await deleteOneTaskListOfUser();
    return filePath;
  }

  pw.Column userDatas(MyUser user, pw.Font font) {
    /// define what and how should be displayed
    DateTime now = DateTime.now();
    DateTime localTime = now.toLocal();
    String formattedTime = DateFormat("yyyy-MM-dd HH:mm:ss").format(localTime);
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text("La personne qui crée la liste:", style: pw.TextStyle(font: font,)),
          pw.Text("Username ${user.username}", style: pw.TextStyle(font: font)),
          pw.Text("Email ${user.email}", style: pw.TextStyle(font: font)),
          pw.Text("Created $formattedTime", style: pw.TextStyle(font: font)),
        ]
    );
  }

  Future<String> getDocumentsPath() async {
    String documentsPath;
    if (Platform.isAndroid) {
      Directory? appDocDir = await getDownloadsDirectory();

      if (appDocDir == null) {
        throw Exception("Failed to get external directory");
      }
      documentsPath = "${appDocDir.path}/camion_appli";

      Directory downloadDir = Directory(documentsPath);
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }
    } else if (Platform.isIOS) {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      documentsPath = appDocDir.path;
    } else {
      throw Exception("Unsupported platform");
    }
    return documentsPath;
  }

  Future<void> uploadAllTemporaryPDFs(MyUser user, String userId) async {
    Directory tempDir = await getApplicationDocumentsDirectory();
    String pdfDirPath = tempDir.path;
    Directory pdfDir = Directory(pdfDirPath);

    if (!await pdfDir.exists()) {
      print("PDF catalog does not exist: $pdfDirPath");
      return;
    }

    List<FileSystemEntity> entities = await pdfDir.list().toList();

    for (FileSystemEntity entity in entities) {
      if (entity is File && entity.path.endsWith('.pdf')) {
        String fullPath = entity.path;
        // Extract the relative path from the temporary directory:
        String relativePath = fullPath.substring(tempDir.path.length + 1);
        // Remove the ".pdf" extension
        String fileUserID = "";
        if (relativePath.endsWith('.pdf')) {
          fileUserID = relativePath.substring(0, relativePath.length - 18);
          relativePath = relativePath.substring(29, relativePath.length - 4);
        }

        // Pass relativePath to the function sending to Firebase if the userId in the file is the same as the actual userId.
        if(userId == fileUserID){
          try {
            await databasePDFService.addPdfToFirebase(fullPath, "${user.company}/$fileUserID/$relativePath");
            await entity.delete();
            print("File deleted: $fullPath");
          } catch (e) {
            print("Error deleting file: $e");
          }
        }
      }
    }
  }
}