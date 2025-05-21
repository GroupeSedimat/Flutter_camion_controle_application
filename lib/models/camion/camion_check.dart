import 'package:cloud_firestore/cloud_firestore.dart';

class CamionCheck {
  final String camionId;
  final String camionName;
  final String userId;
  final String username;
  final String companyId;
  final DateTime checkTime;
  final String? note;
  final Map<String, bool>? result;

  CamionCheck({
    required this.camionId,
    required this.camionName,
    required this.userId,
    required this.username,
    required this.companyId,
    required this.checkTime,
    this.note,
    this.result,
  });

  factory CamionCheck.fromJson(Map<String, dynamic> json) {
    return CamionCheck(
      camionId: json['camionId'],
      camionName: json['camionName'],
      userId: json['userId'],
      username: json['username'],
      companyId: json['companyId'],
      checkTime: (json['checkTime'] as Timestamp).toDate(),
      note: json['note'],
      result: json['result'] != null
          ? Map<String, bool>.from(json['result'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'camionId': camionId,
      'camionName': camionName,
      'userId': userId,
      'username': username,
      'companyId': companyId,
      'checkTime': checkTime,
      'note': note,
      'result': result,
    };
  }
}
