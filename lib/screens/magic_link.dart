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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 14, top: 32, right: 14),
          child: Column(
            children: [
              Text(
                'Check email to ${state.isNewUser ? 'register' : 'log in'}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'A one-time link has been sent to\n${state.userIdentifer}\nYou will be logged in here once you click that link.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                  onPressed: () {
                    state.resendMagicLink();
                  },
                  child: const Text('Resend link'))
            ],
          ),
        ),
      ),
    );
  }
}
