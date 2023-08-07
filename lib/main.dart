import 'package:flutter/material.dart';

import 'state/passage_state_container.dart';
import 'screens/login.dart';
import 'screens/welcome.dart';

void main() {
  runApp(const PassageStateContainer(child: PassageExampleApp()));
}

class PassageExampleApp extends StatefulWidget {
  const PassageExampleApp({super.key});

  @override
  State<PassageExampleApp> createState() => _PassageExampleAppState();
}

class _PassageExampleAppState extends State<PassageExampleApp> {
  late PassageState _passageState;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _passageState = PassageStateContainer.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Passage Example App'),
          backgroundColor: Colors.grey.shade600,
        ),
        body: (_passageState.currentUser == null
            ? const LoginWidget()
            : const WelcomeWidget()),
      ),
    );
  }
}
