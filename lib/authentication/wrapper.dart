import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, User;
import 'package:flutter/material.dart';
import '../home/homepage.dart';
import 'login.dart';
import 'services/firestore_service.dart';
import 'verify_email.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasData && snapshot.data != null) {
            final user = snapshot.data!;
            // Ensure logged-in user is registered in Firestore
            FirestoreService.syncCurrentUser();

            // If email is verified, go straight to HomeScreen;
            // Otherwise, prompt user to verify email first.
            if (user.emailVerified) {
              return const HomeScreen();
            } else {
              return const VerifyEmail();
            }
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Something went wrong!'),
            );
          } else {
            return const Login();
          }
        },
      ),
    );
  }
}
