import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/session_manager.dart';
import '../database/db_helper.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEdit = false;

  File? profileImage;
  final picker = ImagePicker();

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  String? oldUsername;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Apakah kamu yakin ingin log out?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Tidak',
              style: TextStyle(color: Colors.black54),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await SessionManager.logout();

              if (!mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5C5C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Ya',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadUser() async {
    final username = await SessionManager.getUsername();
    if (username == null) return;

    oldUsername = username;
    usernameController.text = username;
    passwordController.text = '********';

    final imagePath = await DBHelper.getProfileImage(username);
    if (imagePath != null && imagePath.isNotEmpty) {
      setState(() {
        profileImage = File(imagePath);
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await picker.pickImage(source: source);
    if (picked != null && oldUsername != null) {
      final file = File(picked.path);

      await DBHelper.updateProfileImage(
        oldUsername!,
        file.path,
      );

      setState(() {
        profileImage = file;
      });
    }
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleEdit() async {
    if (isEdit) {
      if (usernameController.text.trim().isEmpty ||
          passwordController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Harap diisi, jangan kosong!'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      if (oldUsername != null) {
        if (oldUsername != usernameController.text) {
          await DBHelper.updateUsername(
            oldUsername!,
            usernameController.text,
          );
          await SessionManager.saveLogin(usernameController.text);
          oldUsername = usernameController.text;
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil berhasil disimpan')),
          );
        }
      }
    }

    setState(() => isEdit = !isEdit);
  }

  // ===================== DIALOG BANTUAN (?) =====================
  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFFE8D6AB), // Warna krem
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SizedBox(
          // Tinggi dialog dibatasi agar bisa discroll jika perlu
          height: MediaQuery.of(context).size.height * 0.65,
          child: Column(
            children: [
              // Tombol silang di kiri atas
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  padding: const EdgeInsets.only(left: 15, top: 15),
                  icon: const Icon(Icons.close, color: Colors.red, size: 35),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              // Area Scrollable untuk Konten
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: [
                      // Penjelasan Avatar (Foto Profil)
                      Image.asset('assets/images/notifavatar.png', width: 140),
                      const SizedBox(height: 10),
                      const Text(
                        "Sentuh gambar profil ini untuk mengganti foto akunmu! Kamu bisa memilih foto dari galeri atau memotret langsung dengan kamera.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(height: 30),

                      // Penjelasan Tombol Edit
                      Image.asset('assets/images/notifedit.png', width: 160),
                      const SizedBox(height: 10),
                      const Text(
                        "Tombol Edit ini berguna kalau kamu ingin mengubah nama panggilan (username) atau kata sandi (password) milikmu.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(height: 30),

                      // Penjelasan Tombol Simpan
                      Image.asset('assets/images/notifbtsimpan.png',
                          width: 160),
                      const SizedBox(height: 10),
                      const Text(
                        "Setelah selesai mengubah nama dan kata sandi, jangan lupa tekan tombol Simpan ini ya agar perubahanmu tidak hilang!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int currentImpact = 8312;
    int maxImpact = 10000;
    double progressValue = currentImpact / maxImpact;

    return Scaffold(
      // Membungkus dengan Stack agar tombol ? bisa diletakkan di atas background
      body: Stack(
        children: [
          // Background dan Konten Utama
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg_profile.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                // Agar konten bisa scroll jika layar kecil, tapi BG tetap diam
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    // FOTO PROFIL
                    GestureDetector(
                      onTap: _showImagePicker,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.yellow[400],
                          border: Border.all(color: Colors.yellow, width: 4),
                          image: DecorationImage(
                            image: profileImage != null
                                ? FileImage(profileImage!)
                                : const AssetImage('assets/images/trash.png')
                                    as ImageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // LEVEL BAR
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.yellow[700],
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          Column(
                            children: [
                              const Text(
                                'LV',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '${(progressValue * 10).floor()}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: progressValue,
                                    minHeight: 10,
                                    color: Colors.green,
                                    backgroundColor: Colors.yellow[200],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$currentImpact dampak   max $maxImpact',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(Icons.card_giftcard),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    // INPUT FIELD
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        children: [
                          _inputField(
                            'Username',
                            usernameController,
                            enabled: isEdit,
                          ),
                          const SizedBox(height: 15),
                          _inputField(
                            'Password',
                            passwordController,
                            enabled: isEdit,
                            obscure: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    // TOMBOL EDIT / SIMPAN
                    ElevatedButton(
                      onPressed: _toggleEdit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5C5C),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 80,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        isEdit ? 'Simpan' : 'Edit',
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontFamily: 'CherryBomb',
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // TOMBOL LOGOUT
                    ElevatedButton(
                      onPressed: _confirmLogout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 70,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontFamily: 'CherryBomb',
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),

          // Tombol Bantuan (?) di pojok kanan atas
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 10, right: 20),
                child: GestureDetector(
                  onTap: () => _showHelpDialog(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.help_outline,
                      color: Colors.black87,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFFFD72E),
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/koleksi');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.collections),
            label: 'Koleksi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _inputField(
    String hint,
    TextEditingController controller, {
    bool enabled = false,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: enabled ? Colors.white : Colors.white70,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
