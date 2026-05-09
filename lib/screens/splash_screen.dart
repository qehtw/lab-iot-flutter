import 'package:flutter/material.dart';

import '../data/connectivity_plus_repository.dart';
import '../data/local_auth_repository.dart';
import '../data/local_user_repository.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _authRepo = LocalAuthRepository(LocalUserRepository());
  final _connRepo = ConnectivityPlusRepository();

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    final user = await _authRepo.getCurrentUser();
    if (!mounted) return;

    if (user == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    final online = await _connRepo.isOnline;
    if (!mounted) return;

    Navigator.pushReplacementNamed(context, '/dashboard');

    if (!online) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Offline mode — some features are unavailable'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.device_hub,
                color: Colors.black,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'SmartNest',
              style: TextStyle(
                color: primary,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
