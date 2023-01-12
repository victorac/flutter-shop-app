import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/screens/product_overview_screen.dart';

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
    return Scaffold(
      body: Stack(
        children: [
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
                  Flexible(
                    fit: FlexFit.tight,
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthForm(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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

  Widget _buildTextButton() {
    return TextButton(
      style: TextButton.styleFrom(foregroundColor: Colors.black),
      onPressed: () => setState(() {
        _authMode =
            _authMode == AuthMode.login ? AuthMode.signup : AuthMode.login;
      }),
      child: _authMode == AuthMode.login
          ? const Text("Sign up")
          : const Text("Log in"),
    );
  }

  Widget _buildAuthCard() {
    return _authMode == AuthMode.login ? const LoginForm() : const SignupForm();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Flexible(flex: 3, child: _buildAuthCard()),
        Flexible(flex: 1, child: _buildTextButton()),
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
  final GlobalKey<FormState> _formKey = GlobalKey();
  final GlobalKey _buttonKey = GlobalKey();
  bool _loading = false;
  bool _error = false;
  final _formFields = {
    'email': '',
    'password': '',
  };

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _loading = true;
    });
    final navigator = Navigator.of(context);
    try {
      await Provider.of<Auth>(context, listen: false).signin(
        _formFields['email'] as String,
        _formFields['password'] as String,
      );
      navigator.pushReplacementNamed(ProductOverviewScreen.routeName);
    } catch (error) {
      print(error);
      setState(() => _error = true);
    }
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Column(
      children: [
        Flexible(
          flex: 2,
          child: Card(
            elevation: 20,
            child: Focus(
              onFocusChange: (value) async {
                if (value) {
                  await Future.delayed(const Duration(milliseconds: 500));
                  RenderObject? object =
                      _buttonKey.currentContext?.findRenderObject();
                  object?.showOnScreen();
                }
              },
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: deviceSize.width * 0.75,
                ),
                padding: const EdgeInsets.all(10.0),
                child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          TextFormField(
                            decoration:
                                const InputDecoration(labelText: 'Email'),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            onSaved: (newValue) =>
                                _formFields['email'] = newValue as String,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'enter an email';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            decoration:
                                const InputDecoration(labelText: 'Password'),
                            textInputAction: TextInputAction.done,
                            obscureText: true,
                            onSaved: (newValue) =>
                                _formFields['password'] = newValue as String,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'enter your password';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    )),
              ),
            ),
          ),
        ),
        Flexible(
          child: _loading
              ? const Center(
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                    ),
                  ),
                )
              : ElevatedButton(
                  key: _buttonKey,
                  onPressed: _saveForm,
                  child: const Text('Login'),
                ),
        )
      ],
    );
  }
}

class SignupForm extends StatefulWidget {
  const SignupForm({super.key});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  late TextEditingController _passwordController;
  bool _loading = false;
  final GlobalKey _buttonKey = GlobalKey();
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _passwordController.dispose();
  }

  final _formFields = {
    'email': '',
    'password': '',
  };

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _loading = true;
    });
    final navigator = Navigator.of(context);
    try {
      await Provider.of<Auth>(context, listen: false).signup(
        _formFields['email'] as String,
        _formFields['password'] as String,
      );
      navigator.pushReplacementNamed(ProductOverviewScreen.routeName);
    } catch (error) {
      print(error);
      setState(() => _error = true);
    }
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Column(
      children: [
        Flexible(
          flex: 4,
          child: Card(
            elevation: 20,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: deviceSize.width * 0.75,
              ),
              padding: const EdgeInsets.all(10.0),
              child: Focus(
                onFocusChange: (value) async {
                  if (value) {
                    await Future.delayed(const Duration(milliseconds: 500));
                    RenderObject? object =
                        _buttonKey.currentContext?.findRenderObject();
                    object?.showOnScreen();
                  }
                },
                child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          TextFormField(
                            decoration:
                                const InputDecoration(labelText: 'Email'),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            onSaved: (newValue) =>
                                _formFields['email'] = newValue as String,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'enter an email';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            decoration:
                                const InputDecoration(labelText: 'Password'),
                            textInputAction: TextInputAction.next,
                            obscureText: true,
                            controller: _passwordController,
                            onSaved: (newValue) =>
                                _formFields['password'] = newValue as String,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'enter your password';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                                labelText: 'Confirm password'),
                            textInputAction: TextInputAction.done,
                            obscureText: true,
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  value != _passwordController.text) {
                                return 'passwords don\'t match';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    )),
              ),
            ),
          ),
        ),
        Flexible(
          child: _loading
              ? const Center(
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                    ),
                  ),
                )
              : ElevatedButton(
                  key: _buttonKey,
                  onPressed: _saveForm,
                  child: const Text('Signup'),
                ),
        )
      ],
    );
  }
}
