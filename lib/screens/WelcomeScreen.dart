import 'package:flutter/material.dart';
import '../auth/AdminLoginScreen.dart';
import '../auth/userLoginScreen.dart';
import '../utils/responsive_helper.dart';

class WelcomeScreen extends StatelessWidget {
  static const routeName = '/welcome';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        elevation: 0,
        title: Text(
          'Tourism App',
          style: TextStyle(
            color: Colors.white,
            fontSize: ResponsiveHelper.getFontSize(context, 20),
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double maxWidth = ResponsiveHelper.getMaxWidth(context);
                  return Container(
                    width: maxWidth,
                    padding: ResponsiveHelper.getPadding(context),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo veya Başlık
                        Container(
                          width: ResponsiveHelper.isMobile(context) ? double.infinity : maxWidth * 0.6,
                          padding: EdgeInsets.all(ResponsiveHelper.getFontSize(context, 24)),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.shade900.withOpacity(0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Image.asset(
                                'images/icon.png',
                                height: ResponsiveHelper.getFontSize(context, 120),
                                width: ResponsiveHelper.getFontSize(context, 120),
                                fit: BoxFit.contain,
                              ),
                              SizedBox(height: ResponsiveHelper.getFontSize(context, 20)),
                              Text(
                                'TOURİSM REHBER SİSTEMİ',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: ResponsiveHelper.getFontSize(context, 24),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade900,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              SizedBox(height: ResponsiveHelper.getFontSize(context, 12)),
                              Text(
                                'Hayalinizdeki Tatili Keşfedin',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: ResponsiveHelper.getFontSize(context, 16),
                                  color: Colors.grey,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: ResponsiveHelper.getFontSize(context, 48)),
                        // Butonlar
                        Container(
                          width: ResponsiveHelper.isMobile(context) ? double.infinity : maxWidth * 0.4,
                          child: Column(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pushNamed(UserLoginScreen.routeName);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade900,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    vertical: ResponsiveHelper.getFontSize(context, 16),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 4,
                                  minimumSize: Size(double.infinity, ResponsiveHelper.getFontSize(context, 50)),
                                ),
                                child: Text(
                                  'KULLANICI GİRİŞİ',
                                  style: TextStyle(
                                    fontSize: ResponsiveHelper.getFontSize(context, 16),
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              SizedBox(height: ResponsiveHelper.getFontSize(context, 16)),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pushNamed(AdminLoginScreen.routeName);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade900,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    vertical: ResponsiveHelper.getFontSize(context, 16),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 4,
                                  minimumSize: Size(double.infinity, ResponsiveHelper.getFontSize(context, 50)),
                                ),
                                child: Text(
                                  'ADMİN GİRİŞİ',
                                  style: TextStyle(
                                    fontSize: ResponsiveHelper.getFontSize(context, 16),
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}


