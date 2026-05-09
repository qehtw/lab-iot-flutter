import 'dart:async';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import '../core/models/sensor_reading.dart';
import '../core/repositories/mqtt_repository.dart';

class MqttClientRepository implements MqttRepository {
  static final MqttClientRepository _instance = MqttClientRepository._();
  factory MqttClientRepository() => _instance;
  MqttClientRepository._();

  late MqttServerClient _client;
  final _controller = StreamController<SensorReading>.broadcast();
  bool _connected = false;

  @override
  bool get isConnected => _connected;

  @override
  Future<bool> connect() async {
    final id = 'smartnest_${DateTime.now().millisecondsSinceEpoch}';
    _client = MqttServerClient.withPort('broker.hivemq.com', id, 1883)
      ..logging(on: false)
      ..keepAlivePeriod = 20
      ..connectionMessage = MqttConnectMessage()
          .withClientIdentifier(id)
          .startClean()
          .withWillQos(MqttQos.atMostOnce);

    try {
      await _client.connect().timeout(const Duration(seconds: 10));
    } catch (_) {
      _client.disconnect();
      return false;
    }

    _connected =
        _client.connectionStatus?.state == MqttConnectionState.connected;
    if (_connected) {
      _client.updates?.listen(
        _onMessage,
        onError: (_) => _connected = false,
        onDone: () => _connected = false,
      );
    }
    return _connected;
  }

  @override
  void subscribe(List<String> topics) {
    for (final t in topics) {
      _client.subscribe(t, MqttQos.atMostOnce);
    }
  }

  void _onMessage(List<MqttReceivedMessage<MqttMessage>> messages) {
    for (final msg in messages) {
      final pub = msg.payload as MqttPublishMessage;
      final value = MqttPublishPayload.bytesToStringAsString(
        pub.payload.message,
      );
      _controller.add(SensorReading.fromMqtt(msg.topic.trim(), value.trim()));
    }
  }

  @override
  Stream<SensorReading> get readings => _controller.stream;

  @override
  void disconnect() {
    _connected = false;
    try {
      _client.disconnect();
    } catch (_) {}
  }
}
