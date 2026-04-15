// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'baby.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Baby {

 String get id; String get familyId; String get name; DateTime get birthDate; String? get gender;// 'male' | 'female' | 'unknown'
 double? get weightKg; double? get heightCm; String? get photoUrl; bool get isActive;
/// Create a copy of Baby
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BabyCopyWith<Baby> get copyWith => _$BabyCopyWithImpl<Baby>(this as Baby, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Baby&&(identical(other.id, id) || other.id == id)&&(identical(other.familyId, familyId) || other.familyId == familyId)&&(identical(other.name, name) || other.name == name)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.heightCm, heightCm) || other.heightCm == heightCm)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}


@override
int get hashCode => Object.hash(runtimeType,id,familyId,name,birthDate,gender,weightKg,heightCm,photoUrl,isActive);

@override
String toString() {
  return 'Baby(id: $id, familyId: $familyId, name: $name, birthDate: $birthDate, gender: $gender, weightKg: $weightKg, heightCm: $heightCm, photoUrl: $photoUrl, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class $BabyCopyWith<$Res>  {
  factory $BabyCopyWith(Baby value, $Res Function(Baby) _then) = _$BabyCopyWithImpl;
@useResult
$Res call({
 String id, String familyId, String name, DateTime birthDate, String? gender, double? weightKg, double? heightCm, String? photoUrl, bool isActive
});




}
/// @nodoc
class _$BabyCopyWithImpl<$Res>
    implements $BabyCopyWith<$Res> {
  _$BabyCopyWithImpl(this._self, this._then);

  final Baby _self;
  final $Res Function(Baby) _then;

/// Create a copy of Baby
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? familyId = null,Object? name = null,Object? birthDate = null,Object? gender = freezed,Object? weightKg = freezed,Object? heightCm = freezed,Object? photoUrl = freezed,Object? isActive = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,familyId: null == familyId ? _self.familyId : familyId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,birthDate: null == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as DateTime,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,weightKg: freezed == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double?,heightCm: freezed == heightCm ? _self.heightCm : heightCm // ignore: cast_nullable_to_non_nullable
as double?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Baby].
extension BabyPatterns on Baby {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Baby value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Baby() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Baby value)  $default,){
final _that = this;
switch (_that) {
case _Baby():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Baby value)?  $default,){
final _that = this;
switch (_that) {
case _Baby() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String familyId,  String name,  DateTime birthDate,  String? gender,  double? weightKg,  double? heightCm,  String? photoUrl,  bool isActive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Baby() when $default != null:
return $default(_that.id,_that.familyId,_that.name,_that.birthDate,_that.gender,_that.weightKg,_that.heightCm,_that.photoUrl,_that.isActive);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String familyId,  String name,  DateTime birthDate,  String? gender,  double? weightKg,  double? heightCm,  String? photoUrl,  bool isActive)  $default,) {final _that = this;
switch (_that) {
case _Baby():
return $default(_that.id,_that.familyId,_that.name,_that.birthDate,_that.gender,_that.weightKg,_that.heightCm,_that.photoUrl,_that.isActive);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String familyId,  String name,  DateTime birthDate,  String? gender,  double? weightKg,  double? heightCm,  String? photoUrl,  bool isActive)?  $default,) {final _that = this;
switch (_that) {
case _Baby() when $default != null:
return $default(_that.id,_that.familyId,_that.name,_that.birthDate,_that.gender,_that.weightKg,_that.heightCm,_that.photoUrl,_that.isActive);case _:
  return null;

}
}

}

/// @nodoc


class _Baby implements Baby {
  const _Baby({required this.id, required this.familyId, required this.name, required this.birthDate, this.gender, this.weightKg, this.heightCm, this.photoUrl, this.isActive = true});
  

@override final  String id;
@override final  String familyId;
@override final  String name;
@override final  DateTime birthDate;
@override final  String? gender;
// 'male' | 'female' | 'unknown'
@override final  double? weightKg;
@override final  double? heightCm;
@override final  String? photoUrl;
@override@JsonKey() final  bool isActive;

/// Create a copy of Baby
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BabyCopyWith<_Baby> get copyWith => __$BabyCopyWithImpl<_Baby>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Baby&&(identical(other.id, id) || other.id == id)&&(identical(other.familyId, familyId) || other.familyId == familyId)&&(identical(other.name, name) || other.name == name)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.heightCm, heightCm) || other.heightCm == heightCm)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}


@override
int get hashCode => Object.hash(runtimeType,id,familyId,name,birthDate,gender,weightKg,heightCm,photoUrl,isActive);

@override
String toString() {
  return 'Baby(id: $id, familyId: $familyId, name: $name, birthDate: $birthDate, gender: $gender, weightKg: $weightKg, heightCm: $heightCm, photoUrl: $photoUrl, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class _$BabyCopyWith<$Res> implements $BabyCopyWith<$Res> {
  factory _$BabyCopyWith(_Baby value, $Res Function(_Baby) _then) = __$BabyCopyWithImpl;
@override @useResult
$Res call({
 String id, String familyId, String name, DateTime birthDate, String? gender, double? weightKg, double? heightCm, String? photoUrl, bool isActive
});




}
/// @nodoc
class __$BabyCopyWithImpl<$Res>
    implements _$BabyCopyWith<$Res> {
  __$BabyCopyWithImpl(this._self, this._then);

  final _Baby _self;
  final $Res Function(_Baby) _then;

/// Create a copy of Baby
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? familyId = null,Object? name = null,Object? birthDate = null,Object? gender = freezed,Object? weightKg = freezed,Object? heightCm = freezed,Object? photoUrl = freezed,Object? isActive = null,}) {
  return _then(_Baby(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,familyId: null == familyId ? _self.familyId : familyId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,birthDate: null == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as DateTime,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,weightKg: freezed == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double?,heightCm: freezed == heightCm ? _self.heightCm : heightCm // ignore: cast_nullable_to_non_nullable
as double?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
