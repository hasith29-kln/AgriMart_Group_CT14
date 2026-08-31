import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Stream<UserModel?> currentUserStream() {
    return _auth.authStateChanges().asyncExpand((user) {
      if (user == null) {
        return Stream.value(null);
      }
      return _firestore
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .map((doc) => doc.exists && doc.data() != null
              ? UserModel.fromMap(doc.data()!, doc.id)
              : null);
    });
  }

  Future<UserModel?> getCurrentUserModel() async {
    if (currentUser == null) return null;
    final doc = await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> registerWithEmailAndPassword(
    String email,
    String password,
    Map<String, dynamic> userData,
  ) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Save user data to Firestore
    if (credential.user != null) {
      userData['createdAt'] = FieldValue.serverTimestamp();
      userData['email'] = email;
      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(userData);
    }
    return credential;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<UserCredential> registerWithoutLoggingOut(
    String email,
    String password,
    Map<String, dynamic> userData,
  ) async {
    // We use a secondary Firebase app to create the user so the current officer doesn't get logged out
    FirebaseApp secondaryApp;
    try {
      secondaryApp = Firebase.app('SecondaryApp');
    } catch (e) {
      secondaryApp = await Firebase.initializeApp(
        name: 'SecondaryApp',
        options: Firebase.app().options,
      );
    }
    
    final credential = await FirebaseAuth.instanceFor(app: secondaryApp).createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (credential.user != null) {
      userData['createdAt'] = FieldValue.serverTimestamp();
      userData['email'] = email;
      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(userData);
    }
    
    // We do NOT delete the app to avoid issues, we just reuse it next time.
    return credential;
  }
}
