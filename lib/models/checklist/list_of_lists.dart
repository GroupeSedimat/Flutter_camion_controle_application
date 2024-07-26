class ListOfLists {
  int listNr;
  String listName;
  List<String> types;

  ListOfLists({
    required this.listNr,
    required this.listName,
    required this.types
  });

  ListOfLists.fromJson(Map<String, Object?> json): this (
    listNr: json['listNr']! as int,
    listName: json['listName']! as String,
    types: (json['types']! as List).map((item) => item as String).toList(),
  );

  ListOfLists copyWith({
    int? listNr,
    String? listName,
    List<String>? types,
  }){
    return ListOfLists(
      listNr: listNr?? this.listNr,
      listName: listName?? this.listName,
      types: types?? this.types,
    );
  }

  Map<String, Object?> toJson(){
    return{
      'listNr': listNr,
      'listName': listName,
      'types': types,
    };
  }
}