import 'package:firebase_auth/firebase_auth.dart';

class AuthSession {
  const AuthSession({required this.access, required this.refresh});
  final String access;
  final String refresh;
}

class AuthRepository {
  AuthRepository({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Login menggunakan Firebase Auth API
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('User tidak ditemukan setelah login');
      }

      final idToken = await user.getIdToken() ?? '';
      final refreshToken = user.refreshToken ?? '';

      return AuthSession(access: idToken, refresh: refreshToken);
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e.code, e.message));
    } catch (e) {
      throw Exception('Gagal melakukan login: $e');
    }
  }

  /// Registrasi akun baru menggunakan Firebase Auth API
  Future<AuthSession> register({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('Gagal membuat user baru');
      }

      final idToken = await user.getIdToken() ?? '';
      final refreshToken = user.refreshToken ?? '';

      return AuthSession(access: idToken, refresh: refreshToken);
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e.code, e.message));
    } catch (e) {
      throw Exception('Gagal melakukan pendaftaran: $e');
    }
  }

  /// Logout dari Firebase Auth
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Memperbarui ID token jika expired
  Future<String> refresh(String refreshToken) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Sesi telah berakhir, silakan login ulang');
    final freshToken = await user.getIdToken(true);
    return freshToken ?? '';
  }

  String _mapAuthError(String code, String? defaultMessage) {
    switch (code) {
      case 'user-not-found':
        return 'Akun dengan email ini belum terdaftar.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email atau kata sandi salah. Silakan coba lagi.';
      case 'email-already-in-use':
        return 'Email ini sudah terdaftar. Silakan login atau gunakan email lain.';
      case 'invalid-email':
        return 'Format alamat email tidak valid.';
      case 'weak-password':
        return 'Kata sandi terlalu lemah. Gunakan minimal 6 karakter.';
      case 'user-disabled':
        return 'Akun pengguna ini telah dinonaktifkan.';
      case 'network-request-failed':
        return 'Koneksi internet bermasalah. Periksa jaringan Anda.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan login gagal. Coba lagi beberapa saat lagi.';
      default:
        return defaultMessage ?? 'Terjadi kesalahan autentikasi ($code).';
    }
  }
}