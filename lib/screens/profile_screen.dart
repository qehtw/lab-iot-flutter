import 'package:flutter/material.dart';

import '../core/models/user.dart';
import '../core/validators.dart';
import '../data/local_auth_repository.dart';
import '../data/local_user_repository.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/stat_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _userRepo = LocalUserRepository();
  final _authRepo = LocalAuthRepository(LocalUserRepository());
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _homeCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  User? _user;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _homeCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final user = await _authRepo.getCurrentUser();
    if (mounted) setState(() => _user = user);
  }

  void _startEdit() {
    _nameCtrl.text = _user?.name ?? '';
    _homeCtrl.text = _user?.homeName ?? '';
    _passCtrl.clear();
    setState(() => _editing = true);
  }

  Future<void> _saveEdit() async {
    if (_user == null || !_formKey.currentState!.validate()) return;
    final updated = _user!.copyWith(
      name: _nameCtrl.text.trim(),
      homeName: _homeCtrl.text.trim(),
      password: _passCtrl.text.isNotEmpty ? _passCtrl.text : null,
    );
    await _userRepo.update(updated);
    if (!mounted) return;
    setState(() {
      _user = updated;
      _editing = false;
    });
  }

  Future<void> _deleteAccount() async {
    final confirmed = await _showConfirm(
      'Delete account?',
      'This will permanently remove your account.',
    );
    if (!confirmed || _user == null) return;
    await _userRepo.delete(_user!.email);
    await _authRepo.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _logout() async {
    await _authRepo.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<bool> _showConfirm(String title, String body) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(body, style: const TextStyle(color: Colors.white54)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Confirm',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          if (!_editing)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: _startEdit,
            ),
        ],
      ),
      body: _user == null
          ? const Center(child: CircularProgressIndicator())
          : _editing
          ? _EditForm(
              formKey: _formKey,
              nameCtrl: _nameCtrl,
              homeCtrl: _homeCtrl,
              passCtrl: _passCtrl,
              onSave: _saveEdit,
              onCancel: () => setState(() => _editing = false),
            )
          : _ProfileView(
              user: _user!,
              onDelete: _deleteAccount,
              onLogout: _logout,
            ),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView({
    required this.user,
    required this.onDelete,
    required this.onLogout,
  });

  final User user;
  final VoidCallback onDelete;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _UserHeader(user: user, primary: primary),
        const SizedBox(height: 28),
        const Text(
          'MY HOME',
          style: TextStyle(
            color: Colors.white38,
            fontSize: 12,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        const StatCard(label: 'Devices', value: '6', icon: Icons.devices),
        const SizedBox(height: 10),
        const StatCard(label: 'Rooms', value: '4', icon: Icons.home),
        const SizedBox(height: 10),
        const StatCard(label: 'Automations', value: '3', icon: Icons.autorenew),
        const SizedBox(height: 28),
        AppButton(label: 'Sign Out', outlined: true, onPressed: onLogout),
        const SizedBox(height: 12),
        AppButton(label: 'Delete Account', outlined: true, onPressed: onDelete),
      ],
    );
  }
}

class _UserHeader extends StatelessWidget {
  const _UserHeader({required this.user, required this.primary});

  final User user;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 36,
          backgroundColor: primary.withValues(alpha: 0.2),
          child: Text(
            user.name[0].toUpperCase(),
            style: TextStyle(
              color: primary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                user.email,
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                user.homeName,
                style: TextStyle(color: primary, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EditForm extends StatelessWidget {
  const _EditForm({
    required this.formKey,
    required this.nameCtrl,
    required this.homeCtrl,
    required this.passCtrl,
    required this.onSave,
    required this.onCancel,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController homeCtrl;
  final TextEditingController passCtrl;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit Profile',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            AppTextField(
              label: 'Full Name',
              icon: Icons.person_outline,
              controller: nameCtrl,
              validator: Validators.name,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Home Name',
              icon: Icons.home,
              controller: homeCtrl,
              validator: Validators.homeName,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'New Password (optional)',
              icon: Icons.lock_outline,
              obscure: true,
              controller: passCtrl,
              validator: (v) =>
                  v != null && v.isNotEmpty ? Validators.password(v) : null,
            ),
            const SizedBox(height: 32),
            AppButton(label: 'Save Changes', onPressed: onSave),
            const SizedBox(height: 12),
            AppButton(label: 'Cancel', outlined: true, onPressed: onCancel),
          ],
        ),
      ),
    );
  }
}
