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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 14, top: 32, right: 14),
          child: Column(
            children: [
              const Text(
                'Enter code',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'A one-time code has been sent to\n${state.userIdentifer}\nEnter the code here to ${state.isNewUser ? 'register' : 'login'}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 400,
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Your code',
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 14.0, horizontal: 10.0),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  textCapitalization: TextCapitalization.none,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 400,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff3D53F6),
                    elevation: 0,
                  ),
                  onPressed: () {
                    state.activateOTP('${_controller.text}');
                  },
                  child: const Text('Continue'),
                ),
              ),
              TextButton(
                  onPressed: () {
                    state.resendOTP();
                  },
                  child: const Text('Resend code'))
            ],
          ),
        ),
      ),
    );
  }
}
