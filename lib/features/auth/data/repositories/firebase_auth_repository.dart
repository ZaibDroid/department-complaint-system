import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../core/utils/image_compressor.dart';
import '../../domain/entities/user.dart';

class FirebaseAuthRepository {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<User?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      return await _fetchUserProfile(firebaseUser.uid, firebaseUser.email!);
    }
    return null;
  }

  Future<User> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        return await _fetchUserProfile(userCredential.user!.uid, userCredential.user!.email!);
      }
      throw Exception('Login failed: User is null');
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<User> register({
    required String name,
    required String email,
    required String password,
    String? year,
    String? batch,
    String? section,
    String? adviser,
    String? phone,
    bool isCR = false,
  }) async {
    try {
      // 1. Create the user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Registration failed: User is null');
      }

      // 2. Determine default role (you can expand this logic for staff emails)
      String role = 'Student';
      if (email == 'admin@uetmardan.edu.pk') role = 'Admin';
      if (email == 'chairman@uetmardan.edu.pk') role = 'Chairman';
      if (email == 'dean@uetmardan.edu.pk') role = 'Dean';
      if (email == 'coordinator@uetmardan.edu.pk') role = 'Coordinator';
      if (email == 'office@uetmardan.edu.pk') role = 'Office';
      if (email.startsWith('adviser') || email.startsWith('batchadviser')) role = 'Batch Adviser';

      // 3. Create the User entity
      final user = User(
        id: firebaseUser.uid,
        name: name,
        email: email,
        role: role,
        year: year,
        batch: batch,
        section: section,
        adviser: adviser,
        phone: phone,
        isCR: isCR,
        status: role == 'Student' ? 'unlinked' : 'approved',
      );

      // 4. Save to Firestore
      await _firestore.collection('users').doc(firebaseUser.uid).set(user.toJson());

      return user;
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  Future<void> createStaffAccount({
    required String name,
    required String email,
    required String password,
    required String role,
    String? batch,
    String? section,
    String? semester,
  }) async {
    try {
      // Create a secondary app instance to avoid logging out the current admin
      final tempApp = await Firebase.initializeApp(
        name: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        options: Firebase.app().options,
      );
      
      final tempAuth = firebase_auth.FirebaseAuth.instanceFor(app: tempApp);
      final userCredential = await tempAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        final user = User(
          id: firebaseUser.uid,
          name: name,
          email: email,
          role: role,
          status: 'approved',
          batch: batch,
          section: section,
          semester: semester,
        );
        await _firestore.collection('users').doc(firebaseUser.uid).set(user.toJson());
      }
      
      await tempAuth.signOut();
      await tempApp.delete();
    } catch (e) {
      throw Exception('Failed to create staff account: ${e.toString()}');
    }
  }

  Future<void> updateStaffAccount(String uid, {
    required String name,
    required String batch,
    required String section,
    required String semester,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'name': name,
        'batch': batch,
        'section': section,
        'semester': semester,
      });
    } catch (e) {
      throw Exception('Failed to update staff account: ${e.toString()}');
    }
  }

  Future<void> updateUserStatus(String uid, String status) async {
    await _firestore.collection('users').doc(uid).update({'status': status});
  }

  Future<void> updateUserAdviser(String uid, String adviser) async {
    await _firestore.collection('users').doc(uid).update({
      'adviser': adviser,
      'status': 'pending',
    });
  }

  Future<int> handoverStudents(String oldAdviserName, String newAdviserName) async {
    final snapshot = await _firestore.collection('users')
        .where('role', isEqualTo: 'Student')
        .where('adviser', isEqualTo: oldAdviserName)
        .get();
        
    if (snapshot.docs.isEmpty) return 0;

    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'adviser': newAdviserName});
    }
    await batch.commit();
    return snapshot.docs.length;
  }

  Future<void> updatePersonalInfo(String uid, {
    required String name,
    required String year,
    required String batch,
    required String section,
    required String phone,
    String? department,
  }) async {
    final Map<String, dynamic> data = {
      'name': name,
      'year': year,
      'batch': batch,
      'section': section,
      'phone': phone,
    };
    if (department != null) {
      data['department'] = department;
    }
    await _firestore.collection('users').doc(uid).update(data);
  }

  Future<void> updatePassword({required String oldPassword, required String newPassword}) async {
    final user = _auth.currentUser;
    if (user != null && user.email != null) {
      try {
        final credential = firebase_auth.EmailAuthProvider.credential(
          email: user.email!,
          password: oldPassword,
        );
        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(newPassword);
      } catch (e) {
        throw Exception('Incorrect old password or authentication failed.');
      }
    } else {
      throw Exception('No authenticated user found.');
    }
  }

  Future<String> uploadProfileImage(String uid, File imageFile) async {
    final compressedFile = await ImageCompressor.compressImage(imageFile);
    final fileToUpload = compressedFile != null ? File(compressedFile.path) : imageFile;
    
    final ref = _storage.ref().child('users/$uid/profile.jpg');
    await ref.putFile(fileToUpload);
    final downloadUrl = await ref.getDownloadURL();
    await _firestore.collection('users').doc(uid).update({'profileImageUrl': downloadUrl});
    return downloadUrl;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<User> _fetchUserProfile(String uid, String fallbackEmail) async {
    final docSnapshot = await _firestore.collection('users').doc(uid).get();
    
    if (docSnapshot.exists && docSnapshot.data() != null) {
      return User.fromJson(docSnapshot.data()!);
    } else {
      // Fallback if document doesn't exist yet (e.g. they authenticated but Firestore failed)
      return User(
        id: uid,
        name: 'Unknown User',
        email: fallbackEmail,
        role: 'Student',
      );
    }
  }
}
