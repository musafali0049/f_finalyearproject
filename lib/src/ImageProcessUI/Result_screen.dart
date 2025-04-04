
import 'package:finalfyp/src/Service/api_services.dart';
import 'package:finalfyp/src/Service/result_model.dart';
import 'package:finalfyp/src/WelcomeHome/home_screen.dart';
import 'package:finalfyp/src/Widgets/CustomButtons.dart';
import 'package:flutter/material.dart';

import 'result_Services.dart';


class ResultScreen extends StatefulWidget {
  final String imageUrl;
  final String userId;

  const ResultScreen({Key? key, required this.imageUrl, required this.userId})
      : super(key: key);

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late ResultModel resultModel;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchResultsFromAPI();
  }

  Future<void> _fetchResultsFromAPI() async {
    try {
      // Call the separated API service to fetch results.
      ResultModel res = await ResultApiService().fetchResult(widget.imageUrl);
      setState(() {
        resultModel = res;
        isLoading = false;
      });

      // Save the result using the ResultService.
      await ResultService().saveResult(
        userId: widget.userId,
        imageUrl: widget.imageUrl,
        displayResult: resultModel.result,
        status: resultModel.status,
      );
    } catch (e) {
      setState(() {
        // In case of an error, update resultModel accordingly.
        resultModel = ResultModel(
          result: "Error: Failed to fetch results.",
          status: "",
          imageUrl: widget.imageUrl,
          timestamp: DateTime.now(),
        );
        isLoading = false;
      });
    }
  }

  void _generateReport() {
    // Use ReportService to handle report generation.
    ResultService().generateReport(
      context: context,
      userId: widget.userId,
      imageUrl: widget.imageUrl,
      status: resultModel.status,
      result: resultModel.result,
      timestamp: resultModel.timestamp,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF010713),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFB0BEC5)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('Asset/images/welcome.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: isLoading
              ? const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFB0BEC5),
            ),
          )
              : Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50),

                const SizedBox(
                  width: 300,
                  height: 80,
                  child: Center(
                    child: Text(
                      'Result',
                      style: TextStyle(
                        color: Color(0xFFB0BEC5),
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 350),
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB0BEC5),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15.0),
                          child: Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                widget.imageUrl,
                                width: 180,
                                height: 180,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          'Result: ${resultModel.result}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontFamily: 'Poppinsregular',
                          ),
                        ),
                        Text(
                          'Status: ${resultModel.status}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontFamily: 'Poppinsregular',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 8.0),
                      child: CustomElevatedButton(
                        width: 200,
                        onPressed: _generateReport,
                        label: 'Generate Report',
                        isIconButton: false,
                        textStyle: const TextStyle(
                          color: Color(0xFFB0BEC5),
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 8.0),
                      child: CustomElevatedButton(
                        width: 100,
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomeScreen(
                                fromLogin: widget.userId != "guest",
                              ),
                            ),
                                (Route<dynamic> route) => false,
                          );
                        },
                        label: 'Done',
                        isIconButton: false,
                        textStyle: const TextStyle(
                          color: Color(0xFFB0BEC5),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
