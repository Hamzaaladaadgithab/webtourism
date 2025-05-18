import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/storage_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final StorageService _storageService = StorageService();
  final ImagePicker _imagePicker = ImagePicker();

  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isEditing = false;
  bool _isPasswordVisible = false;
  bool _notificationsEnabled = true;
  String? _error;
  AppUser? _user;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) {
        setState(() {
          _error = 'Kullanıcı girişi yapılmamış';
          _isLoading = false;
        });
        return;
      }

      final userData = await _userService.getUser(currentUser.uid);
      if (userData == null) {
        setState(() {
          _error = 'Kullanıcı bilgileri bulunamadı';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _user = userData;
        _nameController.text = userData.name;
        _phoneController.text = userData.phone;
        _emailController.text = userData.email;
        _notificationsEnabled = userData.notificationsEnabled ?? true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_user == null) throw Exception('Kullanıcı bilgisi bulunamadı');

      await _userService.updateUser(_user!.id, {
        'name': _nameController.text,
        'phone': _phoneController.text,
        'notificationsEnabled': _notificationsEnabled,
      });

      if (_currentPasswordController.text.isNotEmpty &&
          _newPasswordController.text.isNotEmpty) {
        await _authService.updatePassword(
          _currentPasswordController.text,
          _newPasswordController.text,
        );
      }

      setState(() {
        _isEditing = false;
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil başarıyla güncellendi'),
          backgroundColor: Colors.green,
        ),
      );

      await _loadUserData();
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() => _isLoading = true);
      final imageUrl = await _storageService.uploadProfileImage(_user!.id, image.path);
      await _userService.updateUser(_user!.id, {'profileImage': imageUrl});
      await _loadUserData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Resim yüklenirken hata: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _nameController.text = _user?.name ?? '';
      _phoneController.text = _user?.phone ?? '';
      _emailController.text = _user?.email ?? '';
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    });
  }

  Future<void> _deleteAccount() async {
    final TextEditingController passwordController = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hesap Silme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'DİKKAT: Bu işlem geri alınamaz!\n\n'
              'Hesabınızı silmek istediğinizden emin misiniz?\n'
              'Tüm verileriniz kalıcı olarak silinecektir.\n\n'
              'Devam etmek için şifrenizi girin:',
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Şifre',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hesabımı Sil'),
          ),
        ],
      ),
    );

    if (confirm ?? false) {
      try {
        setState(() => _isLoading = true);
        // Önce kullanıcının kimliğini doğrula
        await _authService.reauthenticateWithPassword(passwordController.text);
        // Sonra hesabı sil
        await _userService.deleteUser(_user!.id);
        await _authService.deleteAccount();
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/login');
      } catch (e) {
        setState(() => _isLoading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hesap silinirken hata: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: _cancelEditing,
            )
          else
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _isEditing ? _pickImage : null,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _user?.profileImage != null
                            ? NetworkImage(_user!.profileImage!)
                            : null,
                        child: _user?.profileImage == null
                            ? Text(
                                _user?.name[0].toUpperCase() ?? 'U',
                                style: const TextStyle(fontSize: 40),
                              )
                            : null,
                      ),
                      if (_isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  enabled: _isEditing,
                  decoration: const InputDecoration(labelText: 'Ad Soyad'),
                  validator: (value) => value == null || value.isEmpty ? 'Ad gerekli' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _phoneController,
                  enabled: _isEditing,
                  decoration: const InputDecoration(labelText: 'Telefon'),
                  validator: (value) => value == null || value.isEmpty ? 'Telefon gerekli' : null,
                ),
                const SizedBox(height: 10),
                if (_isEditing) ...[
                  SwitchListTile(
                    title: const Text('Bildirimleri Aç'),
                    value: _notificationsEnabled,
                    onChanged: (value) => setState(() => _notificationsEnabled = value),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _currentPasswordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Mevcut Şifre',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () =>
                            setState(() => _isPasswordVisible = !_isPasswordVisible),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Yeni Şifre'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Yeni Şifre (Tekrar)'),
                    validator: (value) {
                      if (_newPasswordController.text != value) {
                        return 'Şifreler eşleşmiyor';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _updateProfile,
                    child: const Text('Kaydet'),
                  ),
                  TextButton(
                    onPressed: _deleteAccount,
                    child: const Text(
                      'Hesabı Sil',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
 