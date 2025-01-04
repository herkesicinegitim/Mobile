import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:education/Core/Constants/app_colors.dart';
import 'package:education/Data/Models/lesson.dart';
import 'package:education/View/Screens/Core/main_control.dart';
import 'package:education/View/Screens/Login/Screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  Future<String?> getUserRole(String uid) async {
    try {
      final DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('Users').doc(uid).get();

      if (userDoc.exists) {
        return userDoc['role'] as String?;
      }
    } catch (e) {
      debugPrint('Error fetching user role: $e');
    }
    return null;
  }

  Future<List<Lesson>> getLessons() async {
    try {
      final QuerySnapshot lessonsSnapshot =
          await FirebaseFirestore.instance.collection('lessons').get();

      return lessonsSnapshot.docs
          .map((doc) => Lesson.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching lessons: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasData) {
            final User? user = snapshot.data;
            if (user != null) {
              return FutureBuilder<String?>(
                future: getUserRole(user.uid),
                builder: (context, roleSnapshot) {
                  if (roleSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CupertinoActivityIndicator(),
                    );
                  }

                  if (roleSnapshot.hasData) {
                    final String role = roleSnapshot.data!;
                    return FutureBuilder<List<Lesson>>(
                      future: getLessons(),
                      builder: (context, lessonsSnapshot) {
                        if (lessonsSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (lessonsSnapshot.hasData) {
                          final lessons = lessonsSnapshot.data!;
                          return MainControl(
                            userId: user.uid,
                            role: role,
                            lessons: lessons,
                          );
                        }

                        return const Center(
                          child: Text('Dersler yüklenemedi.'),
                        );
                      },
                    );
                  }

                  return Center(
                    child: IconButton(
                      onPressed: () async {
                        try {
                          await FirebaseAuth.instance.signOut();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Başarıyla çıkış yapıldı.")),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    "Çıkış yapılırken bir hata oluştu: $e")),
                          );
                        }
                      },
                      icon: const Icon(Icons.logout),
                      tooltip: "Çıkış Yap",
                    ),
                  );
                },
              );
            } else {
              return const LoginScreen();
            }
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
