import 'package:flutter/material.dart';

import 'NavigationView.dart';

class BottomNavWidget extends StatefulWidget {
  const BottomNavWidget({super.key});

  @override
  _BottomNavWidgetState createState() => _BottomNavWidgetState();
}

class _BottomNavWidgetState extends State<BottomNavWidget> {
  final NavigationViewModel _viewModel = NavigationViewModel(); // ViewModel

  void _onItemTapped(int index) {
    setState(() {
      _viewModel.changeTab(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _viewModel.getSelectedScreen(), // Display screen based on ViewModel state
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white, // Set background color if needed
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.summarize_outlined),
            label: 'Summary',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            label: 'SelfAssessmentScreeny',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _viewModel.selectedTab,
        selectedItemColor: Colors.deepPurple, // Selected item color
        unselectedItemColor: Colors.black, // Set unselected item color to black or any other color
        unselectedIconTheme: IconThemeData(
          color: Colors.purple.shade200, // Light purple shade for unselected icons
        ),
        onTap: _onItemTapped,
      ),
    );
  }
}