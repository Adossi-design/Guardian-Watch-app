import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class SignInUseCase {
  const SignInUseCase(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, UserEntity>> call(SignInParams params) =>
      _repository.signInWithEmail(email: params.email, password: params.password);
}

class SignInParams extends Equatable {
  const SignInParams({required this.email, required this.password});
  final String email;
  final String password;

  @override
  List<Object> get props => [email, password];
}
