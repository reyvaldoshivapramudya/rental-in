import 'package:flutter/material.dart';

class NavigationProvider with ChangeNotifier {
  String? _targetRoute;

  String? get targetRoute => _targetRoute;

  void setTargetRoute(String route) {
    _targetRoute = route;
    // Tidak perlu notifyListeners() karena kita akan membacanya sekali saat initState
  }

  void clearTargetRoute() {
    _targetRoute = null;
  }
}