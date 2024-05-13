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
              authButton(label,  _passageState, _controller, "Passkeys"),
              const SizedBox(height: 6.0),
              authButton(label,  _passageState, _controller, "One-Time Passcode"),
              const SizedBox(height: 6.0),
              authButton(label,  _passageState, _controller, "Magic Link"),
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


  Widget authButton(String label, PassageState _passageState, TextEditingController _controller, String type) {
  return SizedBox(
    width: 400,
    height: 48,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        textStyle: TextStyle(color: Colors.white), // background color// text color
        elevation: 0,
        backgroundColor:const Color(0xff3D53F6) ,
        shape: RoundedRectangleBorder( // rounded corners
          borderRadius: BorderRadius.circular(10),
        ),// inner padding
      ),
      onPressed: () async {
        FocusManager.instance.primaryFocus?.unfocus();
        if (_passageState.isNewUser) {
             _passageState.register(_controller.text, type);
        } else {
             _passageState.login(_controller.text, type);
        }
      },
      child: Text("$label with $type", style: TextStyle(color: Colors.white)),
    ),
  );
}

}
