import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rentalin/app/config/theme.dart';
import 'package:rentalin/app/providers/navigation_provider.dart';
import 'package:rentalin/app/providers/sewa_provider.dart';
import 'package:rentalin/app/providers/user_provider.dart';
import 'package:rentalin/app/ui/screens/admin/dashboard_screen.dart';
import 'package:rentalin/app/ui/screens/splash_screen.dart';
import 'package:rentalin/app/ui/screens/user/home_screen.dart';
import 'app/providers/auth_provider.dart';
import 'app/providers/motor_provider.dart';
// ✨ TAMBAHKAN IMPORT UNTUK HALAMAN TUJUAN ✨
import 'package:rentalin/app/ui/screens/user/history_screen.dart';
import 'package:rentalin/app/ui/screens/admin/manage_bookings_screen.dart';

// GlobalKey ini sudah Anda miliki, ini sudah benar.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp();

  // Pindahkan inisialisasi OneSignal ke sini agar bisa dipakai sebelum runApp
  _initializeOneSignal();

  runApp(const MyApp());
}

// ✨ BUAT FUNGSI BARU UNTUK INISIALISASI ONESIGNAL ✨
void _initializeOneSignal() {
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize(dotenv.env['ONESIGNAL_APP_ID']!);
  OneSignal.Notifications.requestPermission(true);

  OneSignal.Notifications.addClickListener((event) {
    final Map<String, dynamic>? additionalData =
        event.notification.additionalData;
    final String? targetScreen = additionalData?['target_screen'];

    if (targetScreen != null) {
      final navigator = navigatorKey.currentState;
      if (navigator == null) return;

      if (targetScreen == 'history_screen') {
        // Logika untuk USER sudah benar, tidak perlu diubah.
        final context = navigatorKey.currentContext;
        if (context != null) {
          Provider.of<NavigationProvider>(
            context,
            listen: false,
          ).setTargetRoute('history_screen');
        }
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      } else if (targetScreen == 'manage_bookings_screen') {

        // 1. Bersihkan tumpukan dan jadikan DashboardScreen sebagai halaman dasar.
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
          (route) => false,
        );

        // 2. Dorong ManageBookingsScreen di atasnya.
        navigator.push(
          MaterialPageRoute(builder: (_) => const ManageBookingsScreen()),
        );
      }
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MotorProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(
          create: (context) =>
              SewaProvider(Provider.of<AuthProvider>(context, listen: false)),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey, // navigatorKey sudah terpasang, ini benar.
        debugShowCheckedModeBanner: false,
        title: 'Rentalin | Boss Sewa Motor',
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
