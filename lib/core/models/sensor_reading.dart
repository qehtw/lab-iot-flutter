class SensorReading {
  const SensorReading({
    required this.topic,
    required this.value,
    required this.unit,
    required this.receivedAt,
  });

  factory SensorReading.fromMqtt(String topic, String rawValue) {
    final type = topic.split('/').last;
    final unit = switch (type) {
      'temperature' => '°C',
      'humidity' => '%',
      _ => '',
    };
    return SensorReading(
      topic: topic,
      value: rawValue,
      unit: unit,
      receivedAt: DateTime.now(),
    );
  }

  final String topic;
  final String value;
  final String unit;
  final DateTime receivedAt;

  String get label {
    final type = topic.split('/').last;
    return '${type[0].toUpperCase()}${type.substring(1)}';
  }
}
