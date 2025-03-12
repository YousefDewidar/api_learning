import 'package:api_learning/char/char.dart';

abstract class GetCharrState {}

class GetCharrInitial extends GetCharrState {}

class GetCharrSuccess extends GetCharrState {
  final List<Charr> charr;
  GetCharrSuccess({required this.charr});
}

class GetCharrError extends GetCharrState {
  final String message;
  GetCharrError({required this.message});
}

class GetCharrLoading extends GetCharrState {}
