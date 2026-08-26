import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    required super.displayName,
    super.photoUrl,
    super.currency = 'VND',
    super.monthlyBudget = 10000000.0,
    required super.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
      currency: map['currency'] as String? ?? 'VND',
      monthlyBudget: (map['monthlyBudget'] as num?)?.toDouble() ?? 10000000.0,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'currency': currency,
      'monthlyBudget': monthlyBudget,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      email: entity.email,
      displayName: entity.displayName,
      photoUrl: entity.photoUrl,
      currency: entity.currency,
      monthlyBudget: entity.monthlyBudget,
      createdAt: entity.createdAt,
    );
  }
}
