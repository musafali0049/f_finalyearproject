import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finalfyp/src/Service/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  DateTime? userCreatedAt;

  @override
  void initState() {
    super.initState();
    _fetchUserCreationTime();
  }

  Future<void> _fetchUserCreationTime() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      if (userDoc.exists) {
        final userModel =
        UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
        setState(() {
          userCreatedAt = userModel.createdAt;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    // Base notifications query sorted by descending timestamp.
    Query notificationsQuery = FirebaseFirestore.instance
        .collection('broadcast_notifications')
        .orderBy('timestamp', descending: true);

    // If we have the user's creation time, filter notifications that are after it.
    if (userCreatedAt != null) {
      notificationsQuery = notificationsQuery.where(
          'timestamp',
          isGreaterThan: Timestamp.fromDate(userCreatedAt!));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 25,
            color: Color(0xFFB0BEC5),
          ),
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
            stream: notificationsQuery.snapshots(),
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
                      fontSize: 18,
                    ),
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
                      // Mark the notification as read if not already.
                      if (currentUser != null && !isRead) {
                        await doc.reference.update({
                          'readBy': FieldValue.arrayUnion([currentUser.uid])
                        });
                      }
                      // Optionally navigate to a detailed view.
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
