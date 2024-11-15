class ListOfLists {
  int listNr;
  String listName;

  ListOfLists({
    required this.listNr,
    required this.listName,
  });

  ListOfLists.fromJson(Map<String, Object?> json): this (
    listNr: json['listNr']! as int,
    listName: json['listName']! as String,
  );

  ListOfLists copyWith({
    int? listNr,
    String? listName,
  }){
    return ListOfLists(
      listNr: listNr?? this.listNr,
      listName: listName?? this.listName,
    );
  }

  Map<String, Object?> toJson(){
    return{
      'listNr': listNr,
      'listName': listName,
    };
  }
}