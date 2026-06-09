import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  bool _isTelugu = false;

  bool get isTelugu => _isTelugu;

  void toggleLanguage() {
    _isTelugu = !_isTelugu;
    notifyListeners();
  }

  // A very simple dictionary for quick localization
  String translate(String english) {
    if (!_isTelugu) return english;
    
    final map = {
      'Home': 'హోమ్ (Home)',
      'Farming': 'వ్యవసాయం (Farming)',
      'Jobs': 'ఉద్యోగాలు (Jobs)',
      'Services': 'సేవలు (Services)',
      'Gallery': 'గ్యాలరీ (Gallery)',
      'Events': 'కార్యక్రమాలు (Events)',
      'Marketplace': 'మార్కెట్ (Market)',
      'Forum': 'చర్చా వేదిక (Forum)',
      'Village Map': 'గ్రామ మ్యాప్ (Map)',
      'Farming Knowledge Hub': 'వ్యవసాయ విజ్ఞాన కేంద్రం',
      'Village Primary School': 'గ్రామ ప్రాథమిక పాఠశాల',
      'Community Health Center': 'సామాజిక ఆరోగ్య కేంద్రం',
    };

    return map[english] ?? english;
  }
}
