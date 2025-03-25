import 'package:flutter/material.dart';

import '../Screens/UserScreen.dart';
import '../Screens/Summaries.dart';
import '../Screens/SelfAssessmentScreen.dart';
import '../Screens/ProfileScreen.dart';


class NavigationViewModel extends ChangeNotifier {
  int _selectedTab = 0;

  int get selectedTab => _selectedTab;

  void changeTab(int index) {
    _selectedTab = index;
    notifyListeners();
  }

  // Returns the current screen based on selectedTab
  Widget getSelectedScreen() {
    switch (_selectedTab) {
      case 0:
        return UserData();   // Home screen widget
      case 1:
        return Summary(); // Menu screen widget
      case 2:
        return const Assessment(); // Order History screen widget
      case 3:
        return ProfileScreen(); // Profile screen widget
      default:
        return UserData();   // Default to home screen
    }
  }
}