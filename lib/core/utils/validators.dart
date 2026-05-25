abstract final class Validators {
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required.';
    final re = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');
    if (!re.hasMatch(value.trim())) return 'Enter a valid email address.';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required.';
    if (value.length < 8) return 'Password must be at least 8 characters.';
    if (!value.contains(RegExp(r'[A-Z]'))) return 'Include at least one uppercase letter.';
    if (!value.contains(RegExp(r'[0-9]'))) return 'Include at least one number.';
    if (!value.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
      return 'Include at least one special character.';
    }
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Please confirm your password.';
    if (value != original) return 'Passwords do not match.';
    return null;
  }

  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name is required.';
    if (value.trim().length < 2) return 'Name must be at least 2 characters.';
    return null;
  }

  static String? phoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone number is required.';
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 7 || digits.length > 15) return 'Enter a valid phone number.';
    return null;
  }

  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required.';
    return null;
  }

  static String? inviteCode(String? value) {
    if (value == null || value.trim().isEmpty) return 'Invite code is required.';
    if (value.trim().length < 6) return 'Enter a valid invite code.';
    return null;
  }

  static String? mfaCode(String? value) {
    if (value == null || value.trim().isEmpty) return 'Code is required.';
    if (value.trim().length != 6) return 'Code must be 6 digits.';
    if (!RegExp(r'^\d{6}$').hasMatch(value.trim())) return 'Code must contain only digits.';
    return null;
  }
}
