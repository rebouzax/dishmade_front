const _unset = Object();

class PublicServiceRequestState {
  final bool isSending;
  final String? errorMessage;

  const PublicServiceRequestState({this.isSending = false, this.errorMessage});

  PublicServiceRequestState copyWith({
    bool? isSending,
    Object? errorMessage = _unset,
  }) {
    return PublicServiceRequestState(
      isSending: isSending ?? this.isSending,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}
