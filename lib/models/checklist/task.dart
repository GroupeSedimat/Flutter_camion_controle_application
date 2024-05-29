import 'package:cloud_firestore/cloud_firestore.dart';

class TaskChecklist{
  String? descriptionOfProblem;
  String? photoFilePath;
  bool? isDone;
  int? nrOfList;
  int? nrEntryPosition;
  Timestamp? validationDate;
  String? userId;

  TaskChecklist({
    this.descriptionOfProblem,
    this.photoFilePath,
    this.isDone,
    this.nrOfList,
    this.nrEntryPosition,
    this.validationDate,
    this.userId
  });

  TaskChecklist.fromJson(Map<String, Object?> json): this (
    descriptionOfProblem: json['descriptionOfProblem']! as String,
    photoFilePath: json['photoFilePath']! as String,
    isDone: json['isDone']! as bool,
    nrOfList: json['nrOfList']! as int,
    nrEntryPosition: json['nrEntryPosition']! as int,
    validationDate: json['validationDate']! as Timestamp,
    userId: json['userId']! as String,
  );

  TaskChecklist copyWith({
    String? descriptionOfProblem,
    String? photoFilePath,
    bool? isDone,
    int? nrOfList,
    int? nrEntryPosition,
    Timestamp? validationDate,
    String? userId,
  }){
    return TaskChecklist(
        descriptionOfProblem: descriptionOfProblem?? this.descriptionOfProblem,
        photoFilePath: photoFilePath?? this.photoFilePath,
        isDone: isDone?? this.isDone,
        nrOfList: nrOfList?? this.nrOfList,
        nrEntryPosition: nrEntryPosition?? this.nrEntryPosition,
        validationDate: validationDate?? this.validationDate,
        userId: userId?? this.userId,
    );
  }

  Map<String, Object?> toJson(){
    return{
      'descriptionOfProblem': descriptionOfProblem,
      'photoFilePath': photoFilePath,
      'isDone': isDone,
      'nrOfList': nrOfList,
      'nrEntryPosition': nrEntryPosition,
      'validationDate': validationDate,
      'userId': userId,
    };
  }
}