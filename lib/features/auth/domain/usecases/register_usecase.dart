import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class RegisterUseCase {
  const RegisterUseCase(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, UserEntity>> call(RegisterParams params) =>
      _repository.registerWithEmail(
        email: params.email,
        password: params.password,
        name: params.name,
        phone: params.phone,
        role: params.role,
      );
}

class RegisterParams extends Equatable {
  const RegisterParams({
    required this.email,
    required this.password,
    required this.name,
    required this.phone,
    required this.role,
  });

  final String email;
  final String password;
  final String name;
  final String phone;
  final UserRole role;

  @override
  List<Object> get props => [email, name, phone, role];
}
