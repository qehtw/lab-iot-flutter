import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/repositories/automation_repository.dart';
import 'core/repositories/auth_repository.dart';
import 'core/repositories/connectivity_repository.dart';
import 'core/repositories/mqtt_repository.dart';
import 'core/repositories/user_repository.dart';
import 'cubits/automations_cubit.dart';
import 'cubits/connectivity_cubit.dart';
import 'cubits/sensor_cubit.dart';
import 'cubits/user_cubit.dart';
import 'data/connectivity_plus_repository.dart';
import 'data/firestore_automation_repository.dart';
import 'data/http_automation_repository.dart';
import 'data/local_auth_repository.dart';
import 'data/local_user_repository.dart';
import 'data/mqtt_client_repository.dart';
import 'firebase_options.dart';
import 'screens/automations_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/register_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  runZonedGuarded(_startup, (e, _) => debugPrint('Uncaught error: $e'));
}

Future<void> _startup() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.android);
    } catch (_) {}
  }

  final UserRepository userRepo = LocalUserRepository();
  final AuthRepository authRepo = LocalAuthRepository(userRepo);
  final ConnectivityRepository connRepo = ConnectivityPlusRepository();
  final MqttRepository mqttRepo = MqttClientRepository();
  final AutomationRepository autoRepo = kIsWeb
      ? HttpAutomationRepository(authRepo)
      : FirestoreAutomationRepository();

  runApp(
    SmartNestApp(
      authRepo: authRepo,
      userRepo: userRepo,
      connRepo: connRepo,
      mqttRepo: mqttRepo,
      autoRepo: autoRepo,
    ),
  );
}

class SmartNestApp extends StatelessWidget {
  const SmartNestApp({
    super.key,
    required this.authRepo,
    required this.userRepo,
    required this.connRepo,
    required this.mqttRepo,
    required this.autoRepo,
  });

  final AuthRepository authRepo;
  final UserRepository userRepo;
  final ConnectivityRepository connRepo;
  final MqttRepository mqttRepo;
  final AutomationRepository autoRepo;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => UserCubit(authRepo, userRepo)..loadUser()),
        BlocProvider(create: (_) => ConnectivityCubit(connRepo)..monitor()),
        BlocProvider(create: (_) => SensorCubit(mqttRepo, connRepo)..start()),
        BlocProvider(create: (_) => AutomationsCubit(autoRepo)..loadTasks()),
      ],
      child: MaterialApp(
        title: 'SmartNest',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF00D4AA),
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: const Color(0xFF0F1420),
        ),
        initialRoute: '/splash',
        routes: {
          '/splash': (_) => const SplashScreen(),
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/dashboard': (_) => const DashboardScreen(),
          '/profile': (_) => const ProfileScreen(),
          '/automations': (_) => const AutomationsScreen(),
        },
      ),
    );
  }
}
