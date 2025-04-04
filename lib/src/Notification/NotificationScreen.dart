import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // For logged-in users, we query the broadcast notifications.
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final notificationsRef = FirebaseFirestore.instance
        .collection('broadcast_notifications')
        .orderBy('timestamp', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
              fontFamily: 'Poppins', fontSize: 25, color: Color(0xFFB0BEC5)),
        ),
        backgroundColor: const Color(0xFF010713),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFB0BEC5)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF010713), Color(0xFF0D2962)],
          ),
        ),
        child: SafeArea(
          child: StreamBuilder<QuerySnapshot>(
            stream: notificationsRef.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    'No notifications received yet.',
                    style: TextStyle(
                        color: Color(0xFFB0BEC5),
                        fontFamily: 'PoppinsRegular',
                        fontSize: 18),
                  ),
                );
              }
              final docs = snapshot.data!.docs;
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final title = data['title'] ?? 'No Title';
                  final body = data['body'] ?? 'No Message';
                  // For broadcast notifications, check if currentUser has read it.
                  bool isRead = true;
                  if (currentUser != null) {
                    final List<dynamic> readBy = data['readBy'] ?? [];
                    isRead = readBy.contains(currentUser.uid);
                  }
                  final timestamp = data['timestamp'];
                  DateTime notificationTime;
                  if (timestamp != null && timestamp is Timestamp) {
                    notificationTime = timestamp.toDate();
                  } else {
                    notificationTime = DateTime.now();
                  }
                  final relativeTime = timeago.format(notificationTime);

                  return InkWell(
                    onTap: () async {
                      // Mark this broadcast notification as read if not already.
                      if (currentUser != null && !isRead) {
                        await doc.reference.update({
                          'readBy': FieldValue.arrayUnion([currentUser.uid])
                        });
                      }
                      // You can add navigation to a detailed view if needed.
                    },
                    child: Card(
                      color: isRead
                          ? Colors.white.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: const BorderSide(color: Colors.white70),
                      ),
                      margin: const EdgeInsets.only(bottom: 15),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                            isRead ? FontWeight.normal : FontWeight.bold,
                            fontFamily: 'PoppinsRegular',
                            color: const Color(0xFFB0BEC5),
                          ),
                        ),
                        subtitle: Text(
                          body,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFFB0BEC5),
                            fontFamily: 'PoppinsRegular',
                          ),
                        ),
                        trailing: Text(
                          relativeTime,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontFamily: 'PoppinsRegular',
                          ),
                        ),
                        leading: isRead
                            ? null
                            : Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
