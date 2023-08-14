import 'package:flutter/material.dart';
import '/state/passage_state_container.dart';

class OTPWidget extends StatefulWidget {
  const OTPWidget({super.key});

  @override
  State<OTPWidget> createState() => _OTPWidgetState();
}

class _OTPWidgetState extends State<OTPWidget> {
  final _controller = TextEditingController();
  late PassageState state;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    state = PassageStateContainer.of(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Text(
            'Enter code',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            'A one-time code has been sent to ${state.userIdentifer}. Enter the code here to ${state.isNewUser ? 'register' : 'login'}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 400,
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Your code',
                ),
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                textCapitalization: TextCapitalization.none,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff3D53F6),
              elevation: 0,
            ),
            onPressed: () {
              state.activateOTP('${_controller.text}');
            },
            child: const Text('Continue'),
          ),
          TextButton(
              onPressed: () {
                state.resendOTP();
              },
              child: const Text('Resend code'))
        ],
      ),
    );
  }
}
