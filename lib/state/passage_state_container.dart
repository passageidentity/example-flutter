import 'package:flutter/material.dart';
import 'package:passage_flutter/passage_flutter_models/passage_error_code.dart';
import 'dart:async';
import 'package:passage_flutter/passage_flutter.dart';
import 'package:passage_flutter/passage_flutter_models/passage_error.dart';
import 'package:passage_flutter/passage_flutter_models/passage_user.dart';

enum AuthState {
  unauthenticated,
  awaitingLoginVerificationOTP,
  awaitingLoginVerificationMagicLink,
  awaitingRegisterVerificationOTP,
  awaitingRegisterVerificationMagicLink,
  authenticated
}

class PassageStateContainer extends StatefulWidget {
  final Widget child;

  const PassageStateContainer({Key? key, required this.child})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => PassageState();

  static PassageState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_PassageInheritedWidget>()!
        .state;
  }
}

class PassageState extends State<PassageStateContainer> {
  bool isNewUser = false;
  CurrentUser? currentUser;
  String? userIdentifer;
  String? authFallbackId;
  AuthState authState = AuthState.unauthenticated;
  Timer? timer;
  late PassageFlutter _passage;

  @override
  void initState() {
    super.initState();
    _passage = PassageFlutter('YOUR_APP_ID');
    _checkForAuthenticatedUser();
  }

  @override
  Widget build(BuildContext context) {
    return _PassageInheritedWidget(state: this, child: widget.child);
  }

  void _checkForAuthenticatedUser() async {
    try {
      final user = await _passage.currentUser.userInfo();
      _setUser(user);
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  void toggleIsNewUser() {
    setState(() {
      isNewUser = !isNewUser;
    });
  }

  void _setUser(CurrentUser? user) {
    setState(() {
      currentUser = user;
      authState =
          user == null ? AuthState.unauthenticated : AuthState.authenticated;
    });
  }

  void register(String identifier, String type) async {  
    try {
      switch (type) {
        case 'Passkeys': 
        {
            try {
            await _passage.passkey.register(identifier);
            final user = await _passage.currentUser.userInfo();
            _setUser(user);
          } catch (error) {
            debugPrint(error.toString());
          }
          break;
        }
        case 'One-Time Passcode':
          {
          final otp = await _passage.oneTimePasscode.register(identifier);
          setState(() {
          authFallbackId = otp.id;
          authState = AuthState.awaitingRegisterVerificationOTP;
          userIdentifer = identifier;
        });
        break;
          }
        case 'Magic Link':
          {
          final magicLink = await _passage.magliclink.register(identifier);
          _setMagicLinkCheckTimer(magicLink.id);
          setState(() {
          authFallbackId = magicLink.id;
          authState = AuthState.awaitingRegisterVerificationMagicLink;
          userIdentifer = identifier;
        });
        break;
          }
          
      }
      
    } catch (error) {
      if (error is PassageError &&
          error.code == PassageErrorCode.userCancelled) {
            // User cancelled passkey prompt, do nothing.
      } else if (identifier.isNotEmpty) {
        debugPrint(error.toString());
        if (error is PassageError) {   
          presentAlert('Error', error.message.toString());     
        }
      }
    }
  }

  void login(String identifier, String type) async {
    try {
      switch (type) {
        case 'Passkeys': 
        {
          try {
            await _passage.passkey.login(identifier);
            final user = await _passage.currentUser.userInfo();
            _setUser(user);
          } catch (error) {
            debugPrint(error.toString());
          }
          break;
        }
        case 'One-Time Passcode':
          {
          final otp = await _passage.oneTimePasscode.login(identifier);
          setState(() {
          authFallbackId = otp.id;
          authState = AuthState.awaitingLoginVerificationOTP;
          userIdentifer = identifier;
        });
        break;
          }
        case 'Magic Link':
          {
          final magicLink = await _passage.magliclink.login(identifier);
          _setMagicLinkCheckTimer(magicLink.id);
          setState(() {
          authFallbackId = magicLink.id;
          authState = AuthState.awaitingLoginVerificationMagicLink;
          userIdentifer = identifier;
        });
        break;
          }
      }
    } catch (error) {
      if (error is PassageError &&
          error.code == PassageErrorCode.userCancelled) {
            // User cancelled passkey prompt, do nothing.
      } else if (identifier.isNotEmpty) {
        debugPrint(error.toString());
        if (error is PassageError) {   
          presentAlert('Error', error.message.toString());        
        }
      }
    }
  }

  Future<void> activateOTP(String otp) async {
    try {
      await _passage.oneTimePasscode.activate(otp, authFallbackId!);
      final user = await _passage.currentUser.userInfo();
      _setUser(user);
    } catch (error) {
      debugPrint(error.toString());
      presentAlert('Problem with passcode', 'Please try again');
    }
  }

  Future<void> resendOTP() async {
    final isNewUser = authState == AuthState.awaitingRegisterVerificationOTP;
    try {
      final otp = isNewUser
          ? await _passage.oneTimePasscode.register(userIdentifer!)
          : await _passage.oneTimePasscode.login(userIdentifer!);
      setState(() {
        authFallbackId = otp.id;
      });
      presentAlert('Success', 'Code resent');
    } catch (error) {
      debugPrint(error.toString());
      presentAlert('Problem resending passcode', 'Please try again');
    }
  }

  Future<void> _checkMagicLink(String? magicLinkId) async {
    try {
      final authResult = await _passage.magliclink.status(magicLinkId!);
        timer?.cancel();
        timer = null;
      final user = await _passage.currentUser.userInfo();
      _setUser(user);
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  Future<void> resendMagicLink() async {
    final isNewUser =
        authState == AuthState.awaitingRegisterVerificationMagicLink;
    try {
      final magicLink = isNewUser
          ? await _passage.magliclink.register(userIdentifer!)
          : await _passage.magliclink.login(userIdentifer!);
      _setMagicLinkCheckTimer(magicLink.id);
      setState(() {
        authFallbackId = magicLink.id;
      });
      presentAlert('Success', 'Magic link resent');
    } catch (error) {
      presentAlert('Problem resending magic link', 'Please try again');
    }
  }

  Future<void> handleDeepMagicLink(String magicLink) async {
    try {
      await _passage.magliclink.activate(magicLink);
      final user = await _passage.currentUser.userInfo();
      _setUser(user);
    } catch (error) {
      presentAlert('Invalid magic link', 'Magic link is no longer active.');
    }
  }

  Future<void> addPasskey() async {
    try {
      await _passage.currentUser.addPasskey();
    } catch (error) {
      debugPrint(error.toString());
      presentAlert('Problem adding passkey', 'Please try again.');
    }
  }

  Future<void> signOut() async {
    _setUser(null);
    await _passage.currentUser.logout();
  }

  void _setMagicLinkCheckTimer(String magicLinkId) {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      _checkMagicLink(magicLinkId);
    });
  }

  void presentAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('Okay'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }
}

class _PassageInheritedWidget extends InheritedWidget {
  final PassageState state;

  const _PassageInheritedWidget({
    Key? key,
    required this.state,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_PassageInheritedWidget oldWidget) => true;
}
