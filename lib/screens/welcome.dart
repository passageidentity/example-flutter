import 'package:flutter/material.dart';
import '/state/passage_state_container.dart';

class WelcomeWidget extends StatefulWidget {
  const WelcomeWidget({super.key});

  @override
  State<WelcomeWidget> createState() => _WelcomeWidgetState();
}

class _WelcomeWidgetState extends State<WelcomeWidget> {
  late PassageState state;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    state = PassageStateContainer.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text(
            'Welcome ${state.currentUser?.email ?? 'no email'}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff3D53F6),
              elevation: 0,
            ),
            onPressed: () {
              state.addPasskey();
            },
            child: const Text('Add passkey'),
          ),
          TextButton(
              onPressed: () {
                state.signOut();
              },
              child: const Text('Sign out'))
        ],
      ),
    );
  }
}
