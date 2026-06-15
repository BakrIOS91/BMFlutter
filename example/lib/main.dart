import 'package:bm_flutter/core.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'bm_flutter Example',
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('bm_flutter Example')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Filled button ──────────────────────────────────────────
            AppCupertinoButton.filled(
              context: context,
              title: 'Submit',
              backgroundColor: Colors.indigo,
              titleStyle: const TextStyle(color: Colors.white),
              icon: Icons.check,
              iconPosition: Position.trailing,
              onPressed: () {},
            ),
            const SizedBox(height: 16),

            // ── Outlined button ────────────────────────────────────────
            AppCupertinoButton.outlined(
              context: context,
              title: 'Cancel',
              borderColor: Colors.indigo,
              titleStyle: const TextStyle(color: Colors.indigo),
              onPressed: () {},
            ),
            const SizedBox(height: 16),

            // ── Underlined button ──────────────────────────────────────
            UnderlinedButton(
              title: 'Forgot Password?',
              style: const TextStyle(color: Colors.indigo),
              onPressed: () {},
            ),
            const SizedBox(height: 32),

            // ── ErrorView ──────────────────────────────────────────────
            ErrorView(
              title: 'No Network',
              message: 'Please check your connection and try again.',
              image: Image.asset('assets/error.png', errorBuilder: (_, __, ___) =>
                  const Icon(Icons.wifi_off, size: 64, color: Colors.indigo)),
              buttonTitle: 'Retry',
              retryAction: () {},
            ),
          ],
        ),
      ),
    );
  }
}
