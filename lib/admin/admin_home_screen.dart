import 'package:flutter/material.dart';
import 'add_tour_screen.dart';
import 'manage_tours_screen.dart';
import 'manage_reservations_screen.dart';
import 'manage_users_screen.dart';
import '../utils/responsive_helper.dart';

class AdminHomeScreen extends StatelessWidget {
  static const routeName = '/admin-home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Admin Paneli',
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(context, 20),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.grey.shade50,
        child: SafeArea(
          child: Padding(
            padding: ResponsiveHelper.getPadding(context),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Ekran genişliğine göre grid sütun sayısını ayarla
                int crossAxisCount = ResponsiveHelper.isDesktop(context) ? 4 : 
                                  ResponsiveHelper.isTablet(context) ? 3 : 2;
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hoş geldiniz kartı
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(ResponsiveHelper.getFontSize(context, 16)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(ResponsiveHelper.getFontSize(context, 12)),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.admin_panel_settings,
                              color: Colors.blue.shade900,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: ResponsiveHelper.getFontSize(context, 16)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hoş Geldiniz',
                                  style: TextStyle(
                                    fontSize: ResponsiveHelper.getFontSize(context, 24),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Turizm Yönetim Sistemi',
                                  style: TextStyle(
                                    fontSize: ResponsiveHelper.getFontSize(context, 16),
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: ResponsiveHelper.getFontSize(context, 24)),
                    // Admin kartları grid
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: ResponsiveHelper.getFontSize(context, 16),
                        crossAxisSpacing: ResponsiveHelper.getFontSize(context, 16),
                        childAspectRatio: 1.1,
                        children: [
                          _buildAdminCard(
                            context,
                            'Yeni Gezi Ekle',
                            Icons.add_circle_outline,
                            Colors.green,
                            () => Navigator.of(context).pushNamed(AddTourScreen.routeName),
                          ),
                          _buildAdminCard(
                            context,
                            'Gezileri Yönet',
                            Icons.travel_explore,
                            Colors.blue,
                            () => Navigator.of(context).pushNamed(ManageToursScreen.routeName),
                          ),
                          _buildAdminCard(
                            context,
                            'Rezervasyonlar',
                            Icons.calendar_today,
                            Colors.orange,
                            () => Navigator.of(context).pushNamed(ManageReservationsScreen.routeName),
                          ),
                          _buildAdminCard(
                            context,
                            'Kullanıcılar',
                            Icons.people_outline,
                            Colors.purple,
                            () => Navigator.of(context).pushNamed(ManageUsersScreen.routeName),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(ResponsiveHelper.getFontSize(context, 16)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.2),
              ],
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              double iconSize = ResponsiveHelper.getFontSize(context, 32);
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(ResponsiveHelper.getFontSize(context, 12)),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      size: iconSize,
                      color: color,
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.getFontSize(context, 16)),
                  Flexible(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getFontSize(context, 16),
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
