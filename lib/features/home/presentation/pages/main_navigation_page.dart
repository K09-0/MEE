import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../creator/presentation/pages/creator_studio_page.dart';
import '../../../marketplace/presentation/pages/feed_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../wallet/presentation/pages/wallet_page.dart';

/// Main Navigation Page
/// 
/// Главная навигация приложения с Bottom Navigation Bar
/// Содержит 4 вкладки: Feed, Create, Wallet, Profile
class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    const FeedPage(),
    const CreatorStudioPage(),
    const WalletPage(),
    const ProfilePage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    // Haptic feedback on tab change
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppTheme.primaryColor,
            unselectedItemColor: AppTheme.textTertiaryDark,
            selectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
            items: [
              BottomNavigationBarItem(
                icon: Icon(
                  _currentIndex == 0 ? Icons.home : Icons.home_outlined,
                ),
                label: 'Feed',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: _currentIndex == 1
                        ? const LinearGradient(colors: AppTheme.primaryGradient)
                        : null,
                    color: _currentIndex == 1 ? null : AppTheme.surfaceDarker,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _currentIndex == 1 ? Icons.add : Icons.add,
                    color: _currentIndex == 1 ? Colors.white : AppTheme.textTertiaryDark,
                    size: 24,
                  ),
                ),
                label: 'Create',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  _currentIndex == 2
                      ? Icons.account_balance_wallet
                      : Icons.account_balance_wallet_outlined,
                ),
                label: 'Wallet',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  _currentIndex == 3 ? Icons.person : Icons.person_outline,
                ),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
