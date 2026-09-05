import 'package:fixmytown_citizen/features/auth/domain/app_user.dart';

abstract interface class AuthRepository {
  AppUser? get currentUser;

  Stream<AppUser?> authStateChanges();

  Future<void> signIn({required String email, required String password});

  Future<void> signOut();
}
