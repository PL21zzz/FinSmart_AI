import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/failures.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel?> getCurrentUser();
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  });
  Future<UserModel> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  });
  Future<void> signOut();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSourceImpl({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<UserModel?> getCurrentUser() async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get()
          .timeout(const Duration(seconds: 3));

      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, currentUser.uid);
      }
    } catch (e) {
      debugPrint('Firestore getCurrentUser exception: $e');
    }

    return UserModel(
      uid: currentUser.uid,
      email: currentUser.email ?? '',
      displayName: currentUser.displayName ?? 'Người dùng FinSmart',
      photoUrl: currentUser.photoURL,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      try {
        final doc = await _firestore
            .collection('users')
            .doc(uid)
            .get()
            .timeout(const Duration(seconds: 3));

        if (doc.exists && doc.data() != null) {
          return UserModel.fromMap(doc.data()!, uid);
        }
      } catch (e) {
        debugPrint('Firestore signInWithEmail exception: $e');
      }

      return UserModel(
        uid: uid,
        email: email,
        displayName: credential.user!.displayName ?? email.split('@').first,
        createdAt: DateTime.now(),
      );
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw ServerFailure('Đăng nhập thất bại: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      // Update Firebase Auth profile
      await credential.user?.updateDisplayName(displayName);

      final userModel = UserModel(
        uid: uid,
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
      );

      // TỰ ĐỘNG TẠO BẢNG 'users' VÀ DOCUMENT TRÊN FIRESTORE (KÈM TIMEOUT & CẢNH BÁO)
      try {
        await _firestore
            .collection('users')
            .doc(uid)
            .set(userModel.toMap())
            .timeout(const Duration(seconds: 3));

        // TỰ ĐỘNG TẠO CÁC DANH MỤC MẶC ĐỊNH CHO NGƯỜI DÙNG MỚI
        await _initDefaultCategories(uid).timeout(const Duration(seconds: 3));
      } catch (e) {
        // Nếu Firestore chưa được bật trên Firebase Console hoặc bị chối quyền,
        // vẫn cho phép đăng nhập thành công và ghi log cảnh báo
        debugPrint('Lưu thông tin Firestore bị bỏ qua (Firestore chưa được bật trên Firebase Console): $e');
      }

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw ServerFailure('Đăng ký thất bại: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> _initDefaultCategories(String uid) async {
    final categoriesRef = _firestore.collection('users').doc(uid).collection('categories');

    final defaultCategories = [
      {'name': 'Ăn uống', 'icon': 'utensils', 'color': 0xFF10B981, 'type': 'expense'},
      {'name': 'Mua sắm', 'icon': 'shopping-bag', 'color': 0xFF3B82F6, 'type': 'expense'},
      {'name': 'Hóa đơn & Điện nước', 'icon': 'file-invoice-dollar', 'color': 0xFFF59E0B, 'type': 'expense'},
      {'name': 'Giải trí', 'icon': 'gamepad', 'color': 0xFF8B5CF6, 'type': 'expense'},
      {'name': 'Di chuyển', 'icon': 'car', 'color': 0xFFEC4899, 'type': 'expense'},
      {'name': 'Lương tháng', 'icon': 'wallet', 'color': 0xFF059669, 'type': 'income'},
      {'name': 'Thưởng & Thu nhập khác', 'icon': 'gift', 'color': 0xFF10B981, 'type': 'income'},
    ];

    for (var cat in defaultCategories) {
      final docRef = categoriesRef.doc();
      await docRef.set({
        'id': docRef.id,
        ...cat,
      });
    }
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Tài khoản không tồn tại trên hệ thống.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Mật khẩu hoặc email không chính xác.';
      case 'email-already-in-use':
        return 'Email này đã được sử dụng cho tài khoản khác.';
      case 'invalid-email':
        return 'Định dạng email không hợp lệ.';
      case 'weak-password':
        return 'Mật khẩu quá yếu (tối thiểu 6 ký tự).';
      default:
        return 'Lỗi xác thực: $code';
    }
  }
}
