import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentalin/app/ui/screens/user/home_screen.dart';
import '../../providers/auth_provider.dart';
import '../../data/models/user_role.dart';
import 'admin/dashboard_screen.dart';
import 'auth/login_screen.dart';

class MainScreenWrapper extends StatelessWidget {
  const MainScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (authProvider.user == null) {
          return const LoginScreen();
        } else {
          return authProvider.user!.role == UserRole.admin
              ? const DashboardScreen()
              : const HomeScreen();
        }
      },
    );
  }
}
