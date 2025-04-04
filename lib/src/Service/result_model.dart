import 'package:cloud_firestore/cloud_firestore.dart';

class ResultModel {
  final String result;
  final String status;
  final String imageUrl;
  final DateTime timestamp;

  ResultModel({
    required this.result,
    required this.status,
    required this.imageUrl,
    required this.timestamp,
  });

  // Convert model to Map for Firestore saving
  Map<String, dynamic> toMap() {
    return {
      'result': result,
      'status': status,
      'image_url': imageUrl,
      'timestamp': timestamp,
    };
  }

  // Create a ResultModel from Firestore data
  factory ResultModel.fromMap(Map<String, dynamic> map) {
    return ResultModel(
      result: map['result'] ?? '',
      status: map['status'] ?? '',
      imageUrl: map['image_url'] ?? '',
      timestamp: map['timestamp'] != null
          ? (map['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}
