import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/models/http_exception.dart';
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
                    child: AuthArea(),
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

class AuthArea extends StatefulWidget {
  const AuthArea({super.key});

  @override
  State<AuthArea> createState() => _AuthAreaState();
}

class _AuthAreaState extends State<AuthArea> {
  AuthMode _authMode = AuthMode.login;

  Widget _buildSwitchAuthModeTextButton() {
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Flexible(flex: 3, child: AuthForm(_authMode)),
        Flexible(flex: 1, child: _buildSwitchAuthModeTextButton()),
      ],
    );
  }
}

class AuthForm extends StatefulWidget {
  const AuthForm(this.authMode, {super.key});

  final AuthMode authMode;

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final GlobalKey _buttonKey = GlobalKey();
  bool _loading = false;
  final Map<String, String> _formFields = {
    'email': '',
    'password': '',
  };
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _showErrorDialog(errorMessage) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Error"),
            content: Text(errorMessage),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Okay"),
              ),
            ],
          );
        });
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _loading = true;
    });
    try {
      if (widget.authMode == AuthMode.login) {
        await Provider.of<Auth>(context, listen: false).signin(
          _formFields['email'] as String,
          _formFields['password'] as String,
        );
      } else {
        await Provider.of<Auth>(context, listen: false).signup(
          _formFields['email'] as String,
          _formFields['password'] as String,
        );
      }
    } on HttpException catch (error) {
      String errorMessage = error.toString();
      if (errorMessage.contains("EMAIL_EXISTS")) {
        errorMessage = 'This email address is already in use.';
      } else if (errorMessage.contains("INVALID_EMAIL")) {
        errorMessage = 'This is not a valid email address.';
      } else if (errorMessage.contains("WEAK_PASSWORD")) {
        errorMessage = 'This password is too weak.';
      } else if (errorMessage.contains("EMAIL_NOT_FOUND") ||
          errorMessage.contains("INVALID_PASSWORD")) {
        errorMessage = 'Email or password is incorrect';
      }
      _showErrorDialog(errorMessage);
    } catch (error) {
      const errorMessage =
          'Could not authenticate user. Please try again later.';
      _showErrorDialog(errorMessage);
    }
    setState(() {
      _loading = false;
    });
  }

  Widget _buildEmailField() {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Email'),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      onSaved: (newValue) => _formFields['email'] = newValue as String,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'enter an email';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Password'),
      textInputAction: widget.authMode == AuthMode.login
          ? TextInputAction.done
          : TextInputAction.next,
      obscureText: true,
      controller: _passwordController,
      onSaved: (newValue) => _formFields['password'] = newValue as String,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'enter your password';
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Confirm password'),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Column(
      children: [
        Flexible(
          flex: widget.authMode == AuthMode.login ? 3 : 4,
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
                          _buildEmailField(),
                          _buildPasswordField(),
                          if (widget.authMode == AuthMode.signup)
                            _buildConfirmPasswordField(),
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
                  child: Text(
                      widget.authMode == AuthMode.login ? 'Login' : 'Sign Up'),
                ),
        )
      ],
    );
  }
}
