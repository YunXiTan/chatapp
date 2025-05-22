import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Call this method to handle user registration
  Future<void> handleNewUser(User user) async {
    final userDoc = _firestore.collection('users').doc(user.uid);

    final docSnapshot = await userDoc.get();
    if (!docSnapshot.exists) {
      await userDoc.set({
        'uid': user.uid,
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Optional: Hook to be called on sign in
  Future<void> checkAndCreateUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      await handleNewUser(user);
    }
  }
}
