import 'package:flutter/material.dart';
import 'package:tourism/widgets/my_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tourism/screens/tabs_screen.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String email = '';
  late String password = '';
  bool showSpinner = false;

  bool isValidEmail(String email) {
    // Basit bir e-posta doğrulama regex'i
    RegExp emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegExp.hasMatch(email);
  }

  bool isValidPassword(String password) {
    // Şifre en az 6 karakter olmalı
    return password.length >= 6;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white), // ← Drawer ikonu beyaz
        title: Text("Giriş Yap", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 30),
                Container(
                  height: 200,
                  child: Image.asset('images/tourism.png'),
                ),
                SizedBox(height: 50),

                TextField(
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    email = value;
                  },
                  decoration: InputDecoration(
                    hintText: 'Email',
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: Colors.grey, width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: Colors.grey, width: 2.0),
                    ),
                  ),
                ),

                SizedBox(height: 10),

                TextField(
                  obscureText: true,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    password = value;
                  },
                  decoration: InputDecoration(
                    hintText: 'Şifre',
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: Colors.grey, width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: Colors.grey, width: 2.0),
                    ),
                  ),
                ),

                SizedBox(height: 10),

                // 🔐 Şifremi Unuttum Butonu
                TextButton(
                  onPressed: () async {
                    if (email.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Lütfen önce e-posta adresinizi girin")),
                      );
                      return;
                    }

                    if (!isValidEmail(email)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Geçersiz e-posta adresi")),
                      );
                      return;
                    }

                    try {
                      await _auth.sendPasswordResetEmail(email: email);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Şifre sıfırlama bağlantısı e-postanıza gönderildi")),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Hata oluştu: $e")),
                      );
                    }
                  },
                  child: Text(
                    "Şifremi Unuttum?",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),

                SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: MyButton(
                    color: Colors.blue[900]!,
                    title: 'Giriş Yap',
                    onPressed: () async {
                      if (email.isEmpty || password.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("E-posta ve şifre alanlarını doldurun")),
                        );
                        return;
                      }

                      if (!isValidEmail(email)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Geçersiz e-posta adresi")),
                        );
                        return;
                      }

                      if (!isValidPassword(password)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Şifre en az 6 karakter olmalıdır")),
                        );
                        return;
                      }

                      setState(() {
                        showSpinner = true;
                      });
                      try {
                        await _auth.signInWithEmailAndPassword(
                          email: email,
                          password: password,
                        );
                        Navigator.pushNamed(context, TabsScreen.routeName);
                      } catch (e) {
                        print(e);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Giriş başarısız: $e")),
                        );
                      } finally {
                        setState(() {
                          showSpinner = false;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
