import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_constants.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Stacked City Images (matching reference design)
                SizedBox(
                  height: 400,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background cards with tilt effect
                      Positioned(
                        top: 20,
                        left: 20,
                        child: Transform.rotate(
                          angle: -0.1,
                          child: _buildImageCard(
                            'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=400',
                          ),
                        ),
                      ),
                      Positioned(
                        top: 40,
                        right: 20,
                        child: Transform.rotate(
                          angle: 0.1,
                          child: _buildImageCard(
                            'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?w=400',
                          ),
                        ),
                      ),
                      // Center main card
                      Positioned(
                        top: 80,
                        child: _buildImageCard(
                          'https://images.unsplash.com/photo-1499856871958-5b9627545d1a?w=400',
                          isMain: true,
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        left: 40,
                        child: Transform.rotate(
                          angle: -0.08,
                          child: _buildImageCard(
                            'https://images.unsplash.com/photo-1514565131-fce0801e5785?w=400',
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 40,
                        right: 40,
                        child: Transform.rotate(
                          angle: 0.08,
                          child: _buildImageCard(
                            'https://images.unsplash.com/photo-1480714378408-67cf0d13bc1b?w=400',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Title and Description
                Text(
                  'Explore Cities, Create\nLasting Memories',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Discover hidden gems and create unforgettable\nmoments around the world.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
                // Get Started Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: AppTheme.backgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Get Started',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: AppTheme.backgroundColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward,
                            color: AppTheme.primaryColor,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageCard(String imageUrl, {bool isMain = false}) {
    return Container(
      width: isMain ? 200 : 140,
      height: isMain ? 260 : 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppTheme.surfaceColor,
              child: const Icon(
                Icons.image,
                color: AppTheme.textTertiary,
                size: 40,
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: AppTheme.surfaceColor,
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primaryColor,
                  strokeWidth: 2,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
