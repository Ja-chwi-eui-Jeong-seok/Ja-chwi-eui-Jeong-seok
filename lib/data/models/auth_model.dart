import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ja_chwi/domain/entities/auth_entity.dart';

class AuthModel extends AuthEntity {
  AuthModel({
    required String uid,
    required String accountData,
    required String accountEmail,
    required String accountType,
    required String createDevice,
    required bool privacyConsent,
    required bool agreeToTermsOfService,
    required DateTime? userCreateDate,
    required DateTime? userUpdateDate,
    required DateTime? userDeleteDate,
    required String userDeleteNote,
    required bool managerType,
  }) : super(
         uid: uid,
         accountData: accountData,
         accountEmail: accountEmail,
         accountType: accountType,
         createDevice: createDevice,
         privacyConsent: privacyConsent,
         agreeToTermsOfService: agreeToTermsOfService,
         userCreateDate: userCreateDate,
         userUpdateDate: userUpdateDate,
         userDeleteDate: userDeleteDate,
         userDeleteNote: userDeleteNote,
         managerType: managerType,
       );

  factory AuthModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime? _toDate(dynamic v) {
      if (v == null) return null;
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
      return DateTime.now();
    }

    return AuthModel(
      uid: id,
      accountData: map['account_data'] ?? '',
      accountEmail: map['account_email'] ?? '',
      accountType: map['account_type'] ?? '',
      createDevice: map['create_device'] ?? '',
      privacyConsent: map['privacy_consent'] ?? false,
      agreeToTermsOfService: map['agree_to_terms_of_service'] ?? false,
      userCreateDate: _toDate(map['user_create_date']),
      userUpdateDate: _toDate(map['user_update_date']),
      userDeleteDate: _toDate(map['user_delete_date']),
      userDeleteNote: map['user_delete_note'] ?? '',
      managerType: map['manager_type'] ?? false,
    );
  }

  AuthEntity toDomain() => AuthEntity(
    uid: uid,
    accountData: accountData,
    accountEmail: accountEmail,
    accountType: accountType,
    createDevice: createDevice,
    privacyConsent: privacyConsent,
    agreeToTermsOfService: agreeToTermsOfService,
    userCreateDate: userCreateDate,
    userUpdateDate: userUpdateDate,
    userDeleteDate: userDeleteDate,
    userDeleteNote: userDeleteNote,
    managerType: managerType,
  );

  factory AuthModel.fromDomain(AuthEntity entity) => AuthModel(
    uid: entity.uid,
    accountData: entity.accountData,
    accountEmail: entity.accountEmail,
    accountType: entity.accountType,
    createDevice: entity.createDevice,
    privacyConsent: entity.privacyConsent,
    agreeToTermsOfService: entity.agreeToTermsOfService,
    userCreateDate: entity.userCreateDate,
    userUpdateDate: entity.userUpdateDate,
    userDeleteDate: entity.userDeleteDate,
    userDeleteNote: entity.userDeleteNote,
    managerType: entity.managerType,
  );

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'account_data': accountData,
      'account_email': accountEmail,
      'account_type': accountType,
      'create_device': createDevice,
      'privacy_consent': privacyConsent,
      'agree_to_terms_of_service': agreeToTermsOfService,
      'user_create_date': userCreateDate,
      'user_update_date': userUpdateDate,
      'user_delete_date': userDeleteDate,
      'user_delete_note': userDeleteNote,
      'manager_type': managerType,
    };
  }
}
