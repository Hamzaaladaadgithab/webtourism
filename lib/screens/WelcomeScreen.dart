import 'package:flutter/material.dart';
import '../widgets/my_button.dart';
import '../auth/LoginScreen.dart';
import '../auth/SignUpScreen.dart'; 

class WelcomeScreen extends StatefulWidget {
  static const routeName = '/welcome'; // route için

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white), // ← Drawer ikonu beyaz
        title: Text("Tourism Rehber Sistemi",
        style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      backgroundColor: Colors.white,
      body:Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                height: 200,
                child: Image.asset('images/tourism.png'),
              ),
          Text('Tourism Uygulaması',
          style: TextStyle(
            fontSize:30,
            fontWeight: FontWeight.w900,
            color: Color(0xff2e386b),
          ),
          ),
          ],
          ),
          SizedBox(height: 30),

           MyButton(color: Color(0xff2e386b),
            title: 'Giriş Yap',
            onPressed: (){
              Navigator.pushNamed(context, LoginScreen.routeName);
            },),

           MyButton(color: Color(0xff2e386b), 
           title: 'Kayıt Ol',
            onPressed: (){
              Navigator.pushNamed(context, SignUpScreen.routeName);
            },
            ),
        ],
      ),
      ),
    );
  }
}


