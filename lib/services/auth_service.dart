import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/user_model.dart';
import '../utils/app_constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register with email and password
  Future<UserModel?> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Create user in Firebase Auth
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = result.user;
      if (user == null) return null;

      // Create user profile in database
      final UserModel newUser = UserModel(
        id: user.uid,
        name: name,
        email: email,
      );

      await _database
          .child(AppConstants.usersCollection)
          .child(user.uid)
          .set(newUser.toJson());

      // Update display name
      await user.updateDisplayName(name);

      return newUser;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw AppConstants.errorGeneric;
    }
  }

  // Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = result.user;
      if (user == null) return null;

      // Get user data from database
      final snapshot = await _database
          .child(AppConstants.usersCollection)
          .child(user.uid)
          .get();

      if (snapshot.exists) {
        return UserModel.fromJson(
          Map<String, dynamic>.from(snapshot.value as Map),
          user.uid,
        );
      }

      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw AppConstants.errorGeneric;
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw AppConstants.errorGeneric;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw AppConstants.errorGeneric;
    }
  }

  // Get user data
  Future<UserModel?> getUserData(String userId) async {
    try {
      final snapshot = await _database
          .child(AppConstants.usersCollection)
          .child(userId)
          .get();

      if (snapshot.exists) {
        return UserModel.fromJson(
          Map<String, dynamic>.from(snapshot.value as Map),
          userId,
        );
      }

      return null;
    } catch (e) {
      throw AppConstants.errorGeneric;
    }
  }

  // Update user profile
  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _database
          .child(AppConstants.usersCollection)
          .child(user.id)
          .update(user.toJson());
    } catch (e) {
      throw AppConstants.errorGeneric;
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'invalid-email':
        return AppConstants.errorInvalidEmail;
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return AppConstants.errorNetwork;
      default:
        return AppConstants.errorGeneric;
    }
  }
}
