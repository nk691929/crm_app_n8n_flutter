import 'package:crm_app/features/auth/domain/entities/app_user.dart';
import 'package:crm_app/features/auth/domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  Future<AppUser> signIn({required String email, required String password}) async {
    final user = await _dataSource.signIn(email: email, password: password);
    return AppUser(id: user.id, email: user.email ?? '');
  }

  @override
  Future<void> signOut() => _dataSource.signOut();

  @override
  AppUser? get currentUser {
    final user = _dataSource.currentUser;
    if (user == null) return null;
    return AppUser(id: user.id, email: user.email ?? '');
  }

  @override
  Stream<AppUser?> get authStateChanges {
    return _dataSource.authStateChanges.map((user) {
      if (user == null) return null;
      return AppUser(id: user.id, email: user.email ?? '');
    });
  }
}