import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Главная'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context); // This will take the user back to the previous screen
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Добро пожаловать!', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}