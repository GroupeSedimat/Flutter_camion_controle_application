// ignore_for_file: avoid_print

import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_application_1/models/checklist/blueprint.dart';
import 'package:flutter_application_1/models/checklist/list_of_lists.dart';
import 'package:flutter_application_1/models/checklist/task.dart';
import 'package:flutter_application_1/models/company/company.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/services/auth_controller.dart';
import 'package:flutter_application_1/services/check_list/database_image_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/services/database_company_service.dart';
import 'package:flutter_application_1/services/pdf/database_pdf_service.dart';
import 'package:flutter_application_1/services/user_service.dart';
import 'package:intl/intl.dart';
import 'package:open_document/open_document.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfService {
  DatabasePDFService databasePDFService = DatabasePDFService();
  AuthController authController = AuthController.instance;
  UserService userService = UserService();
  DatabaseCompanyService companyService = DatabaseCompanyService();
  DatabaseImageService databaseImageService = DatabaseImageService();
  late Map<int,Uint8List> photosToPDF;
  late int count;
  late int count2;
  late Uint8List mobilityLogo;
  late pw.PageTheme pageTheme;
  late String userID;
  late MyUser user;
  late ListOfLists list;
  late pw.Row companyColumn;
  late Company company;

  Future<pw.Font> loadFont() async {
    final fontData = await rootBundle.load("assets/fonts/roboto/Roboto-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);
    return ttf;
  }

  Future<Uint8List> createInvoice(Map<String, TaskChecklist> tasks, Map<String, Blueprint> sortedBlueprints, ListOfLists list) async {
    this.list = list;
    final pdf = pw.Document();
    userID = authController.getCurrentUserUID()!;
    user = await userService.getUserData(userID);
    company = await companyService.getCompanyByID(user.company);
    mobilityLogo = (await rootBundle.load('assets/images/keybas_logo.png')).buffer.asUint8List();
    count = 1;
    count2 = 1;
    photosToPDF = HashMap();
    final font = await loadFont();
    companyColumn = await companyDatas(company, font);
    Map<Blueprint,TaskChecklist> blueprintTaskList = HashMap();
    Map<Blueprint,TaskChecklist> sortedBlueprintTaskList = HashMap();
    for (Blueprint blueprint in sortedBlueprints.values){
      for(TaskChecklist task in tasks.values){
        if (blueprint.nrEntryPosition == task.nrEntryPosition && blueprint.nrOfList == list.listNr && task.nrOfList == list.listNr){
          blueprintTaskList.addAll({blueprint: task});
          if(task.photoFilePath != ""){
            Uint8List? photo = await databaseImageService.downloadImageFromFirebase(task.photoFilePath!);
            photosToPDF.addAll({task.nrEntryPosition!: photo!});
          }
        }
      }
    }

    pageTheme = pw.PageTheme(
      pageFormat: PdfPageFormat.a4,
      buildBackground: (context){
        return pw.FullPage(
          ignoreMargins: false,
          child: pw.Center(
            child: pw.Opacity(
              opacity: 0.3,
              child: pw.Transform.rotate(
                angle: 45, // 0.7854
                child: pw.Image(
                  pw.MemoryImage(mobilityLogo),
                  fit: pw.BoxFit.contain,
                )
              ),
            )
          )
        );
      }
    );

    sortedBlueprintTaskList = Map.fromEntries(blueprintTaskList.entries.toList()..sort(
                  (e1, e2) => (e1.value.nrEntryPosition!).compareTo(e2.value.nrEntryPosition!))
    );
    pdf.addPage(
      pw.MultiPage(
        pageTheme: pageTheme,
        build: (context) => [
          showValidation(sortedBlueprintTaskList, font),
        ],
        header: (context) => header(context, font),
        footer: (context) => footer(context, font),
      ),
    );
    if(photosToPDF.isNotEmpty) {
      pdf.addPage(
        pw.MultiPage(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          pageTheme: pageTheme,
          build: (context) => [
            if(photosToPDF.isNotEmpty)
              pw.Wrap(
                spacing: 20,
                alignment: pw.WrapAlignment.spaceAround,
                runAlignment: pw.WrapAlignment.spaceAround,
                children: [
                  for(Uint8List element in photosToPDF.values)
                    pw.Column(
                      children: [
                        pw.SizedBox(height: 20,),
                        pw.Text("Pièce jointe n°: ${count2++}"),
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
              ),
          ],
          header: (context) => header(context, font),
          footer: (context) => footer(context, font),
        ),
      );
    }
    return pdf.save();
  }




  pw.Widget showValidation(Map<Blueprint, TaskChecklist> blueprintTaskList, pw.Font font) {
    return pw.ListView.builder(
      itemCount: blueprintTaskList.length,
      itemBuilder: (context, index) {
        final entry = blueprintTaskList.entries.elementAt(index);
        return pw.Column(
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
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
                      "Validation date: ${DateFormat("dd-MM-yyyy h:mm a").format(entry.value.validationDate!.toDate())}",
                      style: pw.TextStyle(font: font),
                    ),
                  ],
                ),
                pw.Column(
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
                    if (entry.value.descriptionOfProblem != "")
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
              ],
            ),
            pw.Divider(thickness: 1, color: PdfColors.grey, height: 10),
          ],
        );
      },
    );
  }

  Future<pw.Row> companyDatas(Company company, pw.Font font) async {
    Uint8List? logoData;
    if (company.logo.isNotEmpty) {
      logoData = await downloadImage(company.logo);
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
            pw.Text("Sirene ${company.sirene}", style: pw.TextStyle(font: font)),
            if(company.tel != "")
            pw.Text("Tel ${company.tel}", style: pw.TextStyle(font: font)),
            if(company.email != "")
            pw.Text("Email ${company.email}", style: pw.TextStyle(font: font)),
            if(company.address != "")
            pw.Text("Address ${company.address}", style: pw.TextStyle(font: font)),
          ]
        )

      ]
    );
  }

  Future<Uint8List?> downloadImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        print('Error downloading image: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error downloading image: $e');
      return null;
    }
  }

  pw.Column userDatas(MyUser user, pw.Font font) {
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

  pw.Column footer(pw.Context context, pw.Font font) {
    return pw.Column(
      children: [
        pw.Divider(thickness: 1,color: PdfColors.black, height: 10 ),
        pw.Text("La personne créant ce document certifie que les données fournies sont conformes à la situation réelle.", style: pw.TextStyle(font: font, fontSize: 8)),
        pw.Text('Page ${context.pageNumber}/${context.pagesCount}'),
      ]
    );
  }

  pw.Column header(pw.Context context, pw.Font font) {
    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text("Créé avec MCTruckCheck", style: pw.TextStyle(font: font, fontSize: 14)),
            pw.Image(pw.MemoryImage(mobilityLogo), height: 50),
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

  Future<Uint8List> createInvoiceHello() async {
    String? userID = authController.getCurrentUserUID();
    MyUser user = await userService.getUserData(userID!);
    final pdf = pw.Document();
    final font = await loadFont();
    pdf.addPage(
        pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context){
              return pw.Center (
                child: pw.Text("Hello ${user.username}", style: pw.TextStyle(font: font)),
              );
            }
        )
    );
    return pdf.save();
  }

  Future<void> savePdfFile(String companyID, Uint8List data, Future<void> Function() deleteOneTaskListOfUser) async {
    int time = DateTime.now().millisecondsSinceEpoch;
    String fileName = "${user.username}.${time.toString()}";
    String documentsPath;
    if (Platform.isAndroid) {
      documentsPath = "/storage/emulated/0/Documents/camion_appli";
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
    String filePath = "$documentsPath/$fileName.pdf";
    String filePathDatabase = "${user.company}/$userID/${time.toString()}";

    final directory = Directory(documentsPath);
    if (!(await directory.exists())) {
      await directory.create(recursive: true);
    }

    final file = File(filePath);
    await file.writeAsBytes(data);

    await databasePDFService.addPdfToFirebase(filePath, filePathDatabase);
    await deleteOneTaskListOfUser();
    await OpenDocument.openDocument(filePath: filePath);
  }


}