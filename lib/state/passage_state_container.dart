import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:passage_flutter/passage_flutter_models/passage_error_code.dart';
import 'dart:async';
import 'package:passage_flutter/passage_flutter.dart';
import 'package:passage_flutter/passage_flutter_models/passage_app_info.dart';
import 'package:passage_flutter/passage_flutter_models/passage_error.dart';
import 'package:passage_flutter/passage_flutter_models/passage_user.dart';

enum AuthState {
  unauthenticated,
  awaitingLoginVerificationOTP,
  awaitingLoginVerificationMagicLink,
  awaitingRegisterVerificationOTP,
  awaitingRegisterVerificationMagicLink,
  authenticated,
  error
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
  Timer? timer;
  late PassageFlutter _passage;

  @override
  void initState() {
    super.initState();
    _passage = PassageFlutter('cslGQjgFp4tfQNUN5e6sGbVc');
    _checkForAuthenticatedUser();
  }

  @override
  Widget build(BuildContext context) {
    return _PassageInheritedWidget(state: this, child: widget.child);
  }

  void _checkForAuthenticatedUser() async {
    final user = await _passage.getCurrentUser();
    _setUser(user);
    if (user == null) {
      _passage.signOut();
    }
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

  void register(String identifier, String type) async {  
    try {
      switch (type) {
        case 'passkeys': 
        {
          await _passage.register(identifier);
          final user = await _passage.getCurrentUser();
          _setUser(user);
          break;
        }
        case 'magiccode':
          {
            final otpId = await _passage.newRegisterOneTimePasscode(identifier);
          setState(() {
          authFallbackId = otpId;
          authState = AuthState.awaitingRegisterVerificationOTP;
          userIdentifer = identifier;
        });
        break;
          }
        case 'magiclink':
          {
            final magicLinkId = await _passage.newLoginMagicLink(identifier);
        _setMagicLinkCheckTimer(magicLinkId);
        setState(() {
          authFallbackId = magicLinkId;
          authState = AuthState.awaitingLoginVerificationMagicLink;
          userIdentifer = identifier;
        });
        break;
          }
          
      }
      
    } catch (error) {
      if (error is PassageError &&
          error.code == PassageErrorCode.userCancelled) {
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
        case 'passkey': 
        {
          await _passage.loginWithIdentifier(identifier);
          final user = await _passage.getCurrentUser();
          if (user != null)_setUser(user);
          break;
        }
        case 'magiccode':
          {
            final otpId = await _passage.newLoginOneTimePasscode(identifier);
          setState(() {
          authFallbackId = otpId;
          authState = AuthState.awaitingLoginVerificationOTP;
          userIdentifer = identifier;
        });
        break;
          }
        case 'magiclink':
          {
            final magicLinkId = await _passage.newLoginMagicLink(identifier);
        _setMagicLinkCheckTimer(magicLinkId);
        setState(() {
          authFallbackId = magicLinkId;
          authState = AuthState.awaitingLoginVerificationMagicLink;
          userIdentifer = identifier;
        });
        break;
          }
      }
    } catch (error) {
      if (error is PassageError &&
          error.code == PassageErrorCode.userCancelled) {
      } else if (identifier.isNotEmpty) {
        debugPrint(error.toString());
        if (error is PassageError) {   
          presentAlert('Error', error.message.toString());        
        }
      }
    }
  }

  Future<void> _fallbackRegister(String identifier) async {
    try {
      final appInfo = await _passage.getAppInfo();
      if (appInfo?.authFallbackMethod == PassageAuthFallbackMethod.otp) {
        final otpId = await _passage.newRegisterOneTimePasscode(identifier);
        setState(() {
          authFallbackId = otpId;
          authState = AuthState.awaitingRegisterVerificationOTP;
          userIdentifer = identifier;
        });
      } else if (appInfo?.authFallbackMethod ==
          PassageAuthFallbackMethod.magicLink) {
        final magicLinkId = await _passage.newRegisterMagicLink(identifier);
        _setMagicLinkCheckTimer(magicLinkId);
        setState(() {
          authFallbackId = magicLinkId;
          authState = AuthState.awaitingRegisterVerificationMagicLink;
          userIdentifer = identifier;
        });
      }
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  Future<void> _fallbackLogin(String identifier) async {
    try {
      final appInfo = await _passage.getAppInfo();
      if (appInfo?.authFallbackMethod == PassageAuthFallbackMethod.otp) {
        final otpId = await _passage.newLoginOneTimePasscode(identifier);
        setState(() {
          authFallbackId = otpId;
          authState = AuthState.awaitingLoginVerificationOTP;
          userIdentifer = identifier;
        });
      } else if (appInfo?.authFallbackMethod ==
          PassageAuthFallbackMethod.magicLink) {
        final magicLinkId = await _passage.newLoginMagicLink(identifier);
        _setMagicLinkCheckTimer(magicLinkId);
        setState(() {
          authFallbackId = magicLinkId;
          authState = AuthState.awaitingLoginVerificationMagicLink;
          userIdentifer = identifier;
        });
      }
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  Future<void> activateOTP(String otp) async {
    try {
      await _passage.oneTimePasscodeActivate(otp, authFallbackId!);
      final user = await _passage.getCurrentUser();
      _setUser(user);
    } catch (error) {
      debugPrint(error.toString());
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
      presentAlert('Success', 'Code resent');
    } catch (error) {
      debugPrint(error.toString());
      presentAlert('Problem resending passcode', 'Please try again');
    }
  }

  Future<void> _checkMagicLink(String? magicLinkId) async {
    try {
      final authResult = await _passage.getMagicLinkStatus(magicLinkId!);
      if (authResult != null) {
        timer?.cancel();
        timer = null;
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
      _setMagicLinkCheckTimer(newMagicLinkId);
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
      debugPrint(error.toString());
      presentAlert('Problem adding passkey', 'Please try again.');
    }
  }

  Future<void> signOut() async {
    _setUser(null);
    await _passage.signOut();
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
