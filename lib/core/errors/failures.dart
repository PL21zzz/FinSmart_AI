import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Lỗi kết nối máy chủ']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Lỗi xác thực người dùng']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Lỗi bộ nhớ tạm local']);
}

class AiProcessingFailure extends Failure {
  const AiProcessingFailure([super.message = 'AI xử lý dữ liệu không thành công']);
}
