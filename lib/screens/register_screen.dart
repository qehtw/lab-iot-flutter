import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/models/user.dart';
import '../core/validators.dart';
import '../cubits/user_cubit.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _homeCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _homeCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final user = User(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      homeName: _homeCtrl.text.trim(),
      password: _passCtrl.text,
    );
    final error = await context.read<UserCubit>().register(user);
    if (!mounted) return;
    setState(() => _loading = false);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create account',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Join SmartNest and automate your home',
                  style: TextStyle(color: Colors.white54),
                ),
                const SizedBox(height: 32),
                AppTextField(
                  label: 'Full Name',
                  icon: Icons.person_outline,
                  controller: _nameCtrl,
                  validator: Validators.name,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Email',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailCtrl,
                  validator: Validators.email,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Home Name',
                  icon: Icons.home,
                  controller: _homeCtrl,
                  validator: Validators.homeName,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Password',
                  icon: Icons.lock_outline,
                  obscure: true,
                  controller: _passCtrl,
                  validator: Validators.password,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Confirm Password',
                  icon: Icons.lock_outline,
                  obscure: true,
                  controller: _confirmCtrl,
                  validator: Validators.confirmPassword(() => _passCtrl.text),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : AppButton(label: 'Create Account', onPressed: _submit),
                const SizedBox(height: 20),
                const _SignInLink(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SignInLink extends StatelessWidget {
  const _SignInLink();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Already have an account? ',
          style: TextStyle(color: Colors.white54),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Text(
            'Sign in',
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
