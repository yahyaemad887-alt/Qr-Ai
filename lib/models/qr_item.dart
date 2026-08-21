import 'package:hive/hive.dart';

part 'qr_item.g.dart';

@HiveType(typeId: 0)
class QRItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String data;

  @HiveField(2)
  final String type;

  @HiveField(3)
  final DateTime timestamp;

  QRItem({
    required this.id,
    required this.data,
    required this.type,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'data': data,
    'type': type,
    'timestamp': timestamp.toIso8601String(),
  };

  factory QRItem.fromJson(Map<String, dynamic> json) => QRItem(
    id: json['id'],
    data: json['data'],
    type: json['type'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}