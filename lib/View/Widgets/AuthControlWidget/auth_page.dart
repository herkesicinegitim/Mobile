// ignore_for_file: use_build_context_synchronously

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

  // Kullanıcının rolünü almak için Firestore'dan veri çekme fonksiyonu
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

  // Dersleri Firestore'dan almak için kullanılan fonksiyon
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
          // Kullanıcı oturum açarken gösterilecek yükleniyor durumu
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CupertinoActivityIndicator(),
            );
          }

          // Kullanıcı giriş yaptıysa
          if (snapshot.hasData) {
            final User? user = snapshot.data;
            if (user != null) {
              return FutureBuilder<String?>(
                future: getUserRole(user.uid), // Kullanıcı rolünü almak için çağrı yapılıyor
                builder: (context, roleSnapshot) {
                  // Rol yükleniyor
                  if (roleSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CupertinoActivityIndicator(),
                    );
                  }

                  // Rol verisi alındığında
                  if (roleSnapshot.hasData) {
                    final String role = roleSnapshot.data!;
                    return FutureBuilder<List<Lesson>>(
                      future: getLessons(), // Dersleri almak için çağrı yapılıyor
                      builder: (context, lessonsSnapshot) {
                        // Dersler yükleniyor
                        if (lessonsSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CupertinoActivityIndicator(),
                          );
                        }

                        // Ders verisi alındığında
                        if (lessonsSnapshot.hasData) {
                          final lessons = lessonsSnapshot.data!;
                          return MainControl(
                            userId: user.uid,
                            role: role,
                            lessons: lessons, // Ana kontrol sayfasına dersler ve rol iletiliyor
                          );
                        }

                        return const Center(
                          child: Text('Dersler yüklenemedi.'),
                        ); // Dersler yüklenemedi mesajı
                      },
                    );
                  }

                  // Rol bilgisi alınamadığında, çıkış yapma butonu gösteriliyor
                  return Center(
                    child: IconButton(
                      onPressed: () async {
                        try {
                          await FirebaseAuth.instance.signOut(); // Kullanıcıyı çıkartma
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
              return const LoginScreen(); // Giriş yapılmamışsa login ekranı
            }
          } else {
            return const LoginScreen(); // Veritabanı bağlantısı yoksa login ekranı
          }
        },
      ),
    );
  }
}
