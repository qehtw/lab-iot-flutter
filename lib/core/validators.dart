class Validators {
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name is required';
    if (RegExp(r'\d').hasMatch(value)) return 'Name must not contain digits';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final ok = RegExp(
      r'^[\w.+-]+@[\w-]+\.[a-z]{2,}$',
      caseSensitive: false,
    ).hasMatch(value.trim());
    if (!ok) return 'Enter a valid email';
    return null;
  }

  static String? homeName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Home name is required';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Minimum 6 characters';
    return null;
  }

  static String? Function(String?) confirmPassword(
    String Function() getPassword,
  ) => (value) {
    if (value != getPassword()) return 'Passwords do not match';
    return null;
  };
}
