import 'package:flutter/material.dart';
import '../constants/colors.dart';

class SideMenu extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const SideMenu({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: AppColors.sidebarBackground,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text(
                      'ServeDash',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionHeader('DASHBOARD'),
                  _buildMenuItem(0, Icons.dashboard_outlined, 'Dashboard', hasBadge: false),
                  _buildMenuItem(1, Icons.analytics_outlined, 'Analysis', hasBadge: true),
                  const SizedBox(height: 20),
                  _buildSectionHeader('WORKERS'),
                  _buildMenuItem(2, Icons.people_outline, 'All Workers'),
                  _buildMenuItem(3, Icons.person_add_alt_1_outlined, 'Add Worker'),
                  _buildMenuItem(4, Icons.build_outlined, 'Roles & Skills'),
                  const SizedBox(height: 20),
                  _buildSectionHeader('LISTINGS'),
                  _buildMenuItem(5, Icons.home_work_outlined, 'Properties', hasSub: true),
                  _buildMenuItem(6, Icons.post_add_outlined, 'Post Listing'),
                  const SizedBox(height: 20),
                  _buildSectionHeader('FINANCE'),
                  _buildMenuItem(7, Icons.account_balance_wallet_outlined, 'Earnings'),
                  _buildMenuItem(8, Icons.description_outlined, 'Reports'),
                ],
              ),
            ),
          ),
          const Divider(color: Colors.grey, height: 1),
          _buildSectionHeader('SYSTEM'),
          _buildMenuItem(9, Icons.settings_outlined, 'Settings'),
          const SizedBox(height: 10),
          _buildAdminProfile(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMenuItem(int index, IconData icon, String title,
      {bool hasBadge = false, bool hasSub = false}) {
    final isSelected = selectedIndex == index;
    return InkWell(
      onTap: () => onItemSelected(index),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          border: isSelected
              ? const Border(
                  left: BorderSide(color: AppColors.sidebarItemSelected, width: 4))
              : null,
          color: isSelected ? AppColors.sidebarItemSelected.withOpacity(0.1) : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.sidebarItemSelected : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (hasBadge)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'New',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            if (hasSub)
              const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminProfile() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: Colors.orange,
            child: Text('AD', style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Admin',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
              Text('Super Admin',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }
}
