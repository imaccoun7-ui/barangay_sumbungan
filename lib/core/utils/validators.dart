/// Form validation rules shared by every input in the application.
class Validators {
  Validators._();

  static final RegExp _email = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
  static final RegExp _phone = RegExp(r'^[0-9+()\-\s]{7,20}$');

  static String? required(String? value, {String label = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$label is required.';
    return null;
  }

  static String? email(String? value) {
    final String? missing = required(value, label: 'Email');
    if (missing != null) return missing;
    if (!_email.hasMatch(value!.trim())) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  static String? password(String? value) {
    final String? missing = required(value, label: 'Password');
    if (missing != null) return missing;
    if (value!.length < 8) {
      return 'Use at least 8 characters.';
    }
    if (!RegExp(r'[A-Za-z]').hasMatch(value) ||
        !RegExp(r'[0-9]').hasMatch(value)) {
      return 'Include a letter and a number.';
    }
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    final String? missing = required(value, label: 'Password confirmation');
    if (missing != null) return missing;
    if (value != original) return 'Passwords do not match.';
    return null;
  }

  static String? contactNumber(String? value) {
    final String? missing = required(value, label: 'Contact number');
    if (missing != null) return missing;
    if (!_phone.hasMatch(value!.trim())) {
      return 'Enter a valid contact number.';
    }
    return null;
  }

  static String? minLength(String? value, int length, {String label = 'This field'}) {
    final String? missing = required(value, label: label);
    if (missing != null) return missing;
    if (value!.trim().length < length) {
      return '$label must be at least $length characters.';
    }
    return null;
  }
}
