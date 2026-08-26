import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String currency;
  final double monthlyBudget;
  final DateTime createdAt;

  const UserEntity({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.currency = 'VND',
    this.monthlyBudget = 10000000.0,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        uid,
        email,
        displayName,
        photoUrl,
        currency,
        monthlyBudget,
        createdAt,
      ];
}
