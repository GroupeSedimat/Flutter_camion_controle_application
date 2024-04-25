import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  String title;
  String description;
  int? nrOfList;
  int? nrEntryPosition;
  Timestamp? deleted;
  Timestamp? lastUpdate;

  Task({
    required this.title,
    required this.description,
    this.nrOfList,
    this.nrEntryPosition,
    this.deleted,
    this.lastUpdate,
  });

  Task.fromJson(Map<String, Object?> json): this (
      title: json['title']! as String,
      description: json['description']! as String,
      nrOfList: json['nrOfList']! as int,
      nrEntryPosition: json['nrEntryPosition']! as int,
      deleted: json['deleted']! as Timestamp,
      lastUpdate: json['lastUpdate']! as Timestamp,
  );

  Task copyWith({
    String? title,
    String? description,
    int? nrOfList,
    int? nrEntryPosition,
    Timestamp? deleted,
    Timestamp? lastUpdate,
    }){
      return Task(
          title: title?? this.title,
          description: description?? this.description,
          nrOfList: nrOfList?? this.nrOfList,
          nrEntryPosition: nrEntryPosition?? this.nrEntryPosition,
          deleted: deleted?? this.deleted,
          lastUpdate: lastUpdate?? this.lastUpdate,
      );
    }

    Map<String, Object?> toJson(){
      return{
        'title': title,
        'description': description,
        'nrOfList': nrOfList,
        'nrEntryPosition': nrEntryPosition,
        'deleted': deleted,
        'lastUpdate': lastUpdate,
      };
    }
}