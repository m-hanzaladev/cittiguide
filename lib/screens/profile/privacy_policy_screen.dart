import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: Theme.of(context).cardColor,
        iconTheme: IconThemeData(color: Theme.of(context).textTheme.bodyLarge?.color),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Effective Date: January 2026',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
             _buildSection(context, '1. Information Collection', 
              'We collect information you provide directly to us, such as when you create an account, update your profile, or post reviews. This may include your name, email address, and profile picture.'),

            _buildSection(context, '2. Use of Information', 
              'We use the information we collect to operate, love, and improve our services. This includes personalizing your experience and sending you technical notices and support messages.'),

            _buildSection(context, '3. Data Security', 
              'We implement reasonable security measures to protect the security of your personal information. However, please be aware that no method of transmission over the Internet is 100% secure.'),
            
            _buildSection(context, '4. Location Information', 
              'With your consent, we may collect information about your actual location to provide location-based services (like finding nearby attractions). You can disable this in your settings at any time.'),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
