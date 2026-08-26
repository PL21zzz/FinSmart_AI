import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> getCurrentUser();
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<UserEntity> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  });
  Future<void> signOut();
}
