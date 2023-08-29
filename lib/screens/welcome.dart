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
      body: Padding(
        padding: const EdgeInsets.only(left: 14, top: 32, right: 14),
        // padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const Text(
              'Welcome',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              state.currentUser?.email ?? state.currentUser?.phone ?? '',
            ),
            const SizedBox(height: 18),
            const Text(
              'Passkeys:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.currentUser?.webauthnDevices.length ?? 0,
              itemBuilder: (BuildContext context, int index) {
                return Text(
                  state.currentUser?.webauthnDevices[index].friendlyName ?? '',
                  textAlign: TextAlign.center,
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(height: 8.0);
              },
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: 400,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff3D53F6),
                  elevation: 0,
                ),
                onPressed: () {
                  state.addPasskey();
                },
                child: const Text('Add passkey'),
              ),
            ),
            TextButton(
                onPressed: () {
                  state.signOut();
                },
                child: const Text('Sign out'))
          ],
        ),
      ),
    );
  }
}
