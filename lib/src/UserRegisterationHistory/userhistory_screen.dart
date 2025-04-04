import 'package:finalfyp/src/UserRegisterationHistory/userhistory_services.dart';
import 'package:flutter/material.dart';


class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF010713),
        elevation: 0,
        title: const Text(
          'User History',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 25,
            color: Color(0xFFB0BEC5),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFB0BEC5)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF010713),
                Color(0xFF0D2962),
              ],
            ),
          ),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            // Fetching the user's history
            future: userHistory_services().fetchUserHistory(context),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text("Error fetching history"));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No history found"));
              }

              final userHistory = snapshot.data!;

              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: userHistory.length,
                itemBuilder: (context, index) {
                  final historyItem = userHistory[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.7),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: const Offset(0, 4),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(9.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        tileColor: Colors.transparent,
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text(
                              historyItem['result'],
                              style: const TextStyle(
                                fontFamily: 'PoppinsMedium',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFB0BEC5),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Date: ${historyItem['date']}',
                              style: const TextStyle(
                                fontFamily: 'PoppinsRegular',
                                color: Color(0xFFB0BEC5),
                                fontSize: 17,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 15),
                              Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: const Color(0xFFB0BEC5),
                                ),
                                child: historyItem['imageUrl'].isEmpty
                                    ? const Center(
                                  child: Text(
                                    'No Image Available',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                    ),
                                  ),
                                )
                                    : ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    historyItem['imageUrl'],
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(
                                        child: Text(
                                          'Image Load Error',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
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
