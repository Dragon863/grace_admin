import 'package:flutter/material.dart';
import 'package:grace_admin/utils/api.dart';
import 'package:grace_admin/utils/popup.dart';
import 'package:provider/provider.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  TextEditingController serviceKeyController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  int stage = 1;
  bool isValidEmail = true;
  bool isLoading = false;

  Future<void> maybeLogin() async {
    setState(() {
      isLoading = true;
    });
    final api = context.read<AuthAPI>();
    final success =
        await api.loginAsAdmin(serviceKey: serviceKeyController.text);
    if (success) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      await showErr(context, "Invalid service key");
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (stage == 1) {
      return Container(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SizedBox(
          height: 440,
          child: Stack(fit: StackFit.expand, children: [
            Column(
              children: <Widget>[
                const SizedBox(height: 25),
                const Row(
                  children: [
                    SizedBox(width: 25),
                    SelectableText(
                      "Log In (Admin)",
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    Spacer(),
                  ],
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: TextField(
                    obscureText: true,
                    obscuringCharacter: '*',
                    enableSuggestions: false,
                    autocorrect: false,
                    controller: serviceKeyController,
                    decoration: const InputDecoration(
                      suffixIcon: Icon(Icons.lock, color: Colors.black54),
                      fillColor: Color.fromARGB(255, 238, 238, 238),
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        borderSide: BorderSide(
                            color: Color.fromARGB(255, 238, 238, 238),
                            width: 8.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        borderSide: BorderSide(
                            color: Color.fromARGB(255, 238, 238, 238),
                            width: 8.0),
                      ),
                      hoverColor: Color.fromARGB(255, 238, 238, 238),
                      labelText: 'Service Key',
                    ),
                    onSubmitted: (value) async {
                      await maybeLogin();
                    },
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    const Spacer(),
                    FloatingActionButton.extended(
                      onPressed: maybeLogin,
                      backgroundColor: const Color.fromARGB(255, 0, 88, 141),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(22)),
                      ),
                      label: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Continue",
                              style: TextStyle(color: Colors.white)),
                          SizedBox(width: 10),
                          isLoading
                              ? Container(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                  height: 18,
                                  width: 18,
                                )
                              : Icon(Icons.keyboard_arrow_right,
                                  color: Colors.white, size: 18),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                //const SizedBox(height: 48),
                const Spacer()
              ],
            )
          ]),
        ),
      );
    } else {
      return const CircularProgressIndicator();
    }
  }
}
