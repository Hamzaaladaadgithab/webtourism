import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/tabs_screen.dart';
import 'userSignUpScreen.dart';
import '../utils/responsive_helper.dart';

class UserLoginScreen extends StatefulWidget {
  static const routeName = '/user-login';

  @override
  State<UserLoginScreen> createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends State<UserLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Firestore'da kullanıcı dokümanını kontrol et
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      // Eğer kullanıcı dokümanı yoksa oluştur
      if (!userDoc.exists) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'email': _emailController.text.trim(),
          'name': userCredential.user!.email!.split('@')[0],
          'phone': '',
          'role': 'user',
          'createdAt': DateTime.now(),
          'favorites': [],
        });
      }

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(TabsScreen.routeName);
    } catch (error) {
      var message = 'Bir hata oluştu!';
      if (error.toString().contains('user-not-found')) {
        message = 'Kullanıcı bulunamadı!';
      } else if (error.toString().contains('wrong-password')) {
        message = 'Yanlış şifre!';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Şifremi Unuttum',
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(context, 18),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: emailController,
          decoration: InputDecoration(
            labelText: 'E-posta',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.getFontSize(context, 16),
              vertical: ResponsiveHelper.getFontSize(context, 12),
            ),
          ),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) async {
            try {
              await FirebaseAuth.instance.sendPasswordResetEmail(
                email: emailController.text.trim(),
              );
              if (!mounted) return;
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Şifre sıfırlama bağlantısı gönderildi'),
                  backgroundColor: Colors.green,
                ),
              );
            } catch (error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Hata: ${error.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseAuth.instance.sendPasswordResetEmail(
                  email: emailController.text.trim(),
                );
                if (!mounted) return;
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Şifre sıfırlama bağlantısı gönderildi'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Hata: ${error.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Gönder'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Giriş Yap',
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(context, 20),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade900,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: EdgeInsets.all(ResponsiveHelper.getFontSize(context, 20)),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'E-posta',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: ResponsiveHelper.getFontSize(context, 16),
                              vertical: ResponsiveHelper.getFontSize(context, 12),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen e-posta adresinizi girin';
                            }
                            if (!value.contains('@')) {
                              return 'Geçerli bir e-posta adresi girin';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Şifre',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.lock),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: ResponsiveHelper.getFontSize(context, 16),
                              vertical: ResponsiveHelper.getFontSize(context, 12),
                            ),
                          ),
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen şifrenizi girin';
                            }
                            if (value.length < 6) {
                              return 'Şifre en az 6 karakter olmalıdır';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: _showForgotPasswordDialog,
                          child: Text(
                            'Şifremi Unuttum',
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getFontSize(context, 14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade900,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(
                                    'GİRİŞ YAP',
                                    style: TextStyle(
                                      fontSize: ResponsiveHelper.getFontSize(context, 18),
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed(UserSignUpScreen.routeName);
                          },
                          child: Text(
                            'Hesabınız yok mu? Kayıt olun',
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getFontSize(context, 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
} 