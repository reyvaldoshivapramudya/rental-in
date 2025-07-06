import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:rentalin/app/config/theme.dart';
import 'package:rentalin/app/ui/screens/main_screen_wrapper.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    IntroComponent(
      title: "Selamat Datang",
      description:
          "Temukan kemudahan menyewa motor di Purwokerto dengan Boss Sewa Motor. Liburanmu jadi lebih bebas dan menyenangkan!",
      lottiePath: "assets/onboarding/onboarding-1.json",
    ),
    IntroComponent(
      title: "Jelajahi Purwokerto",
      description:
          "Nikmati berbagai pilihan motor matic yang irit dan nyaman untuk menemani perjalananmu menjelajahi wisata di Purwokerto dengan bebas.",
      lottiePath: "assets/onboarding/onboarding-2.json",
    ),
    IntroComponent(
      title: "Cepat & Praktis",
      description:
          "Pesan motor hanya dalam hitungan menit, tanpa ribet, dan langsung siap pakai saat kamu tiba di Purwokerto.",
      lottiePath: "assets/onboarding/onboarding-3.json",
    ),
    IntroComponent(
      title: "Ayo Mulai!",
      description:
          "Buat akunmu sekarang dan rasakan pengalaman menyewa motor dengan mudah bersama Boss Sewa Motor.",
      lottiePath: "assets/onboarding/onboarding-4.json",
    ),
  ];

  void _skip() {
    _pageController.animateToPage(
      _pages.length - 1,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _onNext() {
    if (_currentIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _onFinish();
    }
  }

  Future<void> _onFinish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainScreenWrapper()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            children: _pages,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
          ),
          Positioned(
            left: 20,
            bottom: 40,
            child: _currentIndex != _pages.length - 1
                ? TextButton(
                    onPressed: _skip,
                    child: const Text(
                      "Lewati",
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
                  )
                : const SizedBox.shrink(), // Tombol hilang di halaman terakhir
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 100,
            child: Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: _pages.length,
                effect: const WormEffect(
                  dotHeight: 12,
                  dotWidth: 12,
                  dotColor: Colors.grey,
                  activeDotColor: AppTheme.primaryColor,
                ),
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: 40,
            child: TextButton(
              onPressed: _onNext,
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
              ),
              child: Text(
                _currentIndex == _pages.length - 1 ? "Mulai" : "Lanjut",
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class IntroComponent extends StatelessWidget {
  final String title;
  final String description;
  final String lottiePath;

  const IntroComponent({
    super.key,
    required this.title,
    required this.description,
    required this.lottiePath,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            lottiePath,
            height: 300,
            repeat: true,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 30),
          Text(
            title,
            style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}
