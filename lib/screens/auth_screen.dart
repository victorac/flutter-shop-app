import 'dart:math';

import 'package:flutter/material.dart';

enum AuthMode {
  select,
  login,
  signup,
}

class AuthScreen extends StatelessWidget {
  static const routeName = "/auth";
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final deviceSize = MediaQuery.of(context).size;
    final topPadding = MediaQuery.of(context).padding.top;
    return Scaffold(
        body: Stack(children: [
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.amber.shade300, Colors.red],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      SingleChildScrollView(
        child: SizedBox(
          width: deviceSize.width,
          height: deviceSize.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        height: 60,
                        width: 200,
                        transform: Matrix4.rotationZ(-10 * pi / 180)
                          ..translate(-5.0, 25.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: theme.colorScheme.secondary,
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 8,
                              color: Colors.black26,
                              offset: Offset(0, 2),
                            )
                          ],
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: Text(
                        'MyShop',
                        style: TextStyle(
                          color: theme.colorScheme.onSecondary,
                          fontSize: 50,
                          fontFamily: 'Anton',
                          fontWeight: FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(flex: deviceSize.width > 600 ? 2 : 1, child: AuthForm()),
            ],
          ),
        ),
      ),
    ]));
  }
}

class AuthForm extends StatefulWidget {
  const AuthForm({super.key});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  late AuthMode _authMode;

  @override
  void initState() {
    super.initState();
    _authMode = AuthMode.login;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _authMode == AuthMode.login ? LoginForm() : SignupForm(),
        ElevatedButton(
          onPressed: () => setState(() {
            _authMode =
                _authMode == AuthMode.login ? AuthMode.signup : AuthMode.login;
          }),
          child: _authMode == AuthMode.login ? Text("Sign up") : Text("Log in"),
        )
      ],
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      elevation: 20,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: deviceSize.height * 0.5,
          maxWidth: deviceSize.width * 0.75,
        ),
        padding: const EdgeInsets.all(10.0),
        child: Form(
            child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Username'),
                textInputAction: TextInputAction.next,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                textInputAction: TextInputAction.next,
              ),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Confirm password'),
                textInputAction: TextInputAction.next,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                textInputAction: TextInputAction.next,
              ),
            ],
          ),
        )),
      ),
    );
  }
}

class SignupForm extends StatefulWidget {
  const SignupForm({super.key});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
