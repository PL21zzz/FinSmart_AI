import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String icon;
  final int color;
  final String type; // 'expense' | 'income'

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });

  @override
  List<Object?> get props => [id, name, icon, color, type];
}
