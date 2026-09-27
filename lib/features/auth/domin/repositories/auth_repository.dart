import 'package:crm_app/features/auth/domin/entitites/app_user.dart';

abstract class AuthRepository {
  Future<AppUser> signIn({required String email, required String password});
  Future<void> signOut();
  AppUser? get currentUser;
  Stream<AppUser?> get authStateChanges;
}