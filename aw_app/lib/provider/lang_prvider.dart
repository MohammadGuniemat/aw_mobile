import 'package:flutter/material.dart';

class LangPrvider extends ChangeNotifier {
  String _lang = 'ar';

  String get lang => _lang;

  void setLang(newLang) {
    _lang = newLang;
    notifyListeners();
  }
}
