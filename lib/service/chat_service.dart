import 'package:chatapp/model/message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(String receiverUserID, String message) async {
  final user = _firebaseAuth.currentUser;
  if (user == null) {
    throw Exception("User not logged in");
  }

  final String currentUserID = user.uid;
  final String currentUserEmail = user.email ?? "Unknown"; // optional fallback
  final Timestamp timestamp = Timestamp.now();

  Message newMessage = Message(
    senderId: currentUserID,
    senderEmail: currentUserEmail,
    receiverId: receiverUserID,
    message: message,
    timestamp: timestamp,
  );

  List<String> chatIDs = [currentUserID, receiverUserID];
  chatIDs.sort();
  String chatRoomID = chatIDs.join('_');

  await _firestore
      .collection('chat_rooms')
      .doc(chatRoomID)
      .collection('messages')
      .add(newMessage.toMap());
}

  Stream<List<Message>> getMessages(String userID, String otherUserID) {
    List<String> chatIDs = [userID, otherUserID];
    chatIDs.sort();
    String chatRoomID = chatIDs.join('_');

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
  return Message.fromMap(doc.data() as Map<String, dynamic>);
}).toList();


    });
  }
}
