import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl({AuthRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? AuthRemoteDataSourceImpl();

  @override
  Future<UserEntity?> getCurrentUser() async {
    return await _remoteDataSource.getCurrentUser();
  }

  @override
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _remoteDataSource.signInWithEmail(
      email: email,
      password: password,
    );
  }

  @override
  Future<UserEntity> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    return await _remoteDataSource.registerWithEmail(
      email: email,
      password: password,
      displayName: displayName,
    );
  }

  @override
  Future<void> signOut() async {
    await _remoteDataSource.signOut();
  }
}
