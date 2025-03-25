import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Screens/TestUser.dart';
import 'firebase_options.dart';
import 'Screens/UserScreen.dart';
import 'Screens/Summaries.dart';
import 'Screens/SelfAssessmentScreen.dart';
import 'Screens/ProfileScreen.dart';
import 'Screens/LoginScreen.dart';
import 'navigation/BottomNavWidget.dart';
import 'Screens/SplashScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashWrapper(),
    );
  }
}

class SplashWrapper extends StatefulWidget {
  const SplashWrapper({Key? key}) : super(key: key);

  @override
  _SplashWrapperState createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await _fetchUserProfile(currentUser); // Preload user profile data
    }
    Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthWrapper()),
      );
    });
  }

  Future<void> _fetchUserProfile(User currentUser) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      DocumentSnapshot userDoc =
      await firestore.collection('users').doc(currentUser.email).get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        User_Info.name = userData['name'] ?? 'No Name Available';
        User_Info.email = userData['email'] ?? 'No Email Available';
        User_Info.phoneNo = userData['phone'] ?? 'No Phone Number';
        User_Info.friendName = userData['friendName'] ?? 'No Friend Name';
        User_Info.friendContact = userData['friendContact'] ?? 'No Friend Contact';
        User_Info.profile_link =
            userData['profilePhotoUrl'] ?? 'https://via.placeholder.com/150';
      }
    } catch (e) {
      print("Error fetching user profile: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}



class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen(); // Use SplashScreen to avoid black screen
        }
        if (snapshot.hasData) {
          return const MainScreen(); // If user is authenticated, go to MainScreen
        } else {
          return const LoginScreen(); // If not, show the login screen
        }
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    TestUserData(),
    Summary(),
    Assessment(),
    ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        backgroundColor: Colors.deepPurple, // Set the background color
        selectedItemColor: Colors.blueAccent, // Set the color of the selected item
        unselectedItemColor: Colors.grey, // Set the color of unselected items
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'User'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Summary'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Assess'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}


class User_Info {
  static String? name;
  static int? age;
  static String? email;
  static String? phoneNo;
  static String? friendName;
  static String? friendContact;
  static String? profile_link;
}
