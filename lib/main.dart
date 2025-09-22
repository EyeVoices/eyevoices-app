import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EyeVoices Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  int _currentHighlight = 0;
  Timer? _timer;

  final List<String> sentences = [
    "Hallo, wie geht es dir?",
    "Ich möchte bitte Wasser.",
    "Kannst du mir helfen?",
    "Vielen Dank.",
    "Ich muss zur Toilette.",
    "Ich bin müde.",
    "Wie spät ist es?",
    "Guten Morgen alle."
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        _currentHighlight = (_currentHighlight + 1) % sentences.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('EyeVoices Test'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Counter: $_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          const Divider(),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: sentences.length,
              itemBuilder: (context, index) {
                final isHighlighted = index == _currentHighlight;
                return Container(
                  decoration: BoxDecoration(
                    color: isHighlighted ? Colors.blue[100] : Colors.grey[200],
                    border: Border.all(
                      color: isHighlighted ? Colors.blue : Colors.grey,
                      width: isHighlighted ? 3 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        sentences[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isHighlighted ? 16 : 14,
                          fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Test',
        child: const Icon(Icons.add),
      ),
    );
  }
}
