import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class DeveloperScreen extends StatelessWidget {
  const DeveloperScreen({super.key});

  Future<void> _launchInBrowser(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> developers = [
      {
        'name': 'Reyvaldo Shiva Pramudya',
        'image': 'assets/dev/valdo.jpeg',
        'linkedin': 'https://www.linkedin.com/in/reyvaldoshivapramudya/',
      },
      {
        'name': 'Alif Nur Fadilah',
        'image': 'assets/dev/alif.jpg',
        'linkedin': 'https://www.linkedin.com/in/alif-nur-fadilah-26348a319/',
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Tim Developer')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        children: [
          // DEVELOPER LIST
          ...developers.map((dev) {
            return Column(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(dev['image']!),
                  radius: 100,
                ),
                const SizedBox(height: 12),
                Text(
                  dev['name']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                IconButton(
                  icon: const FaIcon(
                    FontAwesomeIcons.linkedin,
                    color: Colors.blueAccent,
                    size: 28,
                  ),
                  onPressed: () => _launchInBrowser(dev['linkedin']!),
                ),
                const Divider(thickness: 1, height: 40),
              ],
            );
          }),
        ],
      ),
    );
  }
}
