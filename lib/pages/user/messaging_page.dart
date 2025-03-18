import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';

class MessagingPage extends StatefulWidget {
  const MessagingPage({super.key});

  @override
  _MessagingPageState createState() => _MessagingPageState();
}

class _MessagingPageState extends State<MessagingPage> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  File? _selectedFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messagerie')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('messages')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return const Center(child: CircularProgressIndicator());

                  var messages = snapshot.data!.docs;

                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      var message =
                          messages[index].data() as Map<String, dynamic>;
                      var text = message['text'];
                      var sender = message['sender'];
                      var imageUrl = message['imageUrl'];
                      var fileUrl = message['fileUrl'];
                      var timestamp = message['timestamp'] as Timestamp?;
                      var time = timestamp != null
                          ? DateFormat('HH:mm').format(timestamp.toDate())
                          : '...';
                      var isMe = _auth.currentUser?.email == sender;

                      return _buildMessageBubble(
                          text, sender, isMe, imageUrl, fileUrl, time);
                    },
                  );
                },
              ),
            ),
            if (_selectedImage != null) _buildImagePreview(),
            if (_selectedFile != null) _buildFilePreview(),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(String? text, String sender, bool isMe,
      String? imageUrl, String? fileUrl, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe)
            const CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.person, color: Colors.white),
            ),
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 250),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMe ? Colors.blueAccent : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMe)
                    Text(
                      sender,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black54),
                    ),
                  if (imageUrl != null)
                    GestureDetector(
                      onTap: () => _showFullImage(imageUrl),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(imageUrl,
                            width: 150, height: 150, fit: BoxFit.cover),
                      ),
                    ),
                  if (fileUrl != null)
                    GestureDetector(
                      onTap: () => _openFile(fileUrl),
                      child: const Text(
                          '📄 Fichier joint (cliquer pour ouvrir)',
                          style: TextStyle(color: Colors.blueAccent)),
                    ),
                  if (text != null && text.isNotEmpty)
                    Text(
                      text,
                      style: TextStyle(
                          color: isMe ? Colors.white : Colors.black87,
                          fontSize: 16),
                    ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(time,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.blueAccent)),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.file(_selectedImage!,
                width: 150, height: 150, fit: BoxFit.cover),
          ),
          IconButton(
            icon: const Icon(Icons.cancel, color: Colors.redAccent),
            onPressed: () => setState(() => _selectedImage = null),
          ),
        ],
      ),
    );
  }

  Widget _buildFilePreview() {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: Colors.blueAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.blueAccent)),
      child: Row(
        children: [
          const Icon(Icons.attach_file, color: Colors.blueAccent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(_selectedFile!.path.split('/').last,
                overflow: TextOverflow.ellipsis),
          ),
          IconButton(
            icon: const Icon(Icons.cancel, color: Colors.redAccent),
            onPressed: () => setState(() => _selectedFile = null),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
      child: Row(
        children: [
          IconButton(
              icon: const Icon(Icons.camera_alt, color: Colors.blueAccent),
              onPressed: _pickImage),
          IconButton(
              icon: const Icon(Icons.attach_file, color: Colors.blueAccent),
              onPressed: _pickFile),
          Expanded(
            child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                    hintText: 'Écrire un message...',
                    border: InputBorder.none)),
          ),
          IconButton(
              icon: const Icon(Icons.send, color: Colors.blueAccent),
              onPressed: _sendMessage),
        ],
      ),
    );
  }

  void _showFullImage(String imageUrl) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => Scaffold(
                  appBar: AppBar(),
                  body: Center(child: Image.network(imageUrl)),
                )));
  }

  Future<void> _openFile(String fileUrl) async {
    try {
      await OpenFilex.open(fileUrl);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d’ouvrir le fichier')));
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _selectedImage = File(image.path));
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null)
      setState(() => _selectedFile = File(result.files.single.path!));
  }

  void _sendMessage() async {
    await _firestore.collection('messages').add({
      'text': _messageController.text,
      'sender': _auth.currentUser?.email,
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() {
      _messageController.clear();
      _selectedImage = null;
      _selectedFile = null;
    });
  }
}
