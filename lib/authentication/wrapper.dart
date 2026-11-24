import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, User;
import 'package:flutter/material.dart';
import '../home/homepage.dart';
import 'login.dart';
import 'services/firestore_service.dart';
import 'verify_email.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  /// Track the last synced UID so we only call syncCurrentUser once per login,
  /// not on every stream rebuild (which happens frequently inside build).
  String? _syncedUid;

  void _syncIfNeeded(User user) {
    if (_syncedUid != user.uid) {
      _syncedUid = user.uid;
      FirestoreService.syncCurrentUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong!'));
          }

          final user = snapshot.data;

          if (user == null) {
            _syncedUid = null; // reset on sign-out
            return const Login();
          }

          // Sync to Firestore once per sign-in (not on every build).
          _syncIfNeeded(user);

          if (user.emailVerified) {
            return const HomeScreen();
          } else {
            return const VerifyEmail();
          }
        },
      ),
    );
  }
}
