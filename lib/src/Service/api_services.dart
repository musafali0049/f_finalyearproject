import 'dart:convert';
import 'package:finalfyp/src/Service/result_model.dart';
import 'package:http/http.dart' as http;

class ResultApiService {
  final String apiUrl = 'https://my-project-api-wl59.onrender.com/predict';

  Future<ResultModel> fetchResult(String imageUrl) async {
    var response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"image_url": imageUrl}),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      String prediction = data['prediction'].toString();
      String resultText;
      String status;

      if (prediction == "BAC_PNEUMONIA") {
        resultText = "Bacterial Pneumonia";
        status = "Positive";
      } else if (prediction == "VIR_PNEUMONIA") {
        resultText = "Viral Pneumonia";
        status = "Positive";
      } else {
        resultText = "Normal";
        status = "Negative";
      }

      return ResultModel(
        result: resultText,
        status: status,
        imageUrl: imageUrl,
        timestamp: DateTime.now(),
      );
    } else {
      throw Exception("Error: ${response.statusCode}\n${response.body}");
    }
  }
}