import '../../../../core/platform/mock_location_guard.dart';

class IntegrityState {
  final bool isChecking;
  final IntegrityResult? result;

  const IntegrityState({this.isChecking = true, this.result});

  IntegrityState copyWith({bool? isChecking, IntegrityResult? result}) {
    return IntegrityState(
      isChecking: isChecking ?? this.isChecking,
      result: result ?? this.result,
    );
  }
}
