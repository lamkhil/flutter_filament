import 'package:flutter/foundation.dart';

/// Mutable state shared across a form's components during render.
/// Mirrors Filament's `$set` / `$get` reactive form context.
class FormStateController extends ChangeNotifier {
  final Map<String, dynamic> _values;
  final Map<String, String?> _errors = {};

  FormStateController({Map<String, dynamic>? initial})
      : _values = {...?initial};

  Map<String, dynamic> get values => Map.unmodifiable(_values);
  Map<String, String?> get errors => Map.unmodifiable(_errors);

  T? get<T>(String key) => _values[key] as T?;

  void set(String key, dynamic value) {
    if (_values[key] == value) return;
    _values[key] = value;
    _errors.remove(key);
    notifyListeners();
  }

  void setAll(Map<String, dynamic> updates) {
    var changed = false;
    updates.forEach((k, v) {
      if (_values[k] != v) {
        _values[k] = v;
        _errors.remove(k);
        changed = true;
      }
    });
    if (changed) notifyListeners();
  }

  String? errorOf(String key) => _errors[key];

  void setError(String key, String? error) {
    if (_errors[key] == error) return;
    _errors[key] = error;
    notifyListeners();
  }

  void clearErrors() {
    if (_errors.isEmpty) return;
    _errors.clear();
    notifyListeners();
  }

  bool get hasErrors => _errors.values.any((e) => e != null);
}
