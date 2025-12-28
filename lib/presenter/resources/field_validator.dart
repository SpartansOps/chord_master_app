class TextValidators {
  static String? required(String? value,
      {String message = 'Campo obrigatório'}) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? onlyNumbers(String? value,
      {String message = 'Apenas números'}) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final numericRegex = RegExp(r'^\d+$');
    if (!numericRegex.hasMatch(value)) {
      return message;
    }
    return null;
  }

  static String? combine(
    String? value,
    List<String? Function(String?)> validators,
  ) {
    for (final validator in validators) {
      final result = validator(value);
      if (result != null) {
        return result;
      }
    }
    return null;
  }
}
