import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:passage_flutter/passage_flutter.dart';
import 'package:passage_flutter/passage_flutter_models/passage_user.dart';

enum AuthState {
  unauthenticated,
  awaitingLoginVerificationOTP,
  awaitingLoginVerificationMagicLink,
  awaitingRegisterVerificationOTP,
  awaitingRegisterVerificationMagicLink,
  authenticated,
}

// TODO: Move this into SDK
enum AllowedFallbackAuth {
  otp,
  magic_link,
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
  PassageUser? currentUser;
  String? userIdentifer;
  String? authFallbackId;
  AuthState authState = AuthState.unauthenticated;
  late PassageFlutter _passage;

  @override
  void initState() {
    super.initState();
    _passage = PassageFlutter();
    _checkForAuthenticatedUser();
  }

  @override
  Widget build(BuildContext context) {
    return _PassageInheritedWidget(state: this, child: widget.child);
  }

  void _checkForAuthenticatedUser() async {
    // if (kIsWeb) return; // TODO: Fix Flutter web current user bug.
    final user = await _passage.getCurrentUser();
    _setUser(user);
  }

  void toggleIsNewUser() {
    setState(() {
      isNewUser = !isNewUser;
    });
  }

  void _setUser(PassageUser? user) {
    setState(() {
      currentUser = user;
      authState =
          user == null ? AuthState.unauthenticated : AuthState.authenticated;
    });
  }

  void register(String identifier) async {
    try {
      await _passage.register(identifier);
      final user = await _passage.getCurrentUser();
      _setUser(user);
    } catch (e) {
      print(e);
      if (identifier.isNotEmpty) {
        await _fallbackRegister(identifier);
      }
    }
  }

  void login(String identifier) async {
    // print(identifier);
    try {
      if (kIsWeb) {
        await _passage.loginWithIdentifier(identifier);
      } else {
        await _passage.login();
      }

      final user = await _passage.getCurrentUser();
      _setUser(user);
    } catch (e) {
      print(e);
      if (identifier.isNotEmpty) {
        await _fallbackLogin(identifier);
      }
    }
  }

  Future<void> _fallbackRegister(String identifier) async {
    try {
      final appInfo = await _passage.getAppInfo();
      if (appInfo?.authFallbackMethod == AllowedFallbackAuth.otp.name) {
        final otpId = await _passage.newRegisterOneTimePasscode(identifier);
        setState(() {
          authFallbackId = otpId;
          authState = AuthState.awaitingRegisterVerificationOTP;
          userIdentifer = identifier;
        });
      } else if (appInfo?.authFallbackMethod ==
          AllowedFallbackAuth.magic_link.name) {
        final magicLinkId = await _passage.newRegisterMagicLink(identifier);
        setState(() {
          authFallbackId = magicLinkId;
          authState = AuthState.awaitingRegisterVerificationMagicLink;
          userIdentifer = identifier;
        });
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> _fallbackLogin(String identifier) async {
    try {
      final appInfo = await _passage.getAppInfo();
      if (appInfo?.authFallbackMethod == AllowedFallbackAuth.otp.name) {
        final otpId = await _passage.newLoginOneTimePasscode(identifier);
        setState(() {
          authFallbackId = otpId;
          authState = AuthState.awaitingLoginVerificationOTP;
          userIdentifer = identifier;
        });
      } else if (appInfo?.authFallbackMethod ==
          AllowedFallbackAuth.magic_link.name) {
        final magicLinkId = await _passage.newLoginMagicLink(identifier);
        setState(() {
          authFallbackId = magicLinkId;
          authState = AuthState.awaitingLoginVerificationMagicLink;
          userIdentifer = identifier;
        });
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> activateOTP(String otp) async {
    try {
      await _passage.oneTimePasscodeActivate(otp, authFallbackId!);
      final user = await _passage.getCurrentUser();
      _setUser(user);
    } catch (error) {
      print(error);
      presentAlert('Problem with passcode', 'Please try again');
    }
  }

  Future<void> resendOTP() async {
    final isNewUser = authState == AuthState.awaitingRegisterVerificationOTP;
    try {
      final newOtpId = isNewUser
          ? await _passage.newRegisterOneTimePasscode(userIdentifer!)
          : await _passage.newLoginOneTimePasscode(userIdentifer!);
      setState(() {
        authFallbackId = newOtpId;
      });
    } catch (error) {
      print(error);
      presentAlert('Problem resending passcode', 'Please try again');
    }
  }

  Future<void> checkMagicLink(String? magicLinkId) async {
    try {
      final authResult = await _passage.getMagicLinkStatus(magicLinkId!);
      if (authResult != null) {
        final user = await _passage.getCurrentUser();
        _setUser(user);
      }
    } catch (error) {
      // Magic link not activated yet, do nothing.
    }
  }

  Future<void> resendMagicLink() async {
    final isNewUser =
        authState == AuthState.awaitingRegisterVerificationMagicLink;
    try {
      final newMagicLinkId = isNewUser
          ? await _passage.newRegisterMagicLink(userIdentifer!)
          : await _passage.newLoginMagicLink(userIdentifer!);
      setState(() {
        authFallbackId = newMagicLinkId;
      });
      presentAlert('Success', 'Magic link resent');
    } catch (error) {
      presentAlert('Problem resending magic link', 'Please try again');
    }
  }

  Future<void> handleDeepMagicLink(String magicLink) async {
    try {
      await _passage.magicLinkActivate(magicLink);
      final user = await _passage.getCurrentUser();
      _setUser(user);
    } catch (error) {
      presentAlert('Invalid magic link', 'Magic link is no longer active.');
    }
  }

  Future<void> addPasskey() async {
    try {
      await _passage.addPasskey();
      final user = await _passage.getCurrentUser();
      _setUser(user);
    } catch (error) {
      presentAlert('Problem adding passkey', 'Please try again.');
    }
  }

  Future<void> signOut() async {
    _setUser(null);
    await _passage.signOut();
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
