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
    var label = _passageState.isNewUser ? 'Register' : 'Login';
    var switchLabel =
        '${!_passageState.isNewUser ? 'Register' : 'Login'} instead';
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(
                label,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 400,
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'example@passage.id',
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
                  if (_passageState.isNewUser) {
                    _passageState.register(_controller.text);
                  } else {
                    _passageState.login(_controller.text);
                  }
                },
                child: Text(label),
              ),
              TextButton(
                  onPressed: _passageState.toggleIsNewUser,
                  child: Text(switchLabel))
            ],
          ),
        ),
      ),
    );
  }
}
