import 'package:flutter/material.dart';

import '/state/passage_state_container.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final _controller = TextEditingController();
  late PassageState _passageState;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _passageState = PassageStateContainer.of(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = _passageState.isNewUser ? 'Register' : 'Login';
    final switchLabel = !_passageState.isNewUser
        ? 'Don\'t have an account? Register'
        : 'Already have an account? Log in';
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 14, top: 32, right: 14),
          child: Column(
            children: [
              Text(
                label,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 400,
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'example@passage.id',
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
                    if (_passageState.isNewUser) {
                      _passageState.register(_controller.text);
                    } else {
                      _passageState.login(_controller.text);
                    }
                  },
                  child: Text(label),
                ),
              ),
              const SizedBox(height: 6.0),
              TextButton(
                onPressed: _passageState.toggleIsNewUser,
                style: TextButton.styleFrom(
                    foregroundColor: const Color(0xff3D53F6)),
                child: Text(switchLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
