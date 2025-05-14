import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class PrivateChatPage extends StatefulWidget {
  final String otherUserId;

  const PrivateChatPage({required this.otherUserId});

  @override
  _PrivateChatPageState createState() => _PrivateChatPageState();
}

class _PrivateChatPageState extends State<PrivateChatPage> {
  final _controller = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  late String chatId;
  late String currentUserId;
  late String otherUserId;
  String otherUsername = '...';

  @override
  void initState() {
    super.initState();
    currentUserId = _auth.currentUser!.uid;
    otherUserId = widget.otherUserId;
    chatId = getChatId(currentUserId, otherUserId);
    _loadOtherUsername();
    Future.delayed(Duration.zero, () {
      _firestore.collection('chats').doc(chatId).set({
        'lastSeen': {
          currentUserId: FieldValue.serverTimestamp(),
        }
      }, SetOptions(merge: true));
    });
  }

  void _loadOtherUsername() async {
    final doc = await _firestore.collection('users').doc(otherUserId).get();
    if (doc.exists) {
      setState(() {
        otherUsername = doc['username'] ?? doc['name'] ?? 'Utilisateur';
      });
    }
  }

  String getChatId(String uid1, String uid2) {
    final uids = [uid1, uid2]..sort();
    return '${uids[0]}_${uids[1]}';
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final timestamp = FieldValue.serverTimestamp();

    await _firestore.collection('chats').doc(chatId).set({
      'users': [currentUserId, otherUserId],
      'lastMessage': text,
      'lastTimestamp': timestamp,
      'lastSeen': {
        currentUserId: timestamp,
      }
    }, SetOptions(merge: true));
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'sender': currentUserId,
      'text': text,
      'timestamp': timestamp,
    });

    _controller.clear();
  }

  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final dt = timestamp.toDate();
    return DateFormat.Hm().format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(otherUsername),
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final reversedIndex = messages.length - 1 - index;
                    final msg =
                        messages[reversedIndex].data() as Map<String, dynamic>;
                    final isMe = msg['sender'] == currentUserId;
                    final time = formatTimestamp(msg['timestamp']);

                    return AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 4),
                            padding: EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.75,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isMe ? Color(0xFF007AFF) : Color(0xFFE5E5EA),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(18),
                                topRight: Radius.circular(18),
                                bottomLeft: Radius.circular(isMe ? 18 : 0),
                                bottomRight: Radius.circular(isMe ? 0 : 18),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 2,
                                  offset: Offset(1, 1),
                                )
                              ],
                            ),
                            child: Text(
                              msg['text'],
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                EdgeInsets.only(bottom: 4, left: 8, right: 8),
                            child: Text(
                              time,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'ecrire un message',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF007AFF),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
