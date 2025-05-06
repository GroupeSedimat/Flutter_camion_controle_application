import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_application_1/pages/user/Messagerie/PrivateChatPage.dart';
import 'package:flutter_application_1/pages/user/Messagerie/UserListPage.dart';
import 'package:flutter_application_1/pages/user/Messagerie/messaging_page.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ChatListPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String formatTime(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final dt = timestamp.toDate();
    return DateFormat.Hm().format(dt);
  }

  @override
  Widget build(BuildContext context) {
    String currentUserId = _auth.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('Messagerie'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('chats')
            .where('users', arrayContains: currentUserId)
            .orderBy('lastTimestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final chats = snapshot.data!.docs;

          if (chats.isEmpty) return Center(child: Text("Aucune conversation."));

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final otherUserId = (chat['users'] as List)
                  .firstWhere((uid) => uid != currentUserId);
              final lastMessage = chat['lastMessage'] ?? '';
              final lastTimestamp = chat['lastTimestamp'];
              final lastSeenMap = chat['lastSeen'] ?? {};
              final userLastSeen = lastSeenMap[currentUserId];

              return FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('users').doc(otherUserId).get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) return SizedBox.shrink();

                  final userData =
                      userSnapshot.data!.data() as Map<String, dynamic>;
                  final username = userData['username'] ?? 'Utilisateur';

                  bool isUnread = false;
                  if (lastTimestamp != null && userLastSeen is Timestamp) {
                    isUnread =
                        lastTimestamp.toDate().isAfter(userLastSeen.toDate());
                  }

                  return ListTile(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    onTap: () {
                      _firestore.collection('chats').doc(chat.id).set({
                        'lastSeen': {
                          currentUserId: FieldValue.serverTimestamp()
                        }
                      }, SetOptions(merge: true));

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PrivateChatPage(otherUserId: otherUserId),
                        ),
                      );
                    },
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueGrey[100],
                      child: Text(
                        username.substring(0, 1).toUpperCase(),
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          username,
                          style: TextStyle(
                            fontWeight:
                                isUnread ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                        Text(
                          formatTime(lastTimestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    subtitle: Row(
                      children: [
                        Expanded(
                          child: Text(
                            lastMessage,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isUnread ? Colors.black : Colors.grey[600],
                              fontWeight: isUnread
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (isUnread)
                          Container(
                            margin: EdgeInsets.only(left: 6),
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '1',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: SpeedDial(
        backgroundColor: Colors.black,
        icon: Icons.chat,
        activeIcon: Icons.close,
        children: [
          SpeedDialChild(
            child: Icon(Icons.person_add),
            label: 'Nouvelle discussion',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => UserListPage()),
              );
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.group),
            label: 'Conversation de groupe',
            onTap: () {
              Get.to(() => MessagingPage());
            },
          ),
        ],
      ),
    );
  }
}
