import 'package:flutter/material.dart';

import 'screens/login.dart';
import 'screens/magic_link.dart';
import 'screens/one_time_passcode.dart';
import 'screens/welcome.dart';
import 'state/passage_state_container.dart';

void main() {
  runApp(const MaterialApp(
      home: PassageStateContainer(child: PassageExampleApp())));
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example App'),
        backgroundColor: const Color(0xff3D53F6),
      ),
      body: () {
        switch (_passageState.authState) {
          case AuthState.unauthenticated:
            return const LoginWidget();
          case AuthState.awaitingLoginVerificationOTP:
          case AuthState.awaitingRegisterVerificationOTP:
            return const OTPWidget();
          case AuthState.awaitingLoginVerificationMagicLink:
          case AuthState.awaitingRegisterVerificationMagicLink:
            return const MagicLinkWidget();
          case AuthState.authenticated:
            return const WelcomeWidget();
          default:
            return const LoginWidget();
        }
      }(),
    );
  }
}
