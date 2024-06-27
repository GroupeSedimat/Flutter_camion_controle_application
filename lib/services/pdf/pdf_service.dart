import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_application_1/models/checklist/blueprint.dart';
import 'package:flutter_application_1/models/checklist/list_of_lists.dart';
import 'package:flutter_application_1/models/checklist/task.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/services/auth_controller.dart';
import 'package:flutter_application_1/services/pdf/database_pdf_service.dart';
import 'package:flutter_application_1/services/user_service.dart';
import 'package:intl/intl.dart';
import 'package:open_document/open_document.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfService {
  DatabasePDFService databasePDFService = DatabasePDFService();
  AuthController authController = AuthController.instance;
  UserService userService = UserService();

  Future<pw.Font> loadFont() async {
    final fontData = await rootBundle.load("assets/fonts/roboto/Roboto-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);
    return ttf;
  }

  Future<Uint8List> createInvoice(Map<String, TaskChecklist> tasks, Map<String, Blueprint> sortedBlueprints, ListOfLists list) async {
    String? userID = authController.getCurrentUserUID();
    MyUser user = await userService.getUserData(userID!);
    final pdf = pw.Document();
    final font = await loadFont();
    Map<Blueprint,TaskChecklist> blueprintTaskList = HashMap();
    for (Blueprint blueprint in sortedBlueprints.values){
      for(TaskChecklist task in tasks.values){
        if (blueprint.nrEntryPosition == task.nrEntryPosition && blueprint.nrOfList == list.listNr && task.nrOfList == list.listNr){
          blueprintTaskList.addAll({blueprint: task});
          print("blueprint: ${blueprint.nrEntryPosition}");
          print("task: ${task.nrEntryPosition}");
        }
      }
    }
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context){
          return pw.Column(
            children:[
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  userDatas(user, font),
                  companyDatas(user, font)
                ],
              ),
              pw.SizedBox(height: 20,),
              pw.Text(
                  "List ${list.listName}",
                  style: pw.TextStyle(font: font, fontSize: 14, fontWeight: pw.FontWeight.bold, letterSpacing: 4, wordSpacing: 10)
              ),
              pw.SizedBox(height: 10,),
              showValidation(blueprintTaskList, font),
            ],
          );
        }
      )
    );
    return pdf.save();
  }

  pw.Column showValidation(Map<Blueprint, TaskChecklist> blueprintTaskList, pw.Font font) {
    return pw.Column(
      children: blueprintTaskList.entries.map((entry) {
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
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "Is ok: ${entry.value.isDone}",
                      style: pw.TextStyle(font: font),
                    ),
                    pw.Text(
                      "Problem: ${entry.value.descriptionOfProblem}",
                      style: pw.TextStyle(font: font),
                    ),
                    pw.Text(
                      "Validation date: ${DateFormat("dd-MM-yyyy h:mm a").format(blueprintTaskList.values.first.validationDate!.toDate())}",
                      style: pw.TextStyle(font: font),
                    ),
                  ],
                ),
              ],
            ),
            pw.Divider(thickness: 1,color: PdfColors.grey, height: 10 ),
          ]
        );
      }).toList(),
    );
  }

  pw.Column companyDatas(MyUser user, pw.Font font) {
    return pw.Column(
                  children: [
                    pw.Text("Company ${user.company}", style: pw.TextStyle(font: font)),
                    pw.Text("Company image", style: pw.TextStyle(font: font)),
                    pw.Text("Company adress", style: pw.TextStyle(font: font)),
                    pw.Text("Company contact", style: pw.TextStyle(font: font)),
                  ]
                );
  }

  pw.Column userDatas(MyUser user, pw.Font font) {
    DateTime now = DateTime.now();
    DateTime localTime = now.toLocal();
    String formattedTime = DateFormat("yyyy-MM-dd HH:mm:ss").format(localTime);
    return pw.Column(
                  children: [
                    pw.Text("User ${user.username}", style: pw.TextStyle(font: font)),
                    pw.Text("Role ${user.role}", style: pw.TextStyle(font: font)),
                    pw.Text("In company ${user.company}", style: pw.TextStyle(font: font)),
                    pw.Text("Created $formattedTime", style: pw.TextStyle(font: font)),
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

  Future<void> savePdfFile(String company, Uint8List data) async {
    int time = DateTime.now().millisecondsSinceEpoch;
    String? userID = authController.getCurrentUserUID();
    String fileName = "$company/$userID/${time.toString()}";
    String documentsPath = "/storage/emulated/0/Documents";
    String filePath = "$documentsPath/$fileName.pdf";

    final directory = Directory("$documentsPath/$company/$userID");
    if (!(await directory.exists())) {
      await directory.create(recursive: true);
    }

    final file = File(filePath);
    await file.writeAsBytes(data);

    await databasePDFService.addPdfToFirebase(filePath, fileName);
    await OpenDocument.openDocument(filePath: filePath);
  }


}