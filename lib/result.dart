import 'package:flutter/material.dart';
import 'package:quine_mccluskey_calculator/main.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({super.key, required this.result});
  final Map<String, String> result;

  @override
  Widget build(BuildContext context) {
    // Add null checks and debug info
    print("Received result map: $result");

    String? primeImplicants = result["Prime Implicants"];
    String? finalExpression = result["Final Expression"];

    if (primeImplicants == null || finalExpression == null) {
      print("Warning: Null values detected in result map");
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Quine McCluskey Calculator')),
      body: Center(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'Result Page',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    "Prime Implicants: ",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 20),
                  Text(
                    primeImplicants!,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "Final Expression: ",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 20),
                  Text(
                    finalExpression!,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  RestartWidget.restartApp(context);
                },
                child: Text("Restart"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
