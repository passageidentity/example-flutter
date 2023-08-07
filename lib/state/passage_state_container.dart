import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:passage_flutter/passage_flutter.dart';
import 'package:passage_flutter/passage_flutter_models/passage_user.dart';

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
  late PassageFlutter _passage;

  @override
  void initState() {
    super.initState();
    _passage = PassageFlutter();
    // _checkForAuthenticatedUser();
  }

  @override
  Widget build(BuildContext context) {
    return _PassageInheritedWidget(state: this, child: widget.child);
  }

  void _checkForAuthenticatedUser() async {
    // if (kIsWeb) return; // TODO: Fix Flutter web current user bug.
    final user = await _passage.getCurrentUser();
    setState(() {
      currentUser = user;
    });
  }

  void toggleIsNewUser() {
    setState(() {
      isNewUser = !isNewUser;
    });
  }

  void register(String identifier) async {
    // print(identifier);
    try {
      await _passage.register(identifier);
      final user = await _passage.getCurrentUser();
      setState(() {
        currentUser = user;
      });
    } catch (e) {
      print(e);
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
      setState(() {
        currentUser = user;
      });
    } catch (e) {
      print(e);
    }
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
