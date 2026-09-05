import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../settings/profile.dart';
import 'home/home.dart';
import 'my_matches/joined_and_organized_matches.dart';
import 'discover/available_matches.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  late final PageController _pageController;

  final _screens = const [
    HomeScreen(),
    ExploreScreen(),
    MyMatchesScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (index) => setState(() => _currentIndex = index),
          children: _screens,
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
        color: Colors.white,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 7),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                label: 'الرئيسية',
                isActive: _currentIndex == 0,
                onTap: () => _selectTab(0),
              ),
              _NavItem(
                icon: Icons.explore_outlined,
                label: 'استكشاف',
                isActive: _currentIndex == 1,
                onTap: () => _selectTab(1),
              ),
              _NavItem(
                icon: Icons.sports_soccer_outlined,
                label: 'مبارياتي',
                isActive: _currentIndex == 2,
                onTap: () => _selectTab(2),
              ),
              _NavItem(
                icon: Icons.person_outline,
                label: 'حسابي',
                isActive: _currentIndex == 3,
                onTap: () => _selectTab(3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectTab(int index) {
    if (index == _currentIndex) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 340),
      curve: Curves.easeOutCubic,
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              width: isActive ? 42 : 38,
              height: isActive ? 42 : 38,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : Colors.white,
                shape: BoxShape.circle,
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(42),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Icon(
                  icon,
                  key: ValueKey(isActive),
                  size: 22,
                  color: isActive ? Colors.white : AppColors.slate,
                ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              style: TextStyle(
                fontSize: 11,
                height: 1.25,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? AppColors.primary : AppColors.slate,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
