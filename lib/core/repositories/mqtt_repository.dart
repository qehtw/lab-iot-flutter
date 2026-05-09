import '../models/sensor_reading.dart';

abstract interface class MqttRepository {
  Future<bool> connect();
  void subscribe(List<String> topics);
  Stream<SensorReading> get readings;
  void disconnect();
  bool get isConnected;
}
