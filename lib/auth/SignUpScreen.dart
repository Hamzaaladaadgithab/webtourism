import 'package:flutter/material.dart';
import 'package:tourism/widgets/my_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:tourism/screens/WelcomeScreen.dart';

class SignUpScreen extends StatefulWidget {
  static const routeName = '/signup';

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late String email;
  late String password;
  bool showSpinner = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white), // ← Drawer ikonu beyaz
        title: Text("Kayıt Ol", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: LayoutBuilder(
            builder: (context, constraints) {
              double maxWidth = constraints.maxWidth > 600 ? 400 : constraints.maxWidth * 0.9;
              return SingleChildScrollView(
                child: Center(
                  child: Container(
                    width: maxWidth,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 20),
                          Container(
                            height: constraints.maxWidth > 600 ? 180 : 150,
                            child: Image.asset('images/tourism.png'),
                          ),
                          SizedBox(height: 40),
                          Container(
                            width: constraints.maxWidth > 600 ? 300 : double.infinity,
                            child: TextField(
                              keyboardType: TextInputType.emailAddress,
                              textAlign: TextAlign.center,
                              onChanged: (value) {
                                email = value;
                              },
                              decoration: InputDecoration(
                                hintText: 'Email',
                                contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(8)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(8)),
                                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(8)),
                                  borderSide: BorderSide(color: Colors.grey, width: 2.0),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Container(
                            width: constraints.maxWidth > 600 ? 300 : double.infinity,
                            child: TextField(
                              obscureText: true,
                              textAlign: TextAlign.center,
                              onChanged: (value) {
                                password = value;
                              },
                              decoration: InputDecoration(
                                hintText: 'Şifre',
                                contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(8)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(8)),
                                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(8)),
                                  borderSide: BorderSide(color: Colors.grey, width: 2.0),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Container(
                            width: constraints.maxWidth > 600 ? 300 : double.infinity,
                            child: MyButton(
                              color: Colors.blue[900]!,
                              title: 'Kayıt Ol',
                              onPressed: () async {
                                setState(() {
                                  showSpinner = true;
                                });
                                try {
                                  await _auth.createUserWithEmailAndPassword(
                                    email: email,
                                    password: password,
                                  );
                                  Navigator.pushNamed(context, WelcomeScreen.routeName);
                                } on FirebaseAuthException catch (e) {
                                  if (e.code == 'email-already-in-use') {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Bu e-posta adresi zaten kullanılıyor.")),
                                    );
                                  } else if (e.code == 'invalid-email') {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Geçersiz e-posta adresi.")),
                                    );
                                  } else if (e.code == 'weak-password') {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Şifre çok zayıf. Daha güçlü bir şifre girin.")),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Hata oluştu: ${e.message}")),
                                    );
                                  }
                                } catch (e) {
                                  print("Bilinmeyen hata: $e");
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Bilinmeyen hata: $e")),
                                  );
                                } finally {
                                  setState(() {
                                    showSpinner = false;
                                  });
                                }
                              },
                            ),
                          ),
                          SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
