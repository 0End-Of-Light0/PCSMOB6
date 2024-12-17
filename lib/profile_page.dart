import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _surnameController;
  late TextEditingController _phoneController;
  String _avatarPath = 'assets/images/user_avatar.png';

  Map<String, dynamic> _profileData = {
    'name': 'Test User',
    'surname': '',
    'phone': '+123 456 7890',
    'avatar': 'assets/images/user_avatar.png',
  };

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _nameController = TextEditingController(text: _profileData['name']);
    _surnameController = TextEditingController(text: _profileData['surname']);
    _phoneController = TextEditingController(text: _profileData['phone']);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<File> _getProfileFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/profile.json');
  }

  Future<void> _loadProfileData() async {
    try {
      final file = await _getProfileFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        setState(() {
          _profileData = jsonDecode(content);
          _nameController.text = _profileData['name'];
          _surnameController.text = _profileData['surname'];
          _phoneController.text = _profileData['phone'];
          _avatarPath = _profileData['avatar'];
        });
      }
    } catch (e) {
      // Если произошла ошибка, оставляем данные по умолчанию
      debugPrint('Error loading profile data: $e');
    }
  }

  Future<void> _saveProfileData() async {
    _profileData['name'] = _nameController.text;
    _profileData['surname'] = _surnameController.text;
    _profileData['phone'] = _phoneController.text;
    _profileData['avatar'] = _avatarPath;
    try {
      final file = await _getProfileFile();
      await file.writeAsString(jsonEncode(_profileData));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile data saved successfully!')),
      );
    } catch (e) {
      debugPrint('Error saving profile data: $e');
    }
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      final newPath = '${directory.path}/${pickedFile.name}';
      final newFile = await File(pickedFile.path).copy(newPath);
      setState(() {
        _avatarPath = newFile.path;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No image selected.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveProfileData,
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _pickAvatar,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: File(_avatarPath).existsSync()
                      ? FileImage(File(_avatarPath))
                      : AssetImage(_avatarPath) as ImageProvider,
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle: TextStyle(fontSize: 18),
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _surnameController,
                  decoration: InputDecoration(
                    labelText: 'Surname',
                    labelStyle: TextStyle(fontSize: 18),
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone',
                    labelStyle: TextStyle(fontSize: 18),
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProfileData,
                child: const Text('Save Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
