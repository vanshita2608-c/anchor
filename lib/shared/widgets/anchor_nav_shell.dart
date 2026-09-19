import 'package:flutter/material.dart';
import '../../core/theme/anchor_colors.dart';
import '../../core/theme/anchor_typography.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/documents/documents_screen.dart';
import '../../features/family/family_screen.dart';
import '../../features/security/security_screen.dart';
import '../../features/profile/profile_screen.dart';

class AnchorNavShell extends StatefulWidget {
  const AnchorNavShell({Key? key}) : super(key: key);

  @override
  State<AnchorNavShell> createState() => _AnchorNavShellState();
}

class _AnchorNavShellState extends State<AnchorNavShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    DocumentsScreen(),
    FamilyScreen(),
    SecurityScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: AnchorColors.cardWhite,
        selectedItemColor: AnchorColors.primaryNavy,
        unselectedItemColor: AnchorColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: AnchorTypography.labelMedium.copyWith(fontWeight: FontWeight.bold),
        unselectedLabelStyle: AnchorTypography.labelMedium,
        items: const [
          BottomNavigationBarView(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarView(icon: Icon(Icons.folder_special_outlined), activeIcon: Icon(Icons.folder_special), label: 'Vault'),
          BottomNavigationBarView(icon: Icon(Icons.group_outlined), activeIcon: Icon(Icons.group), label: 'Family'),
          BottomNavigationBarView(icon: Icon(Icons.shield_outlined), activeIcon: Icon(Icons.shield), label: 'Security'),
          BottomNavigationBarView(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class BottomNavigationBarView extends BottomNavigationBarItem {
  const BottomNavigationBarView({
    required Widget icon,
    required Widget activeIcon,
    required String label,
  }) : super(icon: icon, activeIcon: activeIcon, label: label);
}
