import 'package:flutter/material.dart';
import '../../core/theme/anchor_colors.dart';
import '../../core/theme/anchor_typography.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/documents/documents_screen.dart';
import '../../features/passwords/passwords_screen.dart';
import '../../features/family/family_screen.dart';
import '../../features/security/security_screen.dart';

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
    PasswordsScreen(),
    FamilyScreen(),
    SecurityScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AnchorColors.bgWarmCream,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AnchorColors.borderSand, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedLabelStyle: AnchorTypography.labelMedium.copyWith(fontWeight: FontWeight.bold),
          unselectedLabelStyle: AnchorTypography.labelMedium,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded),
              activeIcon: Icon(Icons.grid_view_rounded, color: AnchorColors.primaryNavy),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.folder_special_outlined),
              activeIcon: Icon(Icons.folder_special, color: AnchorColors.primaryNavy),
              label: 'Vault',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.vpn_key_outlined),
              activeIcon: Icon(Icons.vpn_key_rounded, color: AnchorColors.primaryNavy),
              label: 'Passwords',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline_rounded),
              activeIcon: Icon(Icons.people_rounded, color: AnchorColors.primaryNavy),
              label: 'Family',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shield_outlined),
              activeIcon: Icon(Icons.shield_rounded, color: AnchorColors.primaryNavy),
              label: 'Security',
            ),
          ],
        ),
      ),
    );
  }
}
