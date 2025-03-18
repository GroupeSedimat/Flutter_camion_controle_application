class TaskChecklist{
  String? descriptionOfProblem;
  String? photoFilePath;
  bool? isDone;
  int nrOfList;
  int nrEntryPosition;
  String? userId;
  DateTime createdAt;
  DateTime updatedAt;

  TaskChecklist({
    this.descriptionOfProblem,
    this.photoFilePath,
    this.isDone,
    required this.nrOfList,
    required this.nrEntryPosition,
    this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  TaskChecklist.fromJson(Map<String, Object?> json): this (
    descriptionOfProblem: json['descriptionOfProblem'] != null ? json['descriptionOfProblem'] as String : null,
    photoFilePath: json['photoFilePath'] != null ? json['photoFilePath'] as String : null,
    isDone: json['isDone'] != null ? json['isDone'] as bool : null,
    nrOfList: json['nrOfList']! as int,
    nrEntryPosition: json['nrEntryPosition']! as int,
    userId: json['userId'] != null ? json['userId'] as String : null,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  TaskChecklist copyWith({
    String? descriptionOfProblem,
    String? photoFilePath,
    bool? isDone,
    int? nrOfList,
    int? nrEntryPosition,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }){
    return TaskChecklist(
      descriptionOfProblem: descriptionOfProblem?? this.descriptionOfProblem,
      photoFilePath: photoFilePath?? this.photoFilePath,
      isDone: isDone?? this.isDone,
      nrOfList: nrOfList?? this.nrOfList,
      nrEntryPosition: nrEntryPosition?? this.nrEntryPosition,
      userId: userId?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toJson(){
    final Map<String, Object?> json = {
      'nrOfList': nrOfList,
      'nrEntryPosition': nrEntryPosition,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
    if (descriptionOfProblem != null) json['descriptionOfProblem'] = descriptionOfProblem;
    if (photoFilePath != null) json['photoFilePath'] = photoFilePath;
    if (isDone != null) json['isDone'] = isDone;
    if (userId != null) json['userId'] = userId;
    return json;
  }
}