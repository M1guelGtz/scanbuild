class LoginState {
  final bool isSubmitting;
  final bool isGoogleLoading;
  final bool isBiometricLoading;
  /// Whether the device + user state qualify for a biometric shortcut.
  /// Resolved asynchronously after the page mounts.
  final bool biometricAvailable;
  /// Whether to prompt the user to enable biometric after a successful
  /// password/google login that just happened.
  final bool shouldOfferBiometricEnroll;
  final String? errorMessage;
  final bool keepSession;

  const LoginState({
    this.isSubmitting = false,
    this.isGoogleLoading = false,
    this.isBiometricLoading = false,
    this.biometricAvailable = false,
    this.shouldOfferBiometricEnroll = false,
    this.errorMessage,
    this.keepSession = true,
  });

  bool get isBusy => isSubmitting || isGoogleLoading || isBiometricLoading;

  LoginState copyWith({
    bool? isSubmitting,
    bool? isGoogleLoading,
    bool? isBiometricLoading,
    bool? biometricAvailable,
    bool? shouldOfferBiometricEnroll,
    Object? errorMessage = _sentinel,
    bool? keepSession,
  }) {
    return LoginState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isGoogleLoading: isGoogleLoading ?? this.isGoogleLoading,
      isBiometricLoading: isBiometricLoading ?? this.isBiometricLoading,
      biometricAvailable: biometricAvailable ?? this.biometricAvailable,
      shouldOfferBiometricEnroll:
          shouldOfferBiometricEnroll ?? this.shouldOfferBiometricEnroll,
      errorMessage:
          errorMessage == _sentinel ? this.errorMessage : errorMessage as String?,
      keepSession: keepSession ?? this.keepSession,
    );
  }

  static const Object _sentinel = Object();
}
