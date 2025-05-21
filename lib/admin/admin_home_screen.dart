import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';
import 'add_tour_screen.dart';
import 'manage_reservations_screen.dart';
import 'notifications_screen.dart';
import 'statistics_screen.dart';
import 'manage_users_screen.dart';
import 'manage_tours_screen.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class AdminMenuItem {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget screen;

  const AdminMenuItem({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.screen,
  });
}

class AdminHomeScreen extends StatefulWidget {
  static const routeName = '/admin-home';

  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final List<AdminMenuItem> _menuItems = [
    AdminMenuItem(
      title: 'Tur Ekle',
      subtitle: 'Yeni tur oluştur',
      icon: MdiIcons.plusCircleOutline,
      screen: const AddTourScreen(),
    ),
    AdminMenuItem(
      title: 'Turları Yönet',
      subtitle: 'Turları düzenle ve sil',
      icon: MdiIcons.bus,
      screen: ManageToursScreen(),
    ),
    AdminMenuItem(
      title: 'Rezervasyonlar',
      subtitle: 'Rezervasyonları görüntüle ve yönet',
      icon: MdiIcons.bookOutline,
      screen: const ManageReservationsScreen(),
    ),
    AdminMenuItem(
      title: 'Kullanıcılar',
      subtitle: 'Kullanıcıları yönet',
      icon: MdiIcons.accountGroup,
      screen: ManageUsersScreen(),
    ),
    AdminMenuItem(
      title: 'Bildirimler',
      subtitle: 'Bildirimleri görüntüle ve yönet',
      icon: MdiIcons.bellOutline,
      screen: const NotificationsScreen(),
    ),

    AdminMenuItem(
      title: 'İstatistikler',
      subtitle: 'Tur istatistiklerini görüntüle',
      icon: MdiIcons.chartLine,
      screen: const StatisticsScreen(),
    ),
  ];

  Widget _buildWelcomeCard(BuildContext context) {
    return Container(
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
          Icon(
            Icons.admin_panel_settings,
            size: ResponsiveHelper.getFontSize(context, 48),
            color: Colors.blue.shade900,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tur Yönetim Sistemi',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(context, 24),
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Admin Paneline Hoş Geldiniz...',
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
    );
  }

  Widget _buildMenuItem(BuildContext context, AdminMenuItem menuItem) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => menuItem.screen),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(ResponsiveHelper.getFontSize(context, 16)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                menuItem.icon,
                size: ResponsiveHelper.getFontSize(context, 32),
                color: Colors.blue.shade900,
              ),
              SizedBox(height: ResponsiveHelper.getFontSize(context, 8)),
              Text(
                menuItem.title,
                style: TextStyle(
                  fontSize: ResponsiveHelper.getFontSize(context, 18),
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
                textAlign: TextAlign.center,
              ),
              if (menuItem.subtitle != null) ...[
                SizedBox(height: ResponsiveHelper.getFontSize(context, 4)),
                Text(
                  menuItem.subtitle!,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(context, 14),
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

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
        // Bildirim butonu kaldırıldı
      ),
      body: Container(
        color: Colors.grey[100],
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(ResponsiveHelper.getFontSize(context, 16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeCard(context),
                SizedBox(height: ResponsiveHelper.getFontSize(context, 24)),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: ResponsiveHelper.isMobile(context) ? 2 : 3,
                      childAspectRatio: 1.5,
                      crossAxisSpacing: ResponsiveHelper.getFontSize(context, 16),
                      mainAxisSpacing: ResponsiveHelper.getFontSize(context, 16),
                    ),
                    itemCount: _menuItems.length,
                    itemBuilder: (context, index) => _buildMenuItem(context, _menuItems[index]),
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
