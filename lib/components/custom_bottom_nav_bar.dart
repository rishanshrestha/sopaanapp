import 'package:flutter/material.dart';
import '../career_profile/career_profile_screen.dart';
import '../cv_builder_screens/convert_to_cv.dart';
import '../home/homepage.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  /// Standard navigation handler across all screens with the bottom nav bar.
  static void navigateTo(BuildContext context, int index, {int currentIndex = -1}) {
    if (index == currentIndex) return;

    switch (index) {
      case 0: // Home
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const Homepage()),
          (route) => false,
        );
        break;
      case 1: // Jobs
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Opening Jobs...'),
            duration: Duration(seconds: 1),
          ),
        );
        break;
      case 2: // Career
      case 4: // Profile
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CareerProfileScreen()),
        );
        break;
      case 3: // CV
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CVFromProfileScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    const items = [
      _NavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: 'Home',
      ),
      _NavItem(
        icon: Icons.work_outline_rounded,
        activeIcon: Icons.work_rounded,
        label: 'Jobs',
      ),
      _NavItem(
        icon: Icons.explore_outlined,
        activeIcon: Icons.explore_rounded,
        label: 'Career',
      ),
      _NavItem(
        icon: Icons.description_outlined,
        activeIcon: Icons.description_rounded,
        label: 'CV',
      ),
      _NavItem(
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: 'Profile',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final isSelected = currentIndex == index;
              final item = items[index];

              return InkWell(
                onTap: () {
                  if (onTap != null) {
                    onTap!(index);
                  } else {
                    navigateTo(context, index, currentIndex: currentIndex);
                  }
                },
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      isSelected
                          ? Container(
                              width: 48,
                              height: 38,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF2DD4BF), // Vibrant Teal
                                    Color(0xFF3B82F6), // Vibrant Blue
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF2DD4BF).withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Icon(
                                item.activeIcon,
                                color: Colors.white,
                                size: 22,
                              ),
                            )
                          : SizedBox(
                              width: 48,
                              height: 38,
                              child: Icon(
                                item.icon,
                                color: const Color(0xFF94A3B8), // slate / muted grey
                                size: 24,
                              ),
                            ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected
                              ? const Color(0xFF14B8A6) // active teal
                              : const Color(0xFF94A3B8), // inactive grey
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
