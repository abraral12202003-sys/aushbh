import 'package:flutter/material.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'عُشبة - تحديد الأعشاب',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF4CAF50)),
      ),
      home: Scaffold(
        appBar: AppBar(title: Text("Hello")),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildButton(),
                buildButton(),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildButton(),
                buildButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildButton() {
  return Container(
    height: 100,
    width: 100,
    margin: EdgeInsets.all(10),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.black, width: 4),
    ),
  );
}
