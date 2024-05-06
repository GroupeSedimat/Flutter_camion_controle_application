import 'package:cloud_firestore/cloud_firestore.dart';

class Blueprint {
  String title;
  String description;
  int nrOfList;
  int nrEntryPosition;
  Timestamp? lastUpdate;

  Blueprint({
    required this.title,
    required this.description,
    required this.nrOfList,
    required this.nrEntryPosition,
    this.lastUpdate,
  });

  Blueprint.fromJson(Map<String, Object?> json): this (
      title: json['title']! as String,
      description: json['description']! as String,
      nrOfList: json['nrOfList']! as int,
      nrEntryPosition: json['nrEntryPosition']! as int,
      lastUpdate: json['lastUpdate']! as Timestamp,
  );

  Blueprint copyWith({
    String? title,
    String? description,
    int? nrOfList,
    int? nrEntryPosition,
    Timestamp? lastUpdate,
  }){
      return Blueprint(
          title: title?? this.title,
          description: description?? this.description,
          nrOfList: nrOfList?? this.nrOfList,
          nrEntryPosition: nrEntryPosition?? this.nrEntryPosition,
          lastUpdate: lastUpdate?? this.lastUpdate,
      );
    }

    Map<String, Object?> toJson(){
      return{
        'title': title,
        'description': description,
        'nrOfList': nrOfList,
        'nrEntryPosition': nrEntryPosition,
        'lastUpdate': lastUpdate,
      };
    }
}