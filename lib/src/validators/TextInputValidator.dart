class TextInputValidator {
  final RegExp _decimalNumberPattern = RegExp(r'^[0-9]+(.[0-9][0-9]?)?$');
  final RegExp _yearPattern = RegExp(r'^[1-9][0-9][0-9][0-9]$');

  bool isValidRating(String rating) {
    if (rating == null ||
        rating.isEmpty ||
        rating.contains(',') ||
        double.tryParse(rating) == null ||
        double.tryParse(rating) > 10) {
      return false;
    }

    return _decimalNumberPattern.hasMatch(rating);
  }

  String setRatingErrorMessage(String rating) {
    if (rating == null || rating.isEmpty) {
      return 'This filed could not be empty';
    }

    if (!_decimalNumberPattern.hasMatch(rating) || rating.contains(',') || double.tryParse(rating) == null) {
      return 'Rating must be a valid decimal number';
    }

    if (double.tryParse(rating) > 10) {
      return 'Rating must be a number between 0 and 10';
    }

    return null;
  }

  bool isValidYear(String year) {
    if (year == null || year.isEmpty || int.tryParse(year) == null || int.tryParse(year) > 2020) {
      return false;
    }

    return _yearPattern.hasMatch(year);
  }

  String setYearErrorMessage(String year) {
    if (year == null || year.isEmpty) {
      return 'This field could not be empty';
    }

    if (_yearPattern.hasMatch(year) && int.tryParse(year) > 2020) {
      return 'Year must be lower or equal to current year';
    }

    if (!_yearPattern.hasMatch(year)) {
      return 'Year must be an integer number with 4 digits';
    }

    return null;
  }
}
