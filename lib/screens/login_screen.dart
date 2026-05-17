import 'package:flutter/material.dart';

import '../core/validators.dart';
import '../data/analytics_service.dart';
import '../data/connectivity_plus_repository.dart';
import '../data/flashlight_service.dart';
import '../data/local_auth_repository.dart';
import '../data/local_user_repository.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _authRepo = LocalAuthRepository(LocalUserRepository());
  final _connRepo = ConnectivityPlusRepository();
  final _flashlight = FlashlightService();
  final _analytics = AnalyticsService();

  String? _error;
  bool _loading = false;

  // Flashlight state
  // -1 = idle, 1/2/3 = countdown running, 0 = torch is active
  int _countdown = -1;
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _flashlight.ensureOff();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final online = await _connRepo.isOnline;
    if (!mounted) return;
    if (!online) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No internet — using local data'),
          backgroundColor: Colors.orange,
        ),
      );
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    final (user, error) = await _authRepo.login(
      _emailCtrl.text,
      _passCtrl.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (error != null) {
      setState(() => _error = error);
      _analytics.logLoginFailure(error);
      return;
    }
    _analytics.logLoginSuccess();
    Navigator.pushReplacementNamed(context, '/dashboard', arguments: user);
  }

  Future<void> _handleFlashlightTap() async {
    // If torch is already on, turn it off immediately
    if (_flashlight.isOn) {
      await _flashlight.ensureOff();
      if (_disposed) return;
      if (mounted) setState(() => _countdown = -1);
      _analytics.logTorchToggled(isOn: false, delaySeconds: 0);
      return;
    }

    // If countdown is already running, do nothing
    if (_countdown > 0) return;

    _analytics.logTorchDelayStarted(3);

    final success = await _flashlight.toggleWithDelay(
      delaySeconds: 3,
      onCountdown: (remaining) {
        if (_disposed) return;
        if (mounted) setState(() => _countdown = remaining);
      },
    );

    if (_disposed) return;
    if (mounted) setState(() => _countdown = success ? 0 : -1);

    if (success) {
      _analytics.logTorchToggled(isOn: _flashlight.isOn, delaySeconds: 3);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                const _AppLogo(),
                const SizedBox(height: 48),
                const Text(
                  'Welcome back',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign in to manage your smart home',
                  style: TextStyle(color: Colors.white54),
                ),
                const SizedBox(height: 36),
                AppTextField(
                  label: 'Email',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailCtrl,
                  validator: Validators.email,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Password',
                  icon: Icons.lock_outline,
                  obscure: true,
                  controller: _passCtrl,
                  validator: Validators.password,
                ),
                const SizedBox(height: 8),
                const _ForgotLink(),
                if (_error != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _error!,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : AppButton(label: 'Sign In', onPressed: _submit),
                const SizedBox(height: 16),
                _FlashlightButton(
                  countdown: _countdown,
                  isTorchOn: _flashlight.isOn,
                  onTap: _handleFlashlightTap,
                ),
                const SizedBox(height: 12),
                const _RegisterLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FlashlightButton extends StatelessWidget {
  const _FlashlightButton({
    required this.countdown,
    required this.isTorchOn,
    required this.onTap,
  });

  final int countdown;
  final bool isTorchOn;
  final VoidCallback onTap;

  String get _label {
    if (countdown > 0) return 'Turning on in $countdown…';
    if (isTorchOn) return 'Flashlight ON — tap to turn off';
    return 'Test Flashlight (3 s delay)';
  }

  Color _color(BuildContext context) {
    if (countdown > 0) return Colors.orange;
    if (isTorchOn) return Theme.of(context).colorScheme.primary;
    return Colors.white54;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: _color(context).withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isTorchOn ? Icons.flashlight_on : Icons.flashlight_off,
              color: _color(context),
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              _label,
              style: TextStyle(color: _color(context), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppLogo extends StatelessWidget {
  const _AppLogo();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.device_hub, color: Colors.black, size: 28),
        ),
        const SizedBox(width: 12),
        Text(
          'SmartNest',
          style: TextStyle(
            color: primary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _ForgotLink extends StatelessWidget {
  const _ForgotLink();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {},
        child: Text(
          'Forgot password?',
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }
}

class _RegisterLink extends StatelessWidget {
  const _RegisterLink();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'New to SmartNest? ',
          style: TextStyle(color: Colors.white54),
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/register'),
          child: Text(
            'Create account',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
