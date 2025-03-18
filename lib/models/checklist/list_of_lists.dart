class ListOfLists {
  int listNr;
  String listName;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? deletedAt;

  ListOfLists({
    required this.listNr,
    required this.listName,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  ListOfLists.fromJson(Map<String, Object?> json): this (
    listNr: json['listNr']! as int,
    listName: json['listName']! as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
    deletedAt: json['deletedAt'] != null
        ? DateTime.parse(json['deletedAt'] as String)
        : null,
  );

  ListOfLists copyWith({
    int? listNr,
    String? listName,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }){
    return ListOfLists(
      listNr: listNr?? this.listNr,
      listName: listName?? this.listName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  Map<String, Object?> toJson(){
    final Map<String, Object?> json = {
      'listNr': listNr,
      'listName': listName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
    if (deletedAt != null) json['deletedAt'] = deletedAt!.toIso8601String();
    return json;
  }
}