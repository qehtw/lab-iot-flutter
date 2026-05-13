import 'package:flutter_test/flutter_test.dart';

import 'package:my_project/data/connectivity_plus_repository.dart';
import 'package:my_project/data/local_auth_repository.dart';
import 'package:my_project/data/local_user_repository.dart';
import 'package:my_project/data/mqtt_client_repository.dart';
import 'package:my_project/data/http_automation_repository.dart';
import 'package:my_project/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    final userRepo = LocalUserRepository();
    final authRepo = LocalAuthRepository(userRepo);
    final connRepo = ConnectivityPlusRepository();
    final mqttRepo = MqttClientRepository();
    final autoRepo = HttpAutomationRepository(authRepo);

    await tester.pumpWidget(
      SmartNestApp(
        authRepo: authRepo,
        userRepo: userRepo,
        connRepo: connRepo,
        mqttRepo: mqttRepo,
        autoRepo: autoRepo,
      ),
    );
    expect(find.text('SmartNest'), findsNothing);
  });
}
