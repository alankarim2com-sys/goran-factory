import 'package:firebase_core/firebase_core.dart';

class FirebaseConfig {
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyAXFSdKvlIqRMffocPNDpdhU1YUvZNj-XdI',
          appId: '1:691261568325:web:38787f48c560f04d504e2c',
          messagingSenderId: '691261568325',
          projectId: 'goran-factory',
          authDomain: 'goran-factory.firebaseapp.com',
          storageBucket: 'goran-factory.firebasestorage.app',
        ),
      );
      print('Firebase initialized successfully');
    } catch (e) {
      print('Error initializing Firebase: $e');
      rethrow;
    }
  }
}
