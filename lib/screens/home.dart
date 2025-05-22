import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'chat_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _auth = FirebaseAuth.instance;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text(
          'ChatApp Home',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 84, 103, 230),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              _auth.signOut();
            },
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching users'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentUser = _auth.currentUser;
          if (currentUser == null) return const Center(child: Text('User not logged in'));

          final userDocs = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['uid'] != currentUser.uid;
          }).toList();

          if (userDocs.isEmpty) {
            return const Center(child: Text('No other users found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: userDocs.length,
            itemBuilder: (context, index) {
              final data = userDocs[index].data() as Map<String, dynamic>;

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: CircleAvatar(
                    backgroundColor: const Color.fromARGB(255, 13, 126, 232),
                    child: Text(
                      data['email']?.substring(0, 1).toUpperCase() ?? '?',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    data['email'] ?? 'No Email',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.chat_bubble_outline),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          receiverUserEmail: data['email'],
                          receiverUserID: data['uid'],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
