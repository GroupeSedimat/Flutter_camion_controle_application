import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

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
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.messenger)),
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
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
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
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.person, color: Colors.white),
            ),
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 250),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMe ? Theme.of(context).primaryColor : Colors.grey[200],
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
                    fileUrl.toLowerCase().endsWith('.pdf')
                        ? FutureBuilder<String?>(
                            future: _downloadPdf(fileUrl),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const SizedBox(
                                    height: 200,
                                    child: Center(
                                        child: CircularProgressIndicator()));
                              }
                              if (snapshot.hasData) {
                                return SizedBox(
                                  height: 200,
                                  child: PDFView(
                                    filePath: snapshot.data!,
                                    enableSwipe: true,
                                    swipeHorizontal: false,
                                    autoSpacing: true,
                                    pageSnap: true,
                                    fitPolicy: FitPolicy.BOTH,
                                    onError: (error) =>
                                        print("Erreur PDF: $error"),
                                  ),
                                );
                              }
                              return GestureDetector(
                                onTap: () => _openFile(fileUrl),
                                child: Text(
                                    '📄 Fichier joint (cliquer pour ouvrir)',
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor)),
                              );
                            },
                          )
                        : GestureDetector(
                            onTap: () => _openFile(fileUrl),
                            child: Text(
                                '📄 Fichier joint (cliquer pour ouvrir)',
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor)),
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
          border: Border.all(color: Theme.of(context).primaryColor)),
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
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Theme.of(context).primaryColor)),
      child: Row(
        children: [
          Icon(Icons.attach_file, color: Theme.of(context).primaryColor),
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
              icon:
                  Icon(Icons.camera_alt, color: Theme.of(context).primaryColor),
              onPressed: _pickImage),
          IconButton(
              icon: Icon(Icons.attach_file,
                  color: Theme.of(context).primaryColor),
              onPressed: _pickFile),
          Expanded(
            child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                    hintText: 'Écrire un message...',
                    border: InputBorder.none)),
          ),
          IconButton(
              icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
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
    if (image != null) {
      setState(() => _selectedImage = File(image.path));
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() => _selectedFile = File(result.files.single.path!));
    }
  }

  void _sendMessage() async {
    if (_messageController.text.isEmpty &&
        _selectedImage == null &&
        _selectedFile == null) {
      return;
    }

    String? imageUrl;
    String? fileUrl;

    if (_selectedImage != null) {
      imageUrl = await _uploadFileToStorage(_selectedImage!, 'images');
    }
    if (_selectedFile != null) {
      fileUrl = await _uploadFileToStorage(_selectedFile!, 'files');
    }

    await _firestore.collection('messages').add({
      'text':
          _messageController.text.isNotEmpty ? _messageController.text : null,
      'sender': _auth.currentUser?.email,
      'imageUrl': imageUrl,
      'fileUrl': fileUrl,
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() {
      _messageController.clear();
      _selectedImage = null;
      _selectedFile = null;
    });
  }

  Future<String?> _uploadFileToStorage(File file, String folder) async {
    try {
      // Vérifier la taille du fichier (max 5 Mo)
      int fileSize = await file.length();
      if (fileSize > 5 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Le fichier est trop volumineux (max 5 Mo).')));
        return null;
      }

      // Utilise uniquement le nom de base du fichier pour éviter un nom trop long
      String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}';
      Reference ref = _storage.ref().child('$folder/$fileName');

      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Erreur lors de l\'upload du fichier : $e');
      return null;
    }
  }

  Future<String?> _downloadPdf(String fileUrl) async {
    try {
      var response = await http.get(Uri.parse(fileUrl));
      if (response.statusCode != 200) {
        return null;
      }
      var dir = await getApplicationDocumentsDirectory();
      File file =
          File('${dir.path}/temp_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(response.bodyBytes);
      return file.path;
    } catch (e) {
      print("Erreur lors du téléchargement du PDF: $e");
      return null;
    }
  }
}
