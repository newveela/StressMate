import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'LoginScreen.dart';
import 'package:stressmate/main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _fetchUserProfile().then((_) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future<void> _checkLoginStatus() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  Future<void> _fetchUserProfile() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUser.email).get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          User_Info.name = userData['name'] ?? 'No Name Available';
          User_Info.email = userData['email'] ?? 'No Email Available';
          User_Info.phoneNo = userData['phone'] ?? 'No Phone Number';
          User_Info.friendName = userData['friendName'] ?? 'No Friend Name';
          User_Info.friendContact = userData['friendContact'] ?? 'No Friend Email';
          User_Info.profile_link = userData['profilePhotoUrl'] ?? 'https://via.placeholder.com/150';
        });
      }
    }
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: _logout,
          ),
        ],
        backgroundColor: Colors.blueAccent,

      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: 'Personal Information',
              icon: Icons.person_outline,
              child: Column(
                children: [
                  _buildField('Name', User_Info.name, Icons.person),
                  _buildField('Phone', User_Info.phoneNo, Icons.phone),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: 'Emergency Contact',
              icon: Icons.group,
              child: Column(
                children: [
                  _buildField('Friend\'s Name', User_Info.friendName, Icons.person),
                  _buildField('Friend\'s Email', User_Info.friendContact, Icons.email),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(User_Info.profile_link ?? ''),
            onBackgroundImageError: (_, __) {
              // Log the error if needed
              print("Failed to load profile image");
            },
            child: Icon(Icons.person, size: 50), // Fallback icon in case of error
          ),

          const SizedBox(height: 8),
          Text(
            User_Info.name ?? 'No Name Available',
            style: const TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            User_Info.email ?? 'No Email Available',
            style: const TextStyle(fontSize: 14, color: Colors.black),
          ),
        ],
      ),
    );
  }


  Widget _buildField(String label, String? value, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: value ?? 'N/A',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
