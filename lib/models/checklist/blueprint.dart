class Blueprint {
  String title;
  String description;
  List<String>? photoFilePath;
  int nrOfList;
  int nrEntryPosition;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? deletedAt;

  Blueprint({
    required this.title,
    required this.description,
    this.photoFilePath,
    required this.nrOfList,
    required this.nrEntryPosition,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  Blueprint.fromJson(Map<String, Object?> json): this (
    title: json['title']! as String,
    description: json['description']! as String,
    photoFilePath: json['photoFilePath'] != null
        ? (json['photoFilePath'] as List<dynamic>)
        .map((item) => item as String)
        .toList()
        : null,
    nrOfList: json['nrOfList']! as int,
    nrEntryPosition: json['nrEntryPosition']! as int,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
    deletedAt: json['deletedAt'] != null
        ? DateTime.parse(json['deletedAt'] as String)
        : null,
  );

  Blueprint copyWith({
    String? title,
    String? description,
    List<String>? photoFilePath,
    int? nrOfList,
    int? nrEntryPosition,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }){
      return Blueprint(
        title: title?? this.title,
        description: description?? this.description,
        photoFilePath: photoFilePath?? this.photoFilePath,
        nrOfList: nrOfList?? this.nrOfList,
        nrEntryPosition: nrEntryPosition?? this.nrEntryPosition,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt ?? this.deletedAt,
      );
    }

    Map<String, Object?> toJson(){
      final Map<String, Object?> json = {
        'title': title,
        'description': description,
        'nrOfList': nrOfList,
        'nrEntryPosition': nrEntryPosition,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
      if (photoFilePath != null) json['photoFilePath'] = photoFilePath!.map((item) => item).toList();
      if (deletedAt != null) json['deletedAt'] = deletedAt!.toIso8601String();
      return json;
    }
}