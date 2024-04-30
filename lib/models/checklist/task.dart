import 'package:cloud_firestore/cloud_firestore.dart';

class Task{
  String? descriptionOfProblem;
  String? photoFilePath;
  bool? isDone;
  int? nrOfList;
  int? nrEntryPosition;
  Timestamp? validationDate;

  Task({
    this.descriptionOfProblem,
    this.photoFilePath,
    this.isDone,
    this.nrOfList,
    this.nrEntryPosition,
    this.validationDate
  });

  Task.fromJson(Map<String, Object?> json): this (
    descriptionOfProblem: json['descriptionOfProblem']! as String,
    photoFilePath: json['photoFilePath']! as String,
    isDone: json['isDone']! as bool,
    nrOfList: json['nrOfList']! as int,
    nrEntryPosition: json['nrEntryPosition']! as int,
    validationDate: json['validationDate']! as Timestamp,
  );

  Task copyWith({
    String? descriptionOfProblem,
    String? photoFilePath,
    bool? isDone,
    int? nrOfList,
    int? nrEntryPosition,
    Timestamp? validationDate,
  }){
    return Task(
        descriptionOfProblem: descriptionOfProblem?? this.descriptionOfProblem,
        photoFilePath: photoFilePath?? this.photoFilePath,
        isDone: isDone?? this.isDone,
        nrOfList: nrOfList?? this.nrOfList,
        nrEntryPosition: nrEntryPosition?? this.nrEntryPosition,
        validationDate: validationDate?? this.validationDate
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
    };
  }
}