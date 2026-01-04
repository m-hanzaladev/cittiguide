import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'terms_of_service_screen.dart';
import 'privacy_policy_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final prefs = user?.preferences ?? {};

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).cardColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Preferences'),
          _buildSwitchTile(
            'Push Notifications',
            'Receive updates about new attractions',
            prefs['notifications'] ?? true,
            (val) => authProvider.updatePreference('notifications', val),
          ),

          _buildSwitchTile(
            'Location Services',
            'Allow app to access your location',
            prefs['location'] ?? true,
            (val) => authProvider.updatePreference('location', val),
          ),
          

          
          const SizedBox(height: 24),
          _buildSectionHeader('About'),
          _buildListTile('Version', '1.0.0', Icons.info_outline),
          _buildListTile(
            'Terms of Service', 
            '', 
            Icons.description_outlined,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsOfServiceScreen())),
          ),
          _buildListTile(
            'Privacy Policy', 
            '', 
            Icons.privacy_tip_outlined,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildListTile(String title, String trailing, IconData icon, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).iconTheme.color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailing.isNotEmpty) 
              Text(trailing, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            if (trailing.isNotEmpty) const SizedBox(width: 8),
            if (onTap != null) const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
  
  void _showLanguageDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Language'),
        backgroundColor: Theme.of(context).cardColor,
        children: [
          _buildDialogOption(context, 'English', authProvider, 'language'),
          _buildDialogOption(context, 'Spanish', authProvider, 'language'),
          _buildDialogOption(context, 'French', authProvider, 'language'),
          _buildDialogOption(context, 'German', authProvider, 'language'),
        ],
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Currency'),
        backgroundColor: Theme.of(context).cardColor,
        children: [
          _buildDialogOption(context, 'USD (\$)', authProvider, 'currency'),
          _buildDialogOption(context, 'EUR (€)', authProvider, 'currency'),
          _buildDialogOption(context, 'GBP (£)', authProvider, 'currency'),
          _buildDialogOption(context, 'JPY (¥)', authProvider, 'currency'),
        ],
      ),
    );
  }

  Widget _buildDialogOption(BuildContext context, String value, AuthProvider authProvider, String key) {
    return SimpleDialogOption(
      onPressed: () {
        authProvider.updatePreference(key, value);
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(value, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
      ),
    );
  }
}
