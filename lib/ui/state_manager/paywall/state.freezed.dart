// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PaywallListState {
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isError => throw _privateConstructorUsedError;
  String get errorMessage => throw _privateConstructorUsedError;
  List<Paywall> get paywalls => throw _privateConstructorUsedError;

  /// Create a copy of PaywallListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaywallListStateCopyWith<PaywallListState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaywallListStateCopyWith<$Res> {
  factory $PaywallListStateCopyWith(
          PaywallListState value, $Res Function(PaywallListState) then) =
      _$PaywallListStateCopyWithImpl<$Res, PaywallListState>;
  @useResult
  $Res call(
      {bool isLoading,
      bool isError,
      String errorMessage,
      List<Paywall> paywalls});
}

/// @nodoc
class _$PaywallListStateCopyWithImpl<$Res, $Val extends PaywallListState>
    implements $PaywallListStateCopyWith<$Res> {
  _$PaywallListStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaywallListState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? isError = null,
    Object? errorMessage = null,
    Object? paywalls = null,
  }) {
    return _then(_value.copyWith(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isError: null == isError
          ? _value.isError
          : isError // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: null == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String,
      paywalls: null == paywalls
          ? _value.paywalls
          : paywalls // ignore: cast_nullable_to_non_nullable
              as List<Paywall>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PaywallListStateImplCopyWith<$Res>
    implements $PaywallListStateCopyWith<$Res> {
  factory _$$PaywallListStateImplCopyWith(_$PaywallListStateImpl value,
          $Res Function(_$PaywallListStateImpl) then) =
      __$$PaywallListStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isLoading,
      bool isError,
      String errorMessage,
      List<Paywall> paywalls});
}

/// @nodoc
class __$$PaywallListStateImplCopyWithImpl<$Res>
    extends _$PaywallListStateCopyWithImpl<$Res, _$PaywallListStateImpl>
    implements _$$PaywallListStateImplCopyWith<$Res> {
  __$$PaywallListStateImplCopyWithImpl(_$PaywallListStateImpl _value,
      $Res Function(_$PaywallListStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of PaywallListState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? isError = null,
    Object? errorMessage = null,
    Object? paywalls = null,
  }) {
    return _then(_$PaywallListStateImpl(
      null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      null == isError
          ? _value.isError
          : isError // ignore: cast_nullable_to_non_nullable
              as bool,
      null == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String,
      null == paywalls
          ? _value._paywalls
          : paywalls // ignore: cast_nullable_to_non_nullable
              as List<Paywall>,
    ));
  }
}

/// @nodoc

class _$PaywallListStateImpl implements _PaywallListState {
  _$PaywallListStateImpl(
      [this.isLoading = false,
      this.isError = false,
      this.errorMessage = '',
      final List<Paywall> paywalls = const []])
      : _paywalls = paywalls;

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isError;
  @override
  @JsonKey()
  final String errorMessage;
  final List<Paywall> _paywalls;
  @override
  @JsonKey()
  List<Paywall> get paywalls {
    if (_paywalls is EqualUnmodifiableListView) return _paywalls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_paywalls);
  }

  @override
  String toString() {
    return 'PaywallListState(isLoading: $isLoading, isError: $isError, errorMessage: $errorMessage, paywalls: $paywalls)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaywallListStateImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isError, isError) || other.isError == isError) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            const DeepCollectionEquality().equals(other._paywalls, _paywalls));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isLoading, isError, errorMessage,
      const DeepCollectionEquality().hash(_paywalls));

  /// Create a copy of PaywallListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaywallListStateImplCopyWith<_$PaywallListStateImpl> get copyWith =>
      __$$PaywallListStateImplCopyWithImpl<_$PaywallListStateImpl>(
          this, _$identity);
}

abstract class _PaywallListState implements PaywallListState {
  factory _PaywallListState(
      [final bool isLoading,
      final bool isError,
      final String errorMessage,
      final List<Paywall> paywalls]) = _$PaywallListStateImpl;

  @override
  bool get isLoading;
  @override
  bool get isError;
  @override
  String get errorMessage;
  @override
  List<Paywall> get paywalls;

  /// Create a copy of PaywallListState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaywallListStateImplCopyWith<_$PaywallListStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
