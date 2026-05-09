import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/models/sensor_reading.dart';
import '../core/repositories/connectivity_repository.dart';
import '../core/repositories/mqtt_repository.dart';

const mqttTopics = [
  'smartnest/demo/temperature',
  'smartnest/demo/humidity',
  'smartnest/demo/motion',
];

sealed class SensorState {}

final class SensorConnecting extends SensorState {}

final class SensorConnected extends SensorState {
  SensorConnected(this.readings);
  final Map<String, SensorReading> readings;
}

final class SensorOffline extends SensorState {}

class SensorCubit extends Cubit<SensorState> {
  SensorCubit(this._mqttRepo, this._connRepo) : super(SensorConnecting());

  final MqttRepository _mqttRepo;
  final ConnectivityRepository _connRepo;
  StreamSubscription<bool>? _connSub;
  StreamSubscription<SensorReading>? _mqttSub;

  Future<void> start() async {
    final online = await _connRepo.isOnline;
    if (online) {
      await _connect();
    } else {
      emit(SensorOffline());
    }
    _connSub = _connRepo.statusStream.listen((online) {
      if (!online) {
        _mqttSub?.cancel();
        _mqttRepo.disconnect();
        emit(SensorOffline());
      } else if (state is SensorOffline || state is SensorConnecting) {
        _connect();
      }
    });
  }

  Future<void> _connect() async {
    emit(SensorConnecting());
    if (!_mqttRepo.isConnected) {
      final ok = await _mqttRepo.connect();
      if (!ok) {
        emit(SensorOffline());
        return;
      }
      _mqttRepo.subscribe(mqttTopics);
    }
    final prev = state is SensorConnected
        ? Map<String, SensorReading>.from((state as SensorConnected).readings)
        : <String, SensorReading>{};
    emit(SensorConnected(prev));
    _mqttSub?.cancel();
    _mqttSub = _mqttRepo.readings.listen(
      (r) {
        if (state is SensorConnected) {
          final updated = Map<String, SensorReading>.from(
            (state as SensorConnected).readings,
          )..[r.topic] = r;
          emit(SensorConnected(updated));
        }
      },
      onError: (_) => emit(SensorOffline()),
      onDone: () => emit(SensorOffline()),
    );
  }

  @override
  Future<void> close() {
    _connSub?.cancel();
    _mqttSub?.cancel();
    return super.close();
  }
}
