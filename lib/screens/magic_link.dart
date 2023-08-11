import 'package:flutter/material.dart';

import '/state/passage_state_container.dart';

class MagicLinkWidget extends StatefulWidget {
  const MagicLinkWidget({super.key});

  @override
  State<MagicLinkWidget> createState() => _MagicLinkWidgetState();
}

class _MagicLinkWidgetState extends State<MagicLinkWidget> {
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
            'Check email to ${state.isNewUser ? 'Register' : 'Login'}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            'A one-time link has been sent to\n${state.userIdentifer}\nYou will be logged in here once you click that link.',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
          ),
          TextButton(
              onPressed: () {
                state.resendMagicLink();
              },
              child: const Text('Resend link'))
        ],
      ),
    );
  }
}
