import 'package:flutter/material.dart';
import '../models/worker.dart';
import '../widgets/side_menu.dart';
import '../widgets/responsive_layout.dart';
import 'dashboard/dashboard_screen.dart';
import 'dashboard/analysis_screen.dart';
import 'workers/add_worker_screen.dart';
import 'workers/workers_list_screen.dart';
import 'listings/post_listing_screen.dart';
import 'listings/properties_screen.dart';
import 'finance/earnings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  Worker? _editingWorker;

  void _onEditWorker(Worker worker) {
    setState(() {
      _editingWorker = worker;
      _selectedIndex = 3; // Index of AddWorkerScreen
    });
  }

  void _resetWorkerEdit() {
    setState(() {
      _editingWorker = null;
      _selectedIndex = 2; // Back to List
    });
  }

  void _onAddWorker() {
    setState(() {
      _editingWorker = null;
      _selectedIndex = 3;
    });
  }

  List<Widget> get _screens => [
    const DashboardScreen(),
    const AnalysisScreen(),
    WorkersListScreen(onEdit: _onEditWorker, onAdd: _onAddWorker),
    AddWorkerScreen(
      initialWorker: _editingWorker,
      onCancel: _resetWorkerEdit,
    ),
    const Center(child: Text('Roles & Skills')),
    const PropertiesScreen(),
    const PostListingScreen(),
    const EarningsScreen(),
    const Center(child: Text('Reports')),
    const Center(child: Text('Settings')),
  ];

  @override
  Widget build(BuildContext context) {
    final currentScreens = _screens;
    return Scaffold(
      drawer: SideMenu(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
            if (index == 3) _editingWorker = null;
          });
          Navigator.pop(context); // Close drawer on mobile
        },
      ),
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(currentScreens),
        desktop: _buildDesktopLayout(currentScreens),
      ),
    );
  }

  Widget _buildMobileLayout(List<Widget> currentScreens) {
    return Column(
      children: [
        AppBar(
          title: const Text('Admin Panel'),
          elevation: 0,
        ),
        Expanded(child: currentScreens[_selectedIndex]),
      ],
    );
  }

  Widget _buildDesktopLayout(List<Widget> currentScreens) {
    return Row(
      children: [
        SideMenu(
          selectedIndex: _selectedIndex,
          onItemSelected: (index) {
            setState(() {
              _selectedIndex = index;
              if (index == 3) _editingWorker = null;
            });
          },
        ),
        Expanded(
          child: currentScreens[_selectedIndex],
        ),
      ],
    );
  }
}
